//
//  ForecastMapper.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 16/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

struct ForecastMapper {
    
    func map(data: NSData) -> [Forecast]? {
        
        guard let queryObject = Parser().parseData(rawData: data)?["query"] as? [String : AnyObject] else {
            debugPrint("error parsing \"query\"")
            return nil
        }
        
        guard let resultsObject = queryObject["results"] as? [String : AnyObject] else {
            debugPrint("error parsing \"results\"")
            return nil
        }
        
        guard let channelObject = resultsObject["channel"] as? [String : AnyObject] else {
            debugPrint("error parsing \"channel\"")
            return nil
        }
        
        guard let itemObject = channelObject["item"] as? [String : AnyObject] else {
            debugPrint("error parsing \"item\"")
            return nil
        }
        
        guard let forecastArray = itemObject["forecast"] as? [[String : AnyObject]] else {
            debugPrint("error parsing \"forecast\"")
            return nil
        }
        
        var forecasts:[Forecast] = []
        
        for forecastJson in forecastArray {
            if let forecast = Forecast.withJSON(json: forecastJson) {
                forecasts.append(forecast)
            }
        }
        
        return forecasts
    }
    
}
