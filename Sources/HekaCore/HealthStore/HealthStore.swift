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
  var pendingAnchorUpdates: [String: HKQueryAnchor] = [:]
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

  func writePendingAnchorUpdates() {
    self.logger.info("writing pending anchor updates")
    let pendingAnchorUpdates = self.pendingAnchorUpdates
    for (key, value) in pendingAnchorUpdates {
      self.logger.info("writing pending anchor update for \(key)")
      self.hekaKeyChainHelper.setAnchor(value, for: key)
    }
    self.pendingAnchorUpdates = [:]
  }

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    self.logger.info("requesting authorization from healthkit")
    guard let healthStore = self.healthStore else {
      self.logger.info("healthstore not found, returning false")
      return completion(false)
    }

    healthStore.requestAuthorization(
      toShare: [], read: Set(self.healthkitDataTypes.healthDataTypes)
    ) { bool, error in
      if error != nil {
        self.logger.info("request auth returned error, returning false")
        return completion(false)
      } else if bool == true {
        return completion(true)
      } else {
        self.logger.info("request auth returned false, returning false")
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

      self.triggerSync {
        completionHandler()
      }
    }

    self.logger.info("executing observer query")
    if healthStore != nil {
      healthStore!.execute(obsQuery!)
    }
  }

  public func triggerSync(completion: @escaping () -> Void) {
    // TODO: this should be replaced with HKAnchoredObjectQuery
    if self.queryInProgress {
      self.logger.info("a query in progress, so ignoring the observer query update")
      return completion()
    }

    self.logger.info("triggering sync")
    let userUuid = self.hekaKeyChainHelper.userUuid
    let apiKey = self.hekaKeyChainHelper.apiKey

    self.queryInProgress = true
    self.logger.info("marking query in progress")

    let currentDate = Date()

    var healthDataTypesToFetch: [String] = [
      self.healthkitDataTypes.STEPS,
      self.healthkitDataTypes.DISTANCE_WALKING_RUNNING,
      self.healthkitDataTypes.ACTIVE_ENERGY_BURNED,
    ]

    if #available(iOS 13.0, *) {
      healthDataTypesToFetch.append(self.healthkitDataTypes.MENSTRUAL_FLOW)
      healthDataTypesToFetch.append(self.healthkitDataTypes.SLEEP_ANALYSIS)
    }

    // Get steps and upload to server
    firstly {
      self.combineResults(
        healthDataTypes: healthDataTypesToFetch,
        currentDate: currentDate)
    }.done { samples in
      if !samples.isEmpty {
        self.logger.info("got the samples in the observer query callback, sending them to server")
        self.handleUserData(
          with: samples, apiKey: apiKey!, uuid: userUuid!, currentDate: currentDate
        ) {
          self.queryInProgress = false
          self.logger.info("unmarking query in progress")
          return completion()
        }
      }
    }
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
    var totalCount = 0
    for (_, value) in samples {
      if let value = value as? [NSDictionary] {
        totalCount += value.count
      }
    }
    self.logger.info("sending \(samples.count) samples to server")
    fileHandler.createJSONFile(with: samples) { filePath in
      if filePath == nil {
        self.logger.info("failed to create JSON file")
        completion()
        return
      }
      self.uploadClient = FileUploadClinet(
        apiKey: apiKey, userUUID: uuid
      )

      self.uploadClient?.uploadUserDataFile(
        from: filePath, with: FileDetails()
      ) { syncSuccessful in
        switch syncSuccessful {
        case true:
          self.logger.info("Data synced successfully")
          self.hekaKeyChainHelper.markFirstUpload(syncDate: currentDate)
          self.writePendingAnchorUpdates()
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

  func getAggregatedValueCount(
    startDate: Date, endDate: Date, dataTypeKey: String, completion: @escaping (Double?) -> Void
  ) {
    self.logger.info(
      "getting aggregated value count for \(dataTypeKey) from \(startDate) to \(endDate)")
    //  let dataType : HKSampleType = self.healthkitDataTypes.dataTypesDict[dataTypeKey]!
    let predicate = HKQuery.predicateForSamples(
      withStart: startDate, end: endDate, options: .strictStartDate)

    var count: Double?
    var objectType: HKQuantityType?

    var dataTypeMap: [String: (type: HKQuantityType, unit: HKUnit)] = [
      "steps": (HKQuantityType.quantityType(forIdentifier: .stepCount)!, HKUnit.count()),
      "distance_moved": (
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKUnit.meter()
      ),
      "calories": (
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, HKUnit.kilocalorie()
      ),

      "exercise_minutes": (
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!, HKUnit.minute()
      ),
      "floors_climbed": (
        HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!, HKUnit.count()
      ),
      "resting_heart_rate": (
        HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
        HKUnit.count().unitDivided(by: HKUnit.minute())
      ),
      "weight": (
        HKQuantityType.quantityType(forIdentifier: .bodyMass)!, HKUnit.gramUnit(with: .kilo)
      ),
      "height": (HKQuantityType.quantityType(forIdentifier: .height)!, HKUnit.meter()),
      "blood_oxygen": (
        HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!, HKUnit.percent()
      ),
    ]
    if #available(iOS 14.5, *) {
      dataTypeMap["move_minutes"] = (
        HKQuantityType.quantityType(forIdentifier: .appleMoveTime)!, HKUnit.minute()
      )
    }

    guard let (objectType, unit) = dataTypeMap[dataTypeKey] else {
      self.logger.info("Invalid data type \(dataTypeKey)")
      return
    }

    let query = HKStatisticsQuery(
      quantityType: objectType,
      quantitySamplePredicate: predicate, options: .cumulativeSum
    ) { (_, result, error) in
      guard let result = result, let sum = result.sumQuantity() else {
        self.logger.info("Failed to fetch aggregated data")
        // return 0 if failed to fetch
        completion(0)
        return
      }
      count = Double(sum.doubleValue(for: unit))
      completion(count)
    }
    if self.healthStore != nil {
      self.healthStore!.execute(query)
    }
  }

  func getDataFromType(
    dataTypeKey: String, currentDate: Date, completion: @escaping ([NSDictionary]) -> Void
  ) {
    self.logger.info("getting data for data type: \(dataTypeKey)")
    let dataType = self.healthkitDataTypes.dataTypesDict[dataTypeKey]
    var predicate: NSPredicate? = nil
    var anchor: HKQueryAnchor? = self.hekaKeyChainHelper.getAnchor(for: dataTypeKey)

    if anchor == nil {
      anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    }

    let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
    let start = self.hekaKeyChainHelper.lastSyncDate ?? oneWeekAgo
    if let lastSync = self.hekaKeyChainHelper.lastSyncDate, lastSync > oneWeekAgo {
      predicate = HKQuery.predicateForSamples(
        withStart: lastSync, end: currentDate, options: .strictStartDate)
    } else {
      predicate = HKQuery.predicateForSamples(
        withStart: start, end: currentDate, options: .strictStartDate)
    }

    let q = HKAnchoredObjectQuery(
      type: dataType!, predicate: predicate, anchor: anchor!, limit: HKObjectQueryNoLimit
    ) {
      (x, samplesOrNil, deletedObjectsOrNil, newAnchor, error) in

      guard error == nil else {
        self.logger.error("Error in getting \(dataTypeKey) data: \(error!)")
        completion([])
        return
      }

      self.pendingAnchorUpdates[dataTypeKey] = newAnchor

      switch samplesOrNil {
      case let (samples as [HKQuantitySample]) as Any:
        if samples.isEmpty {
          completion([])
          return
        }
        self.logger.info("got \(samples.count) samples for \(dataTypeKey)")
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

      default:
        print("Nothing found!")
        completion([])

      }

    }

    healthStore!.execute(q)
  }
}
