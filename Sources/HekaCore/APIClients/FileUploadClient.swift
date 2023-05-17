//
//  FileUploadClient.swift
//
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Alamofire
import Foundation

struct FileDetails {

  let fileName: String
  let paramName: String
  let mime: String

  init(
    fileName: String = "data.json", paramName: String = "data", mime: String = "application/json"
  ) {
    self.fileName = fileName
    self.paramName = paramName
    self.mime = mime
  }
}

struct FileUploadClinet {

  private let apiKey: String
  private let userUUID: String
  private let dataSource: String

  private let endpoint: FileUploadEndpoint

  init(apiKey: String, userUUID: String, dataSource: String = "sdk_healthkit") {
    self.apiKey = apiKey
    self.userUUID = userUUID
    self.dataSource = dataSource
    endpoint = .userDataJSON(apiKey: apiKey, userUUID: userUUID, dataSource: dataSource)
  }

  func uploadUserDataFile(
    from locationURL: URL,
    with fileDetail: FileDetails,
    with completion: @escaping (Bool) -> Void
  ) {
    do {
      let data = try Data(contentsOf: locationURL)

      AF.upload(
        multipartFormData: { formData in
          formData.append(
            data, withName: fileDetail.paramName,
            fileName: fileDetail.fileName, mimeType: fileDetail.mime
          )
        },
        to: endpoint.url,
        method: endpoint.method,
        headers: endpoint.header
      )
      .responseData { result in
        switch result.result {
        case .success(let data):
          // check the response status code
          print("___Printing Response Code_____")
          print(result.response?.statusCode ?? 0)
          // complete false is status code is not 200
          guard result.response?.statusCode == 200 else {
            completion(false)
            return
          }
          let responseBody = String(data: data, encoding: .utf8)
          print("___Printing Response body_____")
          print(responseBody ?? "Invalid response")
          completion(true)
        case .failure(let error):
          print(error.localizedDescription)
          completion(false)
        }
      }

    } catch {
      print("JSON file not found at: ", locationURL, "With Error: ", error)
      completion(false)
    }
  }
}
