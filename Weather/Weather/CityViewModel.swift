//
//  CityViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 25/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import CoreData

protocol CityViewModelDelegate {
    func update(withCities cities: [City]) 
}

struct CityViewModel { 

    let persistence = PersistenceService.sharedInstance
    let delegate : CityViewModelDelegate
    let weatherApi = WeatherApi()
    
    init(delegate: CityViewModelDelegate){
        self.delegate = delegate
    }
    
    public func getForecasts(withCityName cityName: String, cityState: String,
                             callback: @escaping ([Forecast]?, NetError?)->()) {
        
        weatherApi.requestForecasts(city:cityName, state: cityState) {
            (forecasts, error) in
            
            if let netError = error as? NetError{
                callback(nil, netError)
                return
            }
            callback(forecasts, nil)
        }
    }
    
    public func bulkRequestForecasts(cities: [City], callback: @escaping ([City])->()) {
        var _cities = cities
        weatherApi.bulkRequestForecasts(cities: cities, downloadBulkCompleted: { result in
            
            guard let _result = result else {
                debugPrint("Something went wrong")
                return
            }
            
            for (index, city) in cities.enumerated() {
                let url = self.weatherApi.getURLFormatted(city: city)
                if let forecasts = _result[url] {
                    _cities[index].forecasts = forecasts
                }
            }
            callback(_cities)
        })
    } 

    public func getCities(){
        let moc = persistence.getContext()
        moc.performAndWait {
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            do {
                let citiesMO = try moc.fetch(fetchRequest)
                var cities: [City] = []
                
                citiesMO.forEach({ (cityMO) in
                    let city = City(mo:cityMO)
                    cities.append(city)
                })
                
                self.delegate.update(withCities:cities)
            } catch let error as NSError {
                debugPrint("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    public func getMO(fromCity city: City) -> NSManagedObject? {
        let moc = persistence.getContext()
        var cityMO : NSManagedObject?
        moc.performAndWait {
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            
            var subPredicates : [NSPredicate] = []
            let subPredicate1 = NSPredicate(format: "name == %@", city.name!)
            let subPredicate2 = NSPredicate(format: "state == %@", city.state!)
            let subPredicate3 = NSPredicate(format: "country == %@", city.country!)
            subPredicates.append(subPredicate1)
            subPredicates.append(subPredicate2)
            subPredicates.append(subPredicate3)
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
            
            do {
                let citiesMO = try moc.fetch(fetchRequest)
                debugPrint("Core Data fetched!")
                cityMO = citiesMO[0]
            } catch let error as NSError  {
                debugPrint("Could not fetch \(error), \(error.userInfo)")
            }
        }
        return cityMO
    }
    
    public func delete(city: City) {
        let moc = persistence.getContext()
        moc.performAndWait {
            if let cityMO = self.getMO(fromCity: city) {
                do {
                    moc.delete(cityMO)
                    print("Core Data deleted!")
                    try moc.save()
                    print("Core Data saved!")
                    self.getCities()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
        }
    }
}
