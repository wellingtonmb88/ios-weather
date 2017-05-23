
//
//  WeatherApi.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 24/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

class WeatherApi: NSObject, NetworkServiceDelegate {
/*
     https://query.yahooapis.com/v1/public/yql?q=select
      * from weather.forecast where u="c" AND woeid in (select woeid from geo.places(1) where text="chicago,il")&format=json 
 */
    private let WeatherEndpoint = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20u=%27c%27%20AND%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27"
    
    var bulkForecast = [String : [Forecast]]()
    
    var downloadCompleted: (([Forecast]?, Error?)->())? = nil
    
    func requestForecasts(city:String, state: String, callback:@escaping ([Forecast]?, Error?)->()){
       
        downloadCompleted = callback
        
        let urlString = getURLFormatted(city: city, state: state)
        
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(url: url as URL)
            NetworkService(delegate: self).requestData(request: request)
        } else {
            debugPrint("url inválida")
            callback(nil, NetError.FatalError("url inválida"))
        }
    }
    
    func bulkRequestForecasts(cities: [City], downloadBulkCompleted: @escaping ([String : [Forecast]]?)->()) {
        var requests: [NSMutableURLRequest] = []
        for city in cities {
            let urlString = getURLFormatted(city: city)
            
            if let url = NSURL(string: urlString) {
                let request = NSMutableURLRequest(url: url as URL)
                requests.append(request)
            } else {
                debugPrint("url inválida")
            }
        }
        NetworkService(delegate: self).bulkRequestData(requests: requests, downloadCallback: { finished in
            if finished && self.bulkForecast.count > 0 {
                downloadBulkCompleted(self.bulkForecast)
            } else {
                downloadBulkCompleted(nil)
            }
        })
    }
    
    func getURLFormatted(city: City) -> String {
        return getURLFormatted(city:city.name!, state: city.state!)
    }
    
    func getURLFormatted(city:String, state: String) -> String {
        let _city = city.folding(options: .diacriticInsensitive, locale: .current)
        let _state = state.folding(options: .diacriticInsensitive, locale: .current)
        let urlString = "\(WeatherEndpoint)\(_city),\(_state)%27)&format=json"
            .replacingOccurrences(of: " ", with: "%20")
        return urlString
    }
    
    //MARK: NetworkServiceDelegate
    func callback(url: String, data: AnyObject?, error: Error?) {
        if let error = error {
            debugPrint(error)
            self.downloadCompleted?(nil, error)
            return
        }
        
        guard let _data = data as? NSData else {
            debugPrint("nenhum NSData para intepretar.")
            self.downloadCompleted?(nil, NetError.Unknown)
            return
        }
        
        guard let forecasts:[Forecast] = ForecastMapper().map(data: _data) else {
            debugPrint("Error servidor!")
            self.downloadCompleted?(nil, NetError.ServerResponseError(500))
            return
        }
        
        debugPrint("forecasts count: \(forecasts.count)")
        self.bulkForecast[url] = forecasts
        self.downloadCompleted?(forecasts, nil)
    }
}
