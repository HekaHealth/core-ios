//
//  FileUploadEndpoint.swift
//  
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Foundation
import Alamofire

enum FileUploadEndpoint: Endpoint {
  
  case userDataJSON(apiKey: String, userUUID: String, dataSource: String)
  
  var url: String {
    switch self {
      case let .userDataJSON(apiKey, userUUID, dataSource):
        let queryItems = [
          URLQueryItem(name: "key", value: apiKey),
          URLQueryItem(name: "user_uuid", value: userUUID),
          URLQueryItem(name: "data_source", value: dataSource)
        ]
        var components = URLComponents(string: "\(base)/upload_health_data_as_json")!
        components.queryItems = queryItems
        return components.url!.absoluteString
    }
  }
  
  var method: Alamofire.HTTPMethod {
    .post
  }
  
  var parameters: Alamofire.Parameters? {
    nil
  }
}
