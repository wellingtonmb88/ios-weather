//
//  ForecastViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 28/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import CoreData

protocol ForecastViewModelDelegate {
    func update(withForecasts forecasts: [Forecast])
    func showMessage(withError error: NetError)
}

struct ForecastViewModel {
    
    let delegate : ForecastViewModelDelegate
    let city: City
     
    init(city: City, delegate: ForecastViewModelDelegate){
        self.delegate = delegate
        self.city = city
    }
    
    public func getForecasts(){
        WeatherApi.sharedInstance.requestForecasts(city:city.name!, state: city.state!) {
            (forecasts, error) in
            
            if let netError = error as? NetError{
                self.delegate.showMessage(withError: netError)
                return
            }
            
            DispatchQueue.main.async {
                self.delegate.update(withForecasts: forecasts!)
            }
        }
    }
}
