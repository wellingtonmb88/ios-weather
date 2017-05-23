//
//  City.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 27/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import CoreData

struct City  {
    
    var name: String?
    var state: String?
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var forecasts: [Forecast]?
    
    init(name: String, state: String,
         country: String, latitude: Double, longitude: Double){
        self.name = name
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(mo: NSManagedObject){ 
        self.name = mo.value(forKeyPath: "name") as? String
        self.state = mo.value(forKeyPath: "state") as? String
        self.country = mo.value(forKeyPath: "country") as? String
        self.latitude = mo.value(forKeyPath: "latitude") as? Double
        self.longitude = mo.value(forKeyPath: "longitude") as? Double
    } 
}
