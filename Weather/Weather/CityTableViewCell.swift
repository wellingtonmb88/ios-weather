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
    @IBOutlet weak var errorIcon: UIImageView!
    
    func configure(withCity city: City, viewModel: ForecastViewModel?, isLoading: Bool) {
        activityLoading.startAnimating()
        temperatureLabel.text = ""
        weatherIcon.text = ""
        errorIcon.isHidden = true
        
        if let _viewModel = viewModel {
            activityLoading.stopAnimating()
            let weatherName = _viewModel.forecast.text
            temperatureLabel.text = _viewModel.forecast.high + "º"
            weatherIcon.attributedText =
                getFont(fromUnicode: _viewModel.getWeatherUnicode(fromWeather: weatherName))
        } else if !isLoading {
            weatherIcon.text = ""
            activityLoading.stopAnimating()
            errorIcon.isHidden = false
        }
        
        cityStateLabel.text = "\(city.name!) - \(city.state!)"
        countryLabel.text = city.country!
    }
    
    private func getFont(fromUnicode unicode: WeatherUnicode?) -> NSAttributedString?{
        guard let weatherUnicode = unicode else {
            return nil
        }
        return WeatherIconFont.string(fromUnicode: weatherUnicode, size: 22.0, color: UIColor.white)
    }
}
