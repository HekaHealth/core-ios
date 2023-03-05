//
//  File.swift
//
//
//  Created by Pulkit Goyal on 02/02/23.
//

import Foundation

struct ConnectedPlatform {
  let platform: String
  let loggedIn: Bool
  let lastSync: String?
  let connectedDeviceUUIDs: [String]?
}

struct Connection {
  let userUuid: String
  let connectedPlatforms: [String: ConnectedPlatform]

  func isPlatformConnected(platform: String) -> Bool {
    if let connectedPlatform = connectedPlatforms[platform] {
      return connectedPlatform.loggedIn
    } else {
      return false
    }
  }
}
