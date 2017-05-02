//
//  ForecastViewController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 18/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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

class ForecastViewController: UIViewController {
    
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bgGIF: UIImageView!
    
    var forecast: Forecast? 
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        date.text = forecast?.date
        weekDay.text = forecast?.day
        tempMax.text = forecast?.high
        tempMin.text = forecast?.low
        let weatherName = (forecast?.text)!
        
        switch  normalizeWeatherString(name: weatherName) {
            case ForecastIcon.clear.rawValue:
                setFont(icon: FontIcon.clear)
                break
            case ForecastIcon.sunny.rawValue:
                setFont(icon: FontIcon.clear)
                break
            case ForecastIcon.rain.rawValue:
                setFont(icon: FontIcon.rain)
                    break
            case ForecastIcon.snow.rawValue:
                setFont(icon: FontIcon.snow)
                    break
            case ForecastIcon.sleet.rawValue:
                setFont(icon: FontIcon.sleet)
                    break
            case ForecastIcon.wind.rawValue:
                setFont(icon: FontIcon.wind)
                    break
            case ForecastIcon.fog.rawValue:
                setFont(icon: FontIcon.fog)
                    break
            case ForecastIcon.cloudy.rawValue:
                setFont(icon: FontIcon.cloudy)
                    break
            case ForecastIcon.thunderstorms.rawValue:
                setFont(icon: FontIcon.thunderstorm)
                    break
            case ForecastIcon.tornado.rawValue:
                setFont(icon: FontIcon.tornado)
                    break
            default:
                break
        }
        
        if let imageGif = UIImage.gifImageWithName(name: normalizeWeatherString(name: weatherName)){
            bgGIF.image = imageGif
        }else{
            
        }
    }
    
    func setFont(icon: FontIcon){
        weather.attributedText = IconFont.string(fromIcon: icon, size: 70.0,color: UIColor.blue)
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
