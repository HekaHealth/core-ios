//
//  KeychainHelper.swift
//
//
//  Created by Gaurav Tiwari on 16/02/23.
//

import HealthKit
import Logging
import Security
import UIKit

final class HekaKeychainHelper {

  let logger = Logger(label: "HekaKeychainHelper")

  private struct KeychainData: Codable {
    var apiKey: String
    var uuid: String
    var connected: Bool
    var firstUploadDate: Date?
  }

  private var keychainKey: String {
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      return bundleIdentifier + ".hekaSDKData"
    } else {
      return "hekaSDKData"
    }
  }

  private var anchorKey: String {
    return keychainKey + ".anchor"
  }

  func getAnchor(for dataType: String) -> HKQueryAnchor? {
    let typeKey = anchorKey + "." + dataType
    logger.info("Getting anchor for \(dataType)")
    guard let data = load(key: typeKey) else {
        return nil
    }
    return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
  }

  func setAnchor(_ anchor: HKQueryAnchor, for dataType: String) {
    let typeKey = anchorKey + "." + dataType
    logger.info("Setting anchor for \(dataType)")
    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) else {
        return
    }
    _ = save(key: typeKey, data: data)
  }

  private var keychainData: KeychainData? {
    get {
      logger.info("Getting keychain data")
      guard let data = load(key: keychainKey) else {
        return nil
      }
      return try? JSONDecoder().decode(KeychainData.self, from: data)
    }
    set {
      logger.info("Setting keychain data")
      guard let data = try? JSONEncoder().encode(newValue) else {
        return
      }
      _ = save(key: keychainKey, data: data)
    }
  }

  func markFirstUpload(syncDate: Date) {
    logger.info("marking first upload in keychain")
    var data =
      keychainData ?? KeychainData(apiKey: "", uuid: "", connected: false, firstUploadDate: nil)
    data.firstUploadDate = syncDate
    keychainData = data
  }

  func markConnected(
    apiKey: String, uuid: String, firstUploadDate: Date? = nil, completion: @escaping () -> Void
  ) {
    logger.info("marking connected in keychain")
    var data =
      keychainData ?? KeychainData(apiKey: "", uuid: "", connected: false, firstUploadDate: nil)
    data.connected = true
    data.apiKey = apiKey
    data.uuid = uuid
    data.firstUploadDate = firstUploadDate
    keychainData = data
    completion()
  }

  func markDisconnected() {
    logger.info("marking disconnected in keychain")
    var data =
      keychainData ?? KeychainData(apiKey: "", uuid: "", connected: false, firstUploadDate: nil)
    data.connected = false
    data.apiKey = ""
    data.uuid = ""
    data.firstUploadDate = nil
    keychainData = data
  }

  var lastSyncDate: Date? {
    return keychainData?.firstUploadDate
  }

  var isConnected: Bool {
    return keychainData?.connected ?? false
  }

  var apiKey: String? {
    return keychainData?.apiKey
  }

  var userUuid: String? {
    return keychainData?.uuid
  }

  private func save(key: String, data: Data) -> OSStatus {
    let query =
      [
        kSecClass as String: kSecClassGenericPassword as String,
        kSecAttrAccount as String: key,
        kSecValueData as String: data,
      ] as [String: Any]

    SecItemDelete(query as CFDictionary)

    return SecItemAdd(query as CFDictionary, nil)
  }

  private func load(key: String) -> Data? {
    let query =
      [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne,
      ] as [String: Any]

    var dataTypeRef: AnyObject? = nil

    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

    if status == noErr {
      return dataTypeRef as! Data?
    } else {
      return nil
    }
  }
}
