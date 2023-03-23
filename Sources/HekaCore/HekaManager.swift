import UIKit

public class HekaManager {

  public init() {}

  let healthStore = HealthStore()
  let keyChainHelper = HekaKeychainHelper()

  public func requestAuthorization(completion: @escaping (Bool) -> Void) {
    healthStore.requestAuthorization { success in
      completion(success)
    }
  }

  public func stopSyncing(completion: @escaping (Bool) -> Void) {
    self.keyChainHelper.markDisconnected()
    completion(true)
  }

  public func syncIosHealthData(
    apiKey: String, userUuid: String, lastSyncDate: Date? = nil,
    completion: @escaping (Bool) -> Void
  ) {
    healthStore.requestAuthorization { success in
      if success {
        self.keyChainHelper.markConnected(
          apiKey: apiKey, uuid: userUuid, firstUploadDate: lastSyncDate)
        self.healthStore.setupBackgroundDelivery()
        completion(true)
      } else {
        completion(false)
      }
    }
  }

  public func installObservers() {
    healthStore.setupObserverQuery()
  }
}
