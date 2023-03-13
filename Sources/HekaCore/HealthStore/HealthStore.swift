//
//  HealthStore.swift
//  Runner
//
//  Created by Moksh Mahajan on 09/12/22.
//

import Foundation
import HealthKit
import Logging
import PromiseKit

class HealthStore {
  var healthStore: HKHealthStore?
  var query: HKStatisticsCollectionQuery?
  var obsQuery: HKObserverQuery?
  var queryInProgress: Bool = false
  private let healthkitDataTypes = HealthKitDataTypes()

  private let hekaKeyChainHelper = HekaKeychainHelper()
  private var uploadClient: FileUploadClinet?
  private let fileHandler = JSONFileHandler()
  let logger = Logger(label: "HealthStore")

  init() {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore = HKHealthStore()
      healthkitDataTypes.initWorkoutTypes()
      healthkitDataTypes.initDataTypeToUnit()
      healthkitDataTypes.initDataTypesDict()
    }
  }

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    self.logger.info("requesting authorization from healthkit")
    guard let healthStore = self.healthStore else {
      return completion(false)
    }

    healthStore.requestAuthorization(
      toShare: [], read: Set(self.healthkitDataTypes.healthDataTypes)
    ) { bool, error in
      if error != nil {
        return completion(false)
      } else if bool == true {
        return completion(true)
      } else {
        return completion(false)
      }

    }
  }

  func stopObserverQuery() {
    self.logger.info("stopping healthkit observer query")
    if let query = obsQuery {
      healthStore?.stop(query)
    }
    obsQuery = nil
  }

  // Public function to start syncing health data to server
  // This needs to be called in AppDelegate.swift
  public func setupObserverQuery() {
    self.logger.info("setting up healthkit observer query (public function)")
    setupStepsObserverQuery()
  }

  private func setupStepsObserverQuery() {
    let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!

    obsQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil) {
      (query, completionHandler, errorOrNil) in

      self.logger.info("we are in the observer query callback")

      if let error = errorOrNil {
        self.logger.error("error in observer query callback: \(error)")
        completionHandler()
        return
      }

      // if we are not connected, let's ignore the update
      if !self.hekaKeyChainHelper.isConnected {
        self.logger.info("we are not connected, so ignoring the observer query update")
        completionHandler()
        return
      }
      self.logger.info("we are connected, so we will sync the data")
      let userUuid = self.hekaKeyChainHelper.userUuid
      let apiKey = self.hekaKeyChainHelper.apiKey

      // TODO: this should be replaced with HKAnchoredObjectQuery
      if self.queryInProgress {
        self.logger.info("a query in progress, so ignoring the observer query update")
        completionHandler()
        return
      }

      self.queryInProgress = true
      self.logger.info("marking query in progress")

      let currentDate = Date()

      // Get steps and upload to server
      firstly {
        self.combineResults(
          healthDataTypes: [
            self.healthkitDataTypes.STEPS, self.healthkitDataTypes.HEART_RATE,
            self.healthkitDataTypes.DISTANCE_WALKING_RUNNING,
            self.healthkitDataTypes.ACTIVE_ENERGY_BURNED,
            self.healthkitDataTypes.BLOOD_PRESSURE_SYSTOLIC, self.healthkitDataTypes.BLOOD_OXYGEN,
            self.healthkitDataTypes.BLOOD_GLUCOSE,
            self.healthkitDataTypes.BODY_TEMPERATURE, self.healthkitDataTypes.HEIGHT,
            self.healthkitDataTypes.WEIGHT,
            self.healthkitDataTypes.BODY_MASS_INDEX,
            self.healthkitDataTypes.WATER,
            self.healthkitDataTypes.BODY_FAT_PERCENTAGE,
          ],
          currentDate: currentDate)
      }.done { samples in
        if !samples.isEmpty {
          self.logger.info("got the samples in the observer query callback, sending them to server")
          self.handleUserData(
            with: samples, apiKey: apiKey!, uuid: userUuid!, currentDate: currentDate
          ) {
            self.queryInProgress = false
            self.logger.info("unmarking query in progress")
            completionHandler()
          }
        }
      }
    }

    self.logger.info("executing observer query")
    healthStore!.execute(obsQuery!)
  }

  public func setupBackgroundDelivery() {
    let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
    self.logger.info("enabling background delivery")
    healthStore!.enableBackgroundDelivery(
      for: stepCountType, frequency: .immediate,
      withCompletion: { (succeeded, error) in
        if succeeded {
          print("Enabled background delivery of step changes")
        } else {
          if let theError = error {
            print("Failed to enable background delivery of steps changes. ")
            print("Error = \(theError)")
          }
        }
      })
  }

  private func handleUserData(
    with samples: [String: Any],
    apiKey: String, uuid: String,
    currentDate: Date,
    with completion: @escaping () -> Void
  ) {
    self.logger.info("sending user data to server, creating JSON file")
    fileHandler.createJSONFile(with: samples) { filePath in
      self.uploadClient = FileUploadClinet(
        apiKey: apiKey, userUUID: uuid
      )

      self.uploadClient?.uploadUserDataFile(
        from: filePath, with: FileDetails()
      ) { syncSuccessful in
        switch syncSuccessful {
        case true:
          self.hekaKeyChainHelper.markFirstUpload(syncDate: currentDate)
          self.logger.info("Data synced successfully")
        case false:
          self.logger.info("Data synced failed")
        }
        self.fileHandler.deleteJSONFile()
        completion()
      }
    }
  }

  func combineResults(healthDataTypes: [String], currentDate: Date) -> Promise<
    [String: [NSDictionary]]
  > {
    self.logger.info("fetching data for various data types and combining it")
    var promises = [Promise<[NSDictionary]>]()
    var results: [String: [NSDictionary]] = [:]

    for healthDataType in healthDataTypes {
      promises.append(getSamples(type: healthDataType, currentDate: currentDate))
    }

    return when(fulfilled: promises).map { value in
      for (index, type) in healthDataTypes.enumerated() {
        if !value[index].isEmpty {
          results[type.lowercased()] = value[index]
        }
      }
      return results
    }
  }

  func getSamples(type: String, currentDate: Date) -> Promise<[NSDictionary]> {
    return Promise<[NSDictionary]> { seal in
      getDataFromType(
        dataTypeKey: type,
        currentDate: currentDate,
        completion: { dict in
          seal.fulfill(dict)
        })
    }
  }

  func getDataFromType(
    dataTypeKey: String, currentDate: Date, completion: @escaping ([NSDictionary]) -> Void
  ) {
    self.logger.info("getting data for data type: \(dataTypeKey)")
    let dataType = self.healthkitDataTypes.dataTypesDict[dataTypeKey]
    var predicate: NSPredicate? = nil

    if let lastSync = hekaKeyChainHelper.lastSyncDate {
      predicate = HKQuery.predicateForSamples(
        withStart: lastSync, end: currentDate, options: .strictStartDate)
    } else {
      let start = Calendar.current.date(byAdding: .day, value: -120, to: currentDate)!
      predicate = HKQuery.predicateForSamples(
        withStart: start, end: currentDate, options: .strictStartDate)
    }

    let q = HKSampleQuery(
      sampleType: dataType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil
    ) {
      x, samplesOrNil, error in

      switch samplesOrNil {
      case let (samples as [HKQuantitySample]) as Any:
        print("HKQuantity Sample type data found: ")
        let unit = self.healthkitDataTypes.dataTypeToUnit[dataTypeKey]

        let dictionaries = samples.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "value": sample.quantity.doubleValue(for: unit!),
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name,
          ]
        }

        completion(dictionaries)

      case var (samplesCategory as [HKCategorySample]) as Any:
        print("HKCategory Sample type data found: ")
        if dataTypeKey == self.healthkitDataTypes.SLEEP_IN_BED {
          samplesCategory = samplesCategory.filter { $0.value == 0 }
        }
        if dataTypeKey == self.healthkitDataTypes.SLEEP_ASLEEP {
          samplesCategory = samplesCategory.filter { $0.value == 1 }
        }
        if dataTypeKey == self.healthkitDataTypes.SLEEP_AWAKE {
          samplesCategory = samplesCategory.filter { $0.value == 2 }
        }
        if dataTypeKey == self.healthkitDataTypes.HEADACHE_UNSPECIFIED {
          samplesCategory = samplesCategory.filter { $0.value == 0 }
        }
        if dataTypeKey == self.healthkitDataTypes.HEADACHE_NOT_PRESENT {
          samplesCategory = samplesCategory.filter { $0.value == 1 }
        }
        if dataTypeKey == self.healthkitDataTypes.HEADACHE_MILD {
          samplesCategory = samplesCategory.filter { $0.value == 2 }
        }
        if dataTypeKey == self.healthkitDataTypes.HEADACHE_MODERATE {
          samplesCategory = samplesCategory.filter { $0.value == 3 }
        }
        if dataTypeKey == self.healthkitDataTypes.HEADACHE_SEVERE {
          samplesCategory = samplesCategory.filter { $0.value == 4 }
        }
        let categories = samplesCategory.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "value": sample.value,
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name,
          ]
        }

        completion(categories)

      case let (samplesWorkout as [HKWorkout]) as Any:
        print("HKWorkout type data found: ")

        let dictionaries = samplesWorkout.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "workoutActivityType": self.healthkitDataTypes.workoutActivityTypeMap.first(where: {
              $0.value == sample.workoutActivityType
            })?.key,
            "totalEnergyBurned": sample.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()),
            "totalEnergyBurnedUnit": "KILOCALORIE",
            "totalDistance": sample.totalDistance?.doubleValue(for: HKUnit.meter()),
            "totalDistanceUnit": "METER",
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name,
          ]
        }

        completion(dictionaries)

      // if #available(iOS 13.0, *) {
      //   case let (samplesAudiogram as [HKAudiogramSample]) as Any:
      //       print("HKAudiogram Sample type data found: ")
      //       let dictionaries = samplesAudiogram.map { sample -> NSDictionary in
      //           var frequencies = [Double]()
      //           var leftEarSensitivities = [Double]()
      //           var rightEarSensitivities = [Double]()
      //           for samplePoint in sample.sensitivityPoints {
      //               frequencies.append(samplePoint.frequency.doubleValue(for: HKUnit.hertz()))
      //               // leftEarSensitivities.append(samplePoint.leftEarSensitivity!.doubleValue(for: HKUnit.decibelHearingLevel()))
      //               // rightEarSensitivities.append(samplePoint.rightEarSensitivity!.doubleValue(for: HKUnit.decibelHearingLevel()))
      //           }
      //           return [
      //               "uuid": "\(sample.uuid)",
      //               "frequencies": frequencies,
      //               "leftEarSensitivities": leftEarSensitivities,
      //               "rightEarSensitivities": rightEarSensitivities,
      //               "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
      //               "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
      //               "source_id": sample.sourceRevision.source.bundleIdentifier,
      //               "source_name": sample.sourceRevision.source.name
      //           ]
      //       }

      //       completion(dictionaries)
      // }

      default:
        print("Nothing found!")
        completion([])

      }

    }

    healthStore!.execute(q)
  }
}
