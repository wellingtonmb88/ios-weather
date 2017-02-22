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
    @IBOutlet weak var saveCity: UIButton!
    
    var annotations:[MKAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveCity.isHidden = true
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    @IBAction func saveCity(_ sender: UIButton) {
        save()
        self.mapView.removeAnnotations(annotations)
        annotations = []
        saveCity.isHidden = true
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
                
                guard let city = placeMark.addressDictionary!["City"] as? String,
                    let country = placeMark.addressDictionary!["Country"] as? String else {
                        return
                }
                
                annotation.title = city
                annotation.subtitle = country
                self.mapView.addAnnotation(annotation)
                self.annotations.append(annotation)
                self.saveCity.isHidden = false
            })
            
        }
    }
}

