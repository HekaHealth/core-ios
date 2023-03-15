//
//  Endpoint.swift
//
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Alamofire
import Foundation

typealias WebResponse = (Result<[String: Any], Error>) -> Void

protocol Endpoint {
  var url: String { get }
  var method: HTTPMethod { get }
  var parameters: Parameters? { get }
  var encoding: ParameterEncoding { get }
}

//MARK: - Common Properties and Configurations
extension Endpoint {
  var base: String {
    "https://heka-backend.delightfulmeadow-20fa0dd3.australiaeast.azurecontainerapps.io/watch_sdk"
  }

  var encoding: ParameterEncoding {
    return JSONEncoding.default
  }

  var header: HTTPHeaders {
    var headers = HTTPHeaders()
    headers["Content-Type"] = "application/json"
    return headers
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

    if !NetworkReachabilityManager()!.isReachable {
      //TODO: - Throw error here
      return
    }

    printRequest()

    AF.request(
      url, method: method, parameters: parameters, encoding: encoding
    ).response { result in
      self.handle(result.result, responseClosure: responseClosure)
    }
  }

  private func printRequest() {
    debugPrint(
      "********************************* API Request **************************************")
    debugPrint("Request URL:\(url)")
    debugPrint("Request Parameters: \(parameters ?? [:])")
    debugPrint("Request Headers: \(header)")
  }

  private func handle(_ response: Result<Data?, AFError>, responseClosure: WebResponse) {
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
