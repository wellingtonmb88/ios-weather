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
    func configure(withCity city: City) {
        self.textLabel?.text = "\(city.name!) - \(city.state!) - \(city.country!)"
    }
}
