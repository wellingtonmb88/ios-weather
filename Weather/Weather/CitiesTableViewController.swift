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
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        cityTableView.register(CityTableViewCell.self, forCellReuseIdentifier: "cityCellIdentifier")
        cityViewModel = CityViewModel(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityViewModel?.getCities()
        cityTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "forecastSegue" {
            if let destinationVC = segue.destination as? ForecastPageViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    destinationVC.city = cities[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - CityViewModelDelegate
    
    func update(withCities cities: [City]){
        self.cities = cities
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
        cell.configure(withCity: cities[indexPath.row])
        return cell
    } 
}

// MARK: - UITableViewDelegate
extension CitiesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "forecastSegue", sender: nil)
    }
}
