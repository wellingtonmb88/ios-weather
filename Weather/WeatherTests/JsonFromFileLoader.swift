//
//  JsonFromFileLoader.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 30/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

class JsonFromFileLoader {
    
    class func readJson(fromFile: String) -> NSData? {
        guard let filePath = Bundle(for: self).path(forResource: fromFile, ofType: "json") else {
            fatalError("UnitTestData.json not found")
        }
        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            let jsonData = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            return jsonData as NSData
        } catch {
            print(error)
            fatalError("Unable to read contents of the file url")
        }
        return nil
    }
    
}
