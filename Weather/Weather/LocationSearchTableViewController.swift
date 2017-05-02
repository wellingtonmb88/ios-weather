//
//  LocationSearchTable.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 22/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol HandleLocationSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationSearchTableViewController : UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView?
    var delegate:HandleLocationSearch?
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil)
            && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil
            && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@ %@ %@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // state
            selectedItem.administrativeArea ?? "",
            secondSpace,
            // country
            selectedItem.country ?? ""
        )
        return addressLine
    }
}

//MARK: UITableViewDataSource
extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCellIdentifier")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name 
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

//MARK: UITableViewDelegate
extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDelegate
extension LocationSearchTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController){
        guard let mapView = self.mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBarText
        localSearchRequest.region = mapView.region
        let search = MKLocalSearch(request: localSearchRequest)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            let filteredArray = response.mapItems.filter() { $0.phoneNumber == nil } 
            self.matchingItems = filteredArray
            self.tableView.reloadData()
        }
    } 
}
