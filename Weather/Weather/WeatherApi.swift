
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
    
    private let networkService: NetworkService? = nil
    
    var dictForecast = [String : [Forecast]]()
    
    var downloadCompleted: (([Forecast]?, Error?)->())? = nil
    
    func requestForecasts(city:String, state: String, callback:@escaping ([Forecast]?, Error?)->()){
       
        downloadCompleted = callback
        
        let _city = city.folding(options: .diacriticInsensitive, locale: .current)
        let _state = state.folding(options: .diacriticInsensitive, locale: .current)
        let urlString = "\(WeatherEndpoint)\(_city),\(_state)%27)&format=json"
                                                                    .replacingOccurrences(of: " ", with: "%20")
        if let url = NSURL(string: urlString) {
            let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
            NetworkService(delegate: self).requestData(request: request)
        } else {
            print("url inválida")
            callback(nil, NetError.Unknown)
        }
    }
    
    func bulkRequestForecasts(cities: [City], downloadCallback: @escaping ([String : [Forecast]]?)->()) {
        var requests: [NSMutableURLRequest] = []
        for city in cities {
            let urlString = getURLFormatted(city: city)
            
            if let url = NSURL(string: urlString) {
                let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
                requests.append(request)
            } else {
                print("url inválida") 
            }
        }
        NetworkService(delegate: self).bulkRequestData(requests: requests, downloadCallback: { finished in
            if finished && self.dictForecast.count > 0 {
                downloadCallback(self.dictForecast)
            } else {
                downloadCallback(nil)
            }
        })
    }
    
    func cancel(){
        networkService?.cancel()
    }
    
    func getURLFormatted(city: City) -> String {
        let _city = city.name!.folding(options: .diacriticInsensitive, locale: .current)
        let _state = city.state!.folding(options: .diacriticInsensitive, locale: .current)
        let urlString = "\(WeatherEndpoint)\(_city),\(_state)%27)&format=json"
            .replacingOccurrences(of: " ", with: "%20")
        
        return urlString
    }
    
    //MARK: NetworkServiceDelegate
    func callback(url: String, data: AnyObject?, error: Error?) {
//        print("callback called: \(url)")
//        DispatchQueue.global(qos: .background).async {
        if let error = error {
            print(error)
            self.downloadCompleted?(nil, error)
            return
        }
        
        guard let _data = data as? NSData else {
            print("nenhum json para intepretar.")
            self.downloadCompleted?(nil, NetError.Unknown)
            return
        }
                
        guard let queryObject = Parser().parseData(rawData: _data)?["query"] as? [String : AnyObject] else {
            print("error parsing \"query\"")
            return
        }
        
        guard let resultsObject = queryObject["results"] as? [String : AnyObject] else {
            print("error parsing \"results\"")
            return
        }
        
        guard let channelObject = resultsObject["channel"] as? [String : AnyObject] else {
            print("error parsing \"channel\"")
            return
        }
        
        guard let itemObject = channelObject["item"] as? [String : AnyObject] else {
            print("error parsing \"item\"")
            return
        }
        
        guard let forecastArray = itemObject["forecast"] as? [[String : AnyObject]] else {
            print("error parsing \"forecast\"")
            return
        }
        
        var forecasts:[Forecast] = []
        
        for forecastJson in forecastArray {
            if let forecast = Forecast.withJSON(json: forecastJson) {
                forecasts.append(forecast)
            }
        }
        
        print("forecasts count: \(forecasts.count)")
        self.dictForecast[url] = forecasts
        self.downloadCompleted?(forecasts, nil)
        
//        }
    }
}
