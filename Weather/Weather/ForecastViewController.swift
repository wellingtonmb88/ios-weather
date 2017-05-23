//
//  ForecastViewController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 18/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

class ForecastViewController: UIViewController {
    
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bgGIF: UIImageView!
    
    var viewModel: ForecastViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewModel = self.viewModel{
            date.text = viewModel.forecast.date
            tempMax.text = viewModel.forecast.high + "º"
            tempMin.text = viewModel.forecast.low + "º"
            let weatherName = viewModel.forecast.text
            
            weather.attributedText = getFont(fromUnicode: viewModel.getWeatherUnicode(fromWeather: weatherName))
            
            if let imageGif = UIImage.gifImageWithName(name: viewModel.normalizeWeatherString(name: weatherName)){
                bgGIF.image = imageGif
            }
        }
    }
    
    private func getFont(fromUnicode unicode: WeatherUnicode?) -> NSAttributedString?{
        guard let weatherUnicode = unicode else {
            return nil
        }
        return WeatherIconFont.string(fromUnicode: weatherUnicode, size: 100.0, color: UIColor.blue)
    }
}
