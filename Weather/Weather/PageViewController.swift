//
//  PageViewController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 25/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PageViewController: UIPageViewController, UIPageViewControllerDataSource{
    
    var activityView:UIActivityIndicatorView?
    
    var city: NSManagedObject?
    var forecasts:[Forecast] = []
    var pageControl: UIPageControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        pageControl = UIPageControl.appearance()
        pageControl?.pageIndicatorTintColor = UIColor.gray
        pageControl?.currentPageIndicatorTintColor = UIColor.black
        pageControl?.backgroundColor = UIColor.white
        
        let cityName = city?.value(forKeyPath: "name") as? String
        let cityState = city?.value(forKeyPath: "state") as? String
        navigationItem.title = "\(cityName!) - \(cityState!)"
        
        WeatherApi.sharedInstance.requestForecasts(city: cityName!, state: cityState!) { [weak self]
            (forecasts, error) in
            
            if(error != nil){
                return
            }
            
            guard let `self` = self else {
                return
            }
            
            self.forecasts = forecasts!
            self.setupPageView()
        }
    }
    
    private func setupPageView(){
        activityView?.stopAnimating()
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil) 
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pageContent: ForecastViewController = viewController as! ForecastViewController
        var index = pageContent.pageIndex
        if (index == NSNotFound) {
            return nil;
        }
        index += 1;
        if (index == forecasts.count) {
            return nil;
        }
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let pageContent: ForecastViewController = viewController as! ForecastViewController
        var index = pageContent.pageIndex
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        index -= 1;
        return getViewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        if self.forecasts.count > 0 {
            view.isUserInteractionEnabled = true
            return self.forecasts.count
        } else{
            return 1
        }
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> ForecastViewController {
        // Create a new view controller and pass suitable data.
        let forecastViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
        if self.forecasts.count > 0 {
            forecastViewController.forecast = forecasts[index]
            forecastViewController.pageIndex = index
        }else {
            let forecastView = forecastViewController.view
            //Here the spinnier is initialized
            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityView?.frame = CGRect(x: ((view.bounds.width-100)/2), y: ((view.bounds.height-100)/2), width: 100, height: 100)
            activityView?.hidesWhenStopped = true
            activityView?.startAnimating()
            forecastView?.addSubview(activityView!)
            view.isUserInteractionEnabled = false
        }
        return forecastViewController
    }

}
