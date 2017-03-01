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
        
        let weatherText = forecast?.text.replacingOccurrences(of: " ", with: "_").lowercased()
        weather.text = weatherText
        
        
        let imageGif = UIImage.gifImageWithName(name: weatherText!)
        bgGIF.image = imageGif
    }
   

}
