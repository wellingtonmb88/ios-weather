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

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var city: NSManagedObject?
    var forecasts:[Forecast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white
        
        let cityName = city?.value(forKeyPath: "name") as? String
        let cityState = city?.value(forKeyPath: "state") as? String
        navigationItem.title = "\(cityName!) - \(cityState!)"
        
        WeatherApi.sharedInstance.requestForecasts(city: cityName!, state: cityState!) { [weak self]
            (forecasts, error) in
            
            if let netError = error as? NetError{
                let alert = UIAlertController(title: "Oooops!", message: "\(netError.description)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) {[weak self] action  in
                    let _ = self?.navigationController?.popViewController(animated: true)
                })
                self?.present(alert, animated: true)
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
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.dataSource = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pageContent: ForecastViewController = viewController as! ForecastViewController
        var index = pageContent.pageIndex
        if (index == NSNotFound) {
            return nil;
        }
        index += 1;
        if (index == self.forecasts.count) {
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
        }
        return self.forecasts.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> UIViewController {
        if self.forecasts.count > 0 {
            let forecastViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
            forecastViewController.pageIndex = index
            forecastViewController.forecast = forecasts[index]
            return forecastViewController
        } else {
            let loadingViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
            view.isUserInteractionEnabled = false
            return loadingViewController
        }
    }

}
