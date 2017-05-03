//
//  ForecastViewModel.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 02/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//


import Foundation
import UIKit

public enum ForecastIcon: String {
    case clear
    case sunny
    case rain
    case snow
    case sleet
    case wind
    case fog
    case cloudy
    case thunderstorms
    case tornado
}

struct ForecastViewModel {
    
    var forecast: Forecast!
    var pageIndex: Int
    
    init(pageIndex: Int = 0, forecast: Forecast){
        self.pageIndex = pageIndex
        self.forecast = forecast
    }
    
    func getFontIcon(fromWeather weather:String) -> NSAttributedString? {
        switch  normalizeWeatherString(name: weather) {
            case ForecastIcon.clear.rawValue:
                return getFont(fromIcon: FontIcon.clear)
            case ForecastIcon.sunny.rawValue:
                return getFont(fromIcon: FontIcon.clear)
            case ForecastIcon.rain.rawValue:
                return getFont(fromIcon: FontIcon.rain)
            case ForecastIcon.snow.rawValue:
                return getFont(fromIcon: FontIcon.snow)
            case ForecastIcon.sleet.rawValue:
               return  getFont(fromIcon: FontIcon.sleet)
            case ForecastIcon.wind.rawValue:
                return getFont(fromIcon: FontIcon.wind)
            case ForecastIcon.fog.rawValue:
                return getFont(fromIcon: FontIcon.fog)
            case ForecastIcon.cloudy.rawValue:
                return getFont(fromIcon: FontIcon.cloudy)
            case ForecastIcon.thunderstorms.rawValue:
                return getFont(fromIcon: FontIcon.thunderstorm)
            case ForecastIcon.tornado.rawValue:
                return getFont(fromIcon: FontIcon.tornado)
            default:
                return nil
        }
    }
    
    func getFont(fromIcon icon: FontIcon) -> NSAttributedString?{
        return IconFont.string(fromIcon: icon, size: 70.0, color: UIColor.blue)
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
        return name
    }
}
