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
        weather.text = weatherName
        
        if let imageGif = UIImage.gifImageWithName(name: normalizeWeatherString(name: weatherName)){
            bgGIF.image = imageGif
        }else{
            
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
        
        return name
    }
}
