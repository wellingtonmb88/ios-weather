//
//  PageViewController.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 25/02/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

class ForecastPageViewController: UIPageViewController, ForecastViewModelDelegate  {
  
    var collectionView: UICollectionView!
    var city: City?
    var forecasts:[Forecast] = []
    var cellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
        setupCollectionView()
    }
    
    func update(withForecasts forecasts: [Forecast]) {
        self.forecasts = forecasts
        self.setupPageView()
    }
    
    func showMessage(withError error: NetError) {
        let alert = UIAlertController(title: "Oooops!", message: "\(error.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) {[weak self] action  in
            let _ = self?.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true)
    }
    
    func setupPagerViewLabel(_ label: UILabel, color: UIColor, fontSize: CGFloat) {
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    private func setupCollectionView() {
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame:CGRect(x: 0, y: 60, width: self.view.frame.width, height: 50), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ForecastDateCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
    }
    
    private func initialLoad() {
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController],
                                direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        let cityName = (city?.name)!
        let cityState = (city?.state)!
        navigationItem.title = "\(cityName) - \(cityState)"
        
        let viewModel = ForecastViewModel(city: city!, delegate: self)
        
        viewModel.getForecasts()
    }
    
    private func setupPageView() {
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([getViewControllerAtIndex(index: 0)] as [UIViewController],
                                direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.view.addSubview(collectionView)
    }
    
}

//MARK: UIPageViewControllerDelegate
extension ForecastPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers[0] as? ForecastViewController {
            self.cellIndex = vc.pageIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let vc = previousViewControllers[0] as? ForecastViewController {
            self.collectionView.cellForItem(at: IndexPath(item: vc.pageIndex, section: 0))?.subviews.forEach({ (view) in
                if let label = view as? UILabel {
                    setupPagerViewLabel(label, color: UIColor.black, fontSize: 15)
                }
            })
        }
        
        if completed {
            self.collectionView.selectItem(at: IndexPath(item: self.cellIndex, section: 0), animated: true,
                                           scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            self.collectionView.cellForItem(at: IndexPath(item: self.cellIndex, section: 0))?.subviews.forEach({ (view) in
                if let label = view as? UILabel {
                    setupPagerViewLabel(label, color: UIColor.blue, fontSize: 20)
                }
            })
        }
    }
}

//MARK: UIPageViewControllerDataSource
extension ForecastPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = getPageIndex(isViewControllerBefore: false, viewController: viewController)
        if index < 0 {
            return nil
        }
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = getPageIndex(isViewControllerBefore: true, viewController: viewController)
        if index < 0 {
            return nil
        }
        return getViewControllerAtIndex(index: index)
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> UIViewController {
        if self.forecasts.count > 0 {
            let forecastViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
            forecastViewController.pageIndex = index
            forecastViewController.forecast = forecasts[index]
            return forecastViewController
        } else {
            let loadingViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
            return loadingViewController
        }
    }
    
    func getPageIndex(isViewControllerBefore: Bool, viewController: UIViewController) -> Int {
        let pageContent: ForecastViewController = viewController as! ForecastViewController
        var index = pageContent.pageIndex
        
        if index == NSNotFound {
            return -1;
        }
        
        if isViewControllerBefore {
            if index == 0 {
                return -1;
            }
            index -= 1
        } else {
            index += 1
            if (index == self.forecasts.count) {
                return -1;
            }
        }
        return index
    }
}

//MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension ForecastPageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ForecastDateCollectionViewCell 
        cell.configure(withDate: self.forecasts[indexPath.row].date)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionView.cellForItem(at: IndexPath(item: self.cellIndex, section: 0))?.subviews.forEach({ (view) in
            if let label = view as? UILabel { 
                setupPagerViewLabel(label, color: UIColor.blue, fontSize: 20)
            }
        })
    }
}
