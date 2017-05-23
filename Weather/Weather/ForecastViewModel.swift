//
//  ForecastViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 02/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//


import Foundation

struct ForecastViewModel {
    
    var forecast: Forecast!
    var pageIndex: Int
    
    init(pageIndex: Int = 0, forecast: Forecast){
        self.pageIndex = pageIndex
        self.forecast = forecast
    }
    
    func getWeatherUnicode(fromWeather weather:String) -> WeatherUnicode? {
        switch  normalizeWeatherString(name: weather) {
            case Weather.clear.rawValue, Weather.sunny.rawValue:
                return WeatherUnicode.clear
            case Weather.rain.rawValue:
                return WeatherUnicode.rain
            case Weather.snow.rawValue:
                return WeatherUnicode.snow
            case Weather.sleet.rawValue:
               return  WeatherUnicode.sleet
            case Weather.wind.rawValue:
                return WeatherUnicode.wind
            case Weather.fog.rawValue:
                return WeatherUnicode.fog
            case Weather.cloudy.rawValue:
                return WeatherUnicode.cloudy
            case Weather.thunderstorms.rawValue:
                return WeatherUnicode.thunderstorm
            case Weather.severe_thunderstorms.rawValue:
                return WeatherUnicode.thunderstorm
            case Weather.tornado.rawValue:
                return WeatherUnicode.tornado
            case Weather.showers.rawValue:
                return WeatherUnicode.showers
            default:
                return nil
        }
    }
    
    func normalizeWeatherString(name :String) -> String{
        var name = name
        name = name.replacingOccurrences(of: " ", with: "_").lowercased()
        name = name.replacingOccurrences(of: "scattered_", with: "")
        name = name.replacingOccurrences(of: "_(night)", with: "")
        name = name.replacingOccurrences(of: "_(day)", with: "")
        name = name.replacingOccurrences(of: "partly_", with: "")
        name = name.replacingOccurrences(of: "isolated_", with: "")
        name = name.replacingOccurrences(of: "heavy_", with: "")
        name = name.replacingOccurrences(of: "mostly_", with: "")
        name = name.replacingOccurrences(of: "mixed_", with: "")
        name = name.replacingOccurrences(of: "thundershowers", with: "severe_thunderstorms")
        return name
    }
}
