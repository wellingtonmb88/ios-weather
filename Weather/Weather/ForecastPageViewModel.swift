//
//  ForecastViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 28/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

protocol ForecastPageViewModelDelegate {
    func update(withForecasts forecasts: [Forecast])
    func showMessage(withError error: NetError)
}

struct ForecastPageViewModel {
    
    let delegate : ForecastPageViewModelDelegate
    let city: City
    let weatherApi = WeatherApi()
    
    init(city: City, delegate: ForecastPageViewModelDelegate){
        self.delegate = delegate
        self.city = city
    }
    
    public func getForecasts(){
        weatherApi.requestForecasts(city:city.name!, state: city.state!) {
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
    
    public func cancelForecastRequest(){
        weatherApi.cancel()
    }
}
