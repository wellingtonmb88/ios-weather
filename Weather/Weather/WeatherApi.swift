//
//  WeatherApi.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 24/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

class WeatherApi: NSObject {
/*
     https://query.yahooapis.com/v1/public/yql?q=select
      * from weather.forecast where u="c" AND woeid in (select woeid from geo.places(1) where text="chicago,il")&format=json 
 */
    
    private static let WeatherEndpoint = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20u=%27c%27%20AND%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27"
    
    static func requestForecasts(city:String, state: String, callback:@escaping ([Forecast]?, Error?)->()){
        if let url = NSURL(string: "\(WeatherEndpoint)\(city),\(state)%27)&format=json") {
            
            let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
            var forecasts:[Forecast] = []
            
            NetworkPovider.requestData(request: request, callback: { (data, error) -> () in
                
                if let error = error {
                    print(error)
                    callback(nil, error)
                    return
                }
                
                if let data = data as? NSData {
                    if let queryObject = Parser.parseData(rawData: data)!["query"] as? [String : AnyObject]  {
                        if let resultsObject = queryObject["results"] as? [String : AnyObject]  {
                            if let channelObject = resultsObject["channel"] as? [String : AnyObject]  {
                                if let itemObject = channelObject["item"] as? [String : AnyObject]  {
                                    if let forecastArray = itemObject["forecast"] as? [[String : AnyObject]] {
                                        
                                        for forecastJson in forecastArray {
                                            if let forecast = Forecast.withJSON(json: forecastJson) {
                                                forecasts.append(forecast)
                                            }
                                        }
                                        callback(forecasts, nil)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("nenhum json para intepretar.")
                    callback(nil, NetError.Unknown)
                }
            })
            
        } else {
            print("url inválida")
            callback(nil, NetError.Unknown)
        }
    } 
    
}
