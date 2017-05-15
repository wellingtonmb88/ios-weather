//
//  CityViewCell.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 25/04/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    
    var city: City?
    
    override func awakeFromNib() {
//        activityLoading.startAnimating()
//        temperatureLabel.isHidden = true
//        weatherIcon.isHidden = true
//        cityStateLabel.isHidden = true
//        countryLabel.isHidden = true
    }
    
    func configure(withCity city: City, viewModel: ForecastViewModel?) {
//        activityLoading.startAnimating()
        
        temperatureLabel.text = ""
//        self.weatherIcon.text = ""
        
        if let _viewModel = viewModel {
            activityLoading.stopAnimating()
            let weatherName = _viewModel.forecast.text
            temperatureLabel.text = _viewModel.forecast.high
            weatherIcon.attributedText = getFont(fromUnicode: _viewModel.getWeatherUnicode(fromWeather: weatherName))
        } else {
            self.weatherIcon.text = "ERROR"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 15) { // in 15 seconds...
//                self.activityLoading.stopAnimating()
//                self.weatherIcon.text = "ERROR"
//                self.setNeedsLayout()
//            }
        }
        
        cityStateLabel.text = "\(city.name!) - \(city.state!)"
        countryLabel.text = city.country!
    }
    
    private func getFont(fromUnicode unicode: WeatherUnicode?) -> NSAttributedString?{
        guard let weatherUnicode = unicode else {
            return nil
        }
        return WeatherIconFont.string(fromUnicode: weatherUnicode, size: 20.0, color: UIColor.blue)
    }
}
