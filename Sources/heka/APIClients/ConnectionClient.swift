//
//  ConnectionClient.swift
//
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Foundation

public typealias ConnectionCompletion = (Result<Connection, Error>) -> Void

public struct ConnectionClient {

  enum ConnectionError: Error {
    case noData
    case noUser
    case noConnections

    public var description: String {
      switch self {
      case .noData:
        return "Data object not found in the JSON response"
      case .noUser:
        return "User's UUID not found in the JSON response"
      case .noConnections:
        return "No Connections found yet in the JSON response"
      }
    }
  }

  private let apiKey: String
  private let userUUID: String
  private let platform: String

  init(apiKey: String, userUUID: String, platform: String) {
    self.apiKey = apiKey
    self.userUUID = userUUID
    self.platform = platform
  }

  public func fetchConnection(with completion: @escaping ConnectionCompletion) {
    let endpoint = ConnectionEndpoint.fetch(apiKey: apiKey, userUUID: userUUID)
    requestEndpoint(endpoint, with: completion)
  }

  public func connectToServer(
    forUserWithEmail userEmail: String? = nil,
    and googleFitRefreshToken: String? = nil,
    with completion: @escaping ConnectionCompletion
  ) {
    let endpoint = ConnectionEndpoint.connect(
      apiKey: apiKey, userUUID: userUUID,
      googleFitRefreshToken: googleFitRefreshToken,
      emailID: userEmail,
      platform: platform
    )
    requestEndpoint(endpoint, with: completion)
  }

  public func disconnect(with completion: @escaping ConnectionCompletion) {
    let endpoint = ConnectionEndpoint.disconnect(
      apiKey: apiKey, userUUID: userUUID, platform: platform
    )
    requestEndpoint(endpoint, with: completion)
  }

  private func requestEndpoint(
    _ endpoint: ConnectionEndpoint,
    with completion: @escaping ConnectionCompletion
  ) {
    endpoint.request { result in
      switch result {
      case .success(let json):
        print(json)

        guard let data = json["data"] as? [String: Any] else {
          completion(.failure(ConnectionError.noData))
          return
        }

        guard let userUUID = data["user_uuid"] as? String else {
          completion(.failure(ConnectionError.noUser))
          return
        }

        guard let connections = data["connections"] as? [String: [String: Any]?] else {
          completion(.failure(ConnectionError.noConnections))
          return
        }

        var connectedPlatforms = [String: ConnectedPlatform]()

        connections.forEach { name, list in
          let platform = list?["platform_name"] as? String ?? ""
          let loggedIn = list?["logged_in"] as? Bool ?? false
          let lastSync = list?["last_sync"] as? String
          let connectedDeviceUUIDs = list?["connected_device_uuids"] as? [String]

          let connectedPlatform = ConnectedPlatform(
            platform: platform, loggedIn: loggedIn, lastSync: lastSync,
            connectedDeviceUUIDs: connectedDeviceUUIDs)
          connectedPlatforms[name] = connectedPlatform
        }

        let connection = Connection(userUuid: userUUID, connectedPlatforms: connectedPlatforms)
        completion(.success(connection))

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
