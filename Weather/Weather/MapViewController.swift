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

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var annotations:[MKAnnotation] = []
    var resultSearchController:UISearchController?
    
    var cityState: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        setupLongPressGesture()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) { 
        let searchBar = resultSearchController!.searchBar
        searchBar.isHidden = false
    }
    
    @IBAction func saveCity(_ sender: Any) {
        presentSavedCityAlertController()
        
        let city = City(name: annotations[0].title!!,
                        state: self.cityState!,
                        country: annotations[0].subtitle!!,
                        latitude: annotations[0].coordinate.latitude,
                        longitude: annotations[0].coordinate.longitude)
        
        let viewModel = MapViewModel(city: city)
        
        viewModel.persistCity()
        self.mapView.removeAnnotations(annotations)
        annotations = []
        saveButton.isEnabled = false
    }
}

//MARK: Methods
extension MapViewController {
    
    func presentSavedCityAlertController() {
        let cityName: String = annotations[0].title! ?? ""
        let alert = UIAlertController(title: "Niceeee!", message: "\(cityName) saved successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {[weak self] action  in
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true)
    }
    
    func setupLongPressGesture() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationMark))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    func setupSearchController() {
        let locationSearchTable = storyboard?
            .instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        
        locationSearchTable.mapView = mapView
        locationSearchTable.delegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        setupSearchBar()
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    func setupSearchBar() {
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.isHidden = true
        navigationItem.titleView = resultSearchController?.searchBar
    }
    
    func addAnnotationMark(gestureRecognizer:UILongPressGestureRecognizer){
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

extension MapViewController: HandleLocationSearch {
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

