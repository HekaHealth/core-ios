public class HekaManager {

  public init() {}

  let healthStore = HealthStore()
  let keyChainHelper = HekaKeychainHelper()

  public func requestAuthorization(completion: @escaping (Bool) -> Void) {
    healthStore.requestAuthorization { success in
      completion(success)
    }
  }

  public func stopSyncing() -> Bool {
    keyChainHelper.markDisconnected()
    return true
  }

  public func syncIosHealthData(
    apiKey: String, userUuid: String, completion: @escaping (Bool) -> Void
  ) {
    healthStore.requestAuthorization { success in
      if success {
        // TODO: we should pass in last sync date too
        self.keyChainHelper.markConnected(apiKey: apiKey, uuid: userUuid)
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
