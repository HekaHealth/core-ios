//
//  JSONFileHandler.swift
//
//
//  Created by Gaurav Tiwari on 18/02/23.
//

import Foundation

final class JSONFileHandler {

  // A random filename is generated to avoid conflicts with other apps
  private let fileName = "heka_\(UUID().uuidString).json"
  private var filePath: URL? {
    guard
      let documentDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      print("Cannot locate the document directory")
      return nil
    }
    return documentDirectory.appendingPathComponent(fileName)
  }

  func createJSONFile(with samples: [String: Any], and completion: (URL) -> Void) {
    guard
      let jsonData = try? JSONSerialization.data(withJSONObject: samples, options: .prettyPrinted),
      let jsonString = String(data: jsonData, encoding: .ascii)
    else {
      print("Cannot convert data to json")
      return
    }

    guard let filePath = filePath else {
      print("Cannot loacate the file at: ", filePath?.absoluteString ?? "")
      return
    }

    do {
      // make sure we clear any old data first
      try deleteJSONFile()
      try jsonString.write(to: filePath, atomically: true, encoding: .utf8)
      completion(filePath)
    } catch (let error) {
      print("Cannot write data to file with error: ", error)
    }
  }

  func deleteJSONFile() {
    guard let filePath = filePath else {
      print("Cannot loacate the file at: ", filePath?.absoluteString ?? "")
      return
    }
    do {
      try FileManager.default.removeItem(at: filePath)
    } catch {
      print("Cannot delete the userdata json file with error: ", error)
    }
  }
}
