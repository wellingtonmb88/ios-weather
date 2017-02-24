//
//  CitiesController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 18/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CitiesTableViewController: UITableViewController {
    @IBOutlet weak var cityTableView: UITableView!
    
    var cities: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        cityTableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cityCellIdentifier")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
        
        do {
            cities = try getContext().fetch(fetchRequest)
            cityTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func delete(city: NSManagedObject) {
        let moc = getContext()
        moc.delete(city)
        do {
            try moc.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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
            self.delete(city: self.cities[indexPath.row])
            self.cities.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
            
        let city = cities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCellIdentifier", for: indexPath)

        let cityName = city.value(forKeyPath: "name") as? String
        let cityCountry = city.value(forKeyPath: "country") as? String
        cell.textLabel?.text = "\(cityName!) - \(cityCountry!)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "forecastSegue", sender: nil)
    }
}
