//
//  MapViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 27/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import CoreData
 
struct MapViewModel {
    
    let persistence = PersistenceService.sharedInstance
    let city: City
    
    init(city: City) {
        self.city = city
    }
    
    public func persistCity() {
        let moc = persistence.getContext()
        moc.performAndWait {
            let entity =
                NSEntityDescription.entity(forEntityName: "CityEntity", in: moc)!
            
            let cityMO = NSManagedObject(entity: entity, insertInto: moc)
            
            cityMO.setValue(self.city.name, forKeyPath: "name")
            cityMO.setValue(self.city.state, forKeyPath: "state")
            cityMO.setValue(self.city.country, forKeyPath: "country")
            cityMO.setValue(self.city.latitude, forKeyPath: "latitude")
            cityMO.setValue(self.city.longitude, forKeyPath: "longitude")
            
            do {
                try moc.save()
                debugPrint("Core Data saved!")
            } catch let error as NSError {
                debugPrint("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
