//
//  ViewController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 17/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var annotations:[MKAnnotation] = []
    
    var resultSearchController:UISearchController?
    
    var cityState: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
        
        let locationSearchTable =
            storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.isHidden = true
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) { 
        let searchBar = resultSearchController!.searchBar
        searchBar.isHidden = false
    }
    
    @IBAction func saveCity(_ sender: Any) {
        let cityName: String = annotations[0].title! ?? ""
        let alert = UIAlertController(title: "Niceeee!", message: "\(cityName) saved successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {[weak self] action  in
            let _ = self?.navigationController?.popViewController(animated: true)
        })
        save()
        self.mapView.removeAnnotations(annotations)
        annotations = []
        saveButton.isEnabled = false
        self.present(alert, animated: true)
    }
    
    func save() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "CityEntity",
                                       in: managedContext)!
        
        let city = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        city.setValue(annotations[0].title!, forKeyPath: "name")
        city.setValue(cityState, forKeyPath: "state")
        city.setValue(annotations[0].subtitle!, forKeyPath: "country")
        city.setValue(annotations[0].coordinate.latitude, forKeyPath: "latitude")
        city.setValue(annotations[0].coordinate.longitude, forKeyPath: "longitude")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            self.mapView.removeAnnotations(annotations)
            annotations = []
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            let location = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                [weak self]  (placemarks, error) -> Void in
                
                guard let `self` = self else {
                    return
                }
                
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                guard let city = placeMark.locality,
                    let state = placeMark.administrativeArea,
                    let country = placeMark.country else {
                        return
                }
                
                annotation.title = city
                annotation.subtitle = country
                self.cityState = state
                self.mapView.addAnnotation(annotation)
                self.annotations.append(annotation)
                self.saveButton.isEnabled = true
            })
            
        }
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){ 
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        guard let city = placemark.locality,
            let state = placemark.administrativeArea,
            let country = placemark.country else {
                return
        }
        
        annotation.title = city
        annotation.subtitle = country
        self.cityState = state
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true) 
        self.annotations.append(annotation)
        self.saveButton.isEnabled = true
    }
}

