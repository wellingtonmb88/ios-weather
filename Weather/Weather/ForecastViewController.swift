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
  
    var city: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cityName = city?.value(forKeyPath: "name") as? String
        let cityState = city?.value(forKeyPath: "state") as? String
        let cityCountry = city?.value(forKeyPath: "country") as? String
    }
    
}
