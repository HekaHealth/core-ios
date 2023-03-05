//
//  HekaResources.swift
//  
//
//  Created by Gaurav Tiwari on 22/02/23.
//

import Foundation

final class HekaResources {
  
  static let resourceBundle: Bundle = {
    
    let candidates = [
      // Bundle should be present here when the package is linked into an App.
      Bundle.main.resourceURL,
      
      // Bundle should be present here when the package is linked into a framework.
      Bundle(for: HekaResources.self).resourceURL,
    ]
    
    let bundleName = "heka_heka"
    
    for candidate in candidates {
      let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
      if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
        return bundle
      }
    }
    
      // Return whatever bundle this code is in as a last resort.
    return Bundle(for: HekaResources.self)
  }()
}
