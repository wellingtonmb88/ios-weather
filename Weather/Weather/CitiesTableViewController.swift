//
//  CitiesController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 18/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

class CitiesTableViewController: UITableViewController, CityViewModelDelegate {
    
    @IBOutlet weak var cityTableView: UITableView!
    
    var cities: [City] = []
    var cityViewModel : CityViewModel?
    var forecastLoaded: Bool = false
    var shouldReloadForecast: Bool = false
    var citiesToReload: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "cityCellIdentifier")
        cityViewModel = CityViewModel(delegate: self)
        cityTableView.rowHeight = UITableViewAutomaticDimension
        cityTableView.estimatedRowHeight = 50.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityViewModel?.getCities()
    }
    
    // MARK: - CityViewModelDelegate
    func update(withCities cities: [City]){
        if self.cities.count != cities.count {
            forecastLoaded = false
        }
    
        if shouldReloadForecast && forecastLoaded {
            getForecast(cities: self.citiesToReload)
        } else if !forecastLoaded {
            self.cities = cities
            getForecast(cities: cities)
        }
    }
    
    func updateTable(cities: [City]) {
        self.shouldReloadForecast = false
        self.forecastLoaded = true
        self.citiesToReload.removeAll()
        self.cities = cities
        DispatchQueue.main.async {
            self.cityTableView.reloadData()
        }
    }
    
    func getForecast(cities: [City]) {
        cityViewModel?.bulkRequestForecasts(cities: cities, callback: { (_cities) in
            for city in _cities {
                for (index, _city) in self.cities.enumerated() {
                    if _city.latitude == city.latitude {
                        self.cities[index].forecasts = city.forecasts
                    }
                }
            } 
            self.updateTable(cities: self.cities)
        }) 
    }
}

// MARK: - UITableViewDataSource
extension CitiesTableViewController {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                                                        forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cityViewModel?.delete(city: self.cities[indexPath.row])
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCellIdentifier", for: indexPath) as! CityTableViewCell
        
        let city = cities[indexPath.row]
        
        if let forecast = city.forecasts?[0] {
            let viewModel = ForecastViewModel(pageIndex: 0, forecast: forecast)
            cell.configure(withCity: city, viewModel: viewModel, isLoading: !forecastLoaded)
        } else {
            if forecastLoaded {
                shouldReloadForecast = true
                citiesToReload.append(city)
            }
            cell.configure(withCity: city, viewModel: nil, isLoading: !forecastLoaded)
        } 
        return cell
    }
    
    func showMessage(withError error: NetError) {
        let alert = UIAlertController(title: "Oooops!", message: "\(error.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {[weak self] action  in
            let _ = self?.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true)
    }
     
}

// MARK: - UITableViewDelegate
extension CitiesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let forecastPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastPageViewController") as! ForecastPageViewController
        forecastPageViewController.viewModel = ForecastPageViewModel(city: cities[indexPath.row], delegate: forecastPageViewController)
        self.navigationController?.pushViewController(forecastPageViewController, animated: true)
    }
}
