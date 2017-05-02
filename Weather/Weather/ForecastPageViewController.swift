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

class ForecastPageViewController: UIPageViewController, UIPageViewControllerDelegate,
UIPageViewControllerDataSource , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
  
    var collectionView: UICollectionView!
    var city: City?
    var forecasts:[Forecast] = []
    var cellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for v in self.view.subviews{
//            if v.isKind(of:UIScrollView.self){
//                (v as! UIScrollView).delegate = self
//            }
//        }
        
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
//        let pageControl = UIPageControl.appearance()
//        pageControl.pageIndicatorTintColor = UIColor.gray
//        pageControl.currentPageIndicatorTintColor = UIColor.black
//        pageControl.backgroundColor = UIColor.white
        
        let cityName = (city?.name)!
        let cityState = (city?.state)!
        navigationItem.title = "\(cityName) - \(cityState)"
        
        WeatherApi.sharedInstance.requestForecasts(city:cityName, state: cityState) { [weak self]
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
            
            DispatchQueue.main.async {
                self.setupPageView()
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 15
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame:CGRect(x: 0, y: 60, width: self.view.frame.width, height: 50), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
    }
    
    private func setupPageView(){
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.view.addSubview(collectionView)
        
        let visualEffectViewLeft = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        visualEffectViewLeft.frame = CGRect(x: 0, y: 60, width: 50, height: 50)
        
        let visualEffectViewRight = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        visualEffectViewRight.frame = CGRect(x: self.view.bounds.width - 50, y: 60, width: 50, height: 50)
        
//        self.view.addSubview(visualEffectViewLeft)
//        self.view.addSubview(visualEffectViewRight)
        
//        [YourLabel.layer addSublayer:rightGradient];
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
    
    
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        if self.forecasts.count > 0 {
//            view.isUserInteractionEnabled = true
//        }
//        return self.forecasts.count
//    }
//    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
    
    func getViewControllerAtIndex(index: NSInteger) -> UIViewController {
        if self.forecasts.count > 0 {
            let forecastViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
            forecastViewController.pageIndex = index
            forecastViewController.forecast = forecasts[index]
            return forecastViewController
        } else {
            let loadingViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
//            view.isUserInteractionEnabled = false
            return loadingViewController
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        if let vc = pendingViewControllers[0] as? ForecastViewController {
            self.cellIndex = vc.pageIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        
        if let vc = previousViewControllers[0] as? ForecastViewController {
            self.collectionView.cellForItem(at: IndexPath(item: vc.pageIndex, section: 0))?.subviews.forEach({ (view) in
                if let label = view as? UILabel {
                    label.textColor = UIColor.black
                    label.font = UIFont.systemFont(ofSize: 15)
                    
                    let rightGradient = CAGradientLayer();
                    rightGradient.frame = CGRect(x: 0, y: 60, width: 50, height: 50)
                    rightGradient.colors = [UIColor(red: 0, green: 0.5, blue: 1, alpha: 0), UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)]
                    rightGradient.startPoint = CGPoint(x: 0.8, y: 0.9)
                    rightGradient.endPoint = CGPoint(x: 1.0, y: 0.9)
                    
                    label.layoutSublayers(of: rightGradient)
                }
            })
        }
        
        if completed {
                self.collectionView.selectItem(at: IndexPath(item: self.cellIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            self.collectionView.cellForItem(at: IndexPath(item: self.cellIndex, section: 0))?.subviews.forEach({ (view) in
                if let label = view as? UILabel {
                    label.textColor = UIColor.blue
                    label.font = UIFont.systemFont(ofSize: 20)
                }
            })
        }
    }

}

//UIPageViewController
extension ForecastPageViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
//        self.collectionView?.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: self.collectionView.contentOffset.y), animated: true)
        //scroll to next cell
//        CGPoint(x: scrollView.contentOffset.x + 120, y: self.collectionView.contentOffset.y)
//        self.collectionView.scrollRectToVisible(
//            CGRect(x: scrollView.contentOffset.x + 120, y: self.collectionView.contentOffset.y,
//                   width: self.collectionView.frame.width, height: self.collectionView.frame.height), animated: true);

    }
    
}


//UICollectionView
extension ForecastPageViewController {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftInset = (self.view.frame.width - 120) / 2;
        return UIEdgeInsetsMake(0, leftInset, 0, leftInset)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.clear
        
        cell.subviews.forEach{$0.removeFromSuperview()}
        let label = UILabel(frame: cell.contentView.frame)
        label.text = "\(self.forecasts[indexPath.row].date)"
        
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
       
        label.textAlignment = .center
        cell.addSubview(label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionView.cellForItem(at: IndexPath(item: self.cellIndex, section: 0))?.subviews.forEach({ (view) in
            if let label = view as? UILabel {
                label.textColor = UIColor.blue
                label.font = UIFont.systemFont(ofSize: 20)
            }
        })
    }
}
