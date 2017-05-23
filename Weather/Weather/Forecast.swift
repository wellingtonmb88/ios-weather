//
//  Forecast.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 24/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

protocol JSONParselable {
    static func withJSON(json: [String:AnyObject]) -> Self?
}

struct Forecast {
    let date: String
    let day: String
    let high: String
    let low: String
    let text: String
    
    init(date: String, day: String, high: String, low: String, text: String){
        self.date = date
        self.day = day
        self.high = high
        self.low = low
        self.text = text
    }
}

extension Forecast: JSONParselable {
    
    static func withJSON(json: [String:AnyObject]) -> Forecast? {
        
        guard let date = json["date"] as? String,
            let day = json["day"] as? String,
            let high = json["high"] as? String,
            let low = json["low"] as? String,
            let text = json["text"] as? String else {
            return nil
        }
        
        let forecast = Forecast(date: date, day: day, high: high, low: low, text: text)
        
        return forecast 
    }
}
