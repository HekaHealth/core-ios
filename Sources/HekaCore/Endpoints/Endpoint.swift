//
//  Endpoint.swift
//
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Foundation
import SystemConfiguration

typealias WebResponse = (Result<[String: Any], Error>) -> Void

func isNetworkReachable() -> Bool {
  var zeroAddress = sockaddr_in()
  zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
  zeroAddress.sin_family = sa_family_t(AF_INET)

  guard
    let defaultRouteReachability = withUnsafePointer(
      to: &zeroAddress,
      {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
      })
  else {
    return false
  }

  var flags: SCNetworkReachabilityFlags = []
  if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
    return false
  }

  let isReachable = flags.contains(.reachable)
  let needsConnection = flags.contains(.connectionRequired)

  return (isReachable && !needsConnection)
}

protocol Endpoint {
  var url: String { get }
  var method: String { get }
  var parameters: [String: Any]? { get }
  var headers: [String: String] { get }
}

extension Endpoint {
  var base: String {
    "https://heka-backend.delightfulmeadow-20fa0dd3.australiaeast.azurecontainerapps.io/watch_sdk"
  }

  var headers: [String: String] {
    return ["Content-Type": "application/json"]
  }
}

//MARK: - Webservice Interaction Method
extension Endpoint {
  /**
   Method for interacting with the server for data
   - parameter api: Endpoints object for preferred data from the server
   - parameter withHiddenIndicator: True if you want to interact without the Loading indicator
   - parameter withHiddenError: True if you want to hide error popup from backend
   - parameter responseClosure: A Closure to handle the response from the server
   */
  func request(
    withHiddenError: Bool = false,
    responseClosure: @escaping WebResponse
  ) {

    if !isNetworkReachable() {
      //TODO: - Throw error here
      return
    }
    printRequest()

    // Assuming url, method, and parameters are defined
    guard let url = URL(string: url) else {
      print("Invalid URL")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = method  // "GET", "POST", etc.

    if let parameters = parameters {
      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    }

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        self.handle(.failure(error), responseClosure: responseClosure)
      } else if let data = data {
        self.handle(.success(data), responseClosure: responseClosure)
      }
    }

    task.resume()
  }

  private func printRequest() {
    debugPrint(
      "********************************* API Request **************************************")
    debugPrint("Request URL:\(url)")
    debugPrint("Request Parameters: \(parameters ?? [:])")
    debugPrint("Request Headers: \(headers)")
  }

  private func handle(_ response: Result<Data?, Error>, responseClosure: WebResponse) {
    switch response {
    case .success(let data):
      debugPrint("Response:---------->")
      if let data = data {
        debugPrint(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "")

        do {
          let dictionary =
            try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          responseClosure(.success(dictionary ?? [:]))
        } catch {
          print(error.localizedDescription)
        }

      } else {
        debugPrint("No Data found in the response")
        responseClosure(.success([:]))
      }
      debugPrint(
        "************************************************************************************")
    case .failure(let error):
      debugPrint("Response:---------->")
      debugPrint(error.localizedDescription)
      debugPrint(
        "************************************************************************************")
      responseClosure(.failure(error))
    }
  }
}
