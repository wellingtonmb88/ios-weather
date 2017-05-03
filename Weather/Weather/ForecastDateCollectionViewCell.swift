//
//  CollectionViewCell.swift
//  Weather
//
//  Created by WELLINGTON BARBOSA on 02/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation
import UIKit

class ForecastDateCollectionViewCell: UICollectionViewCell {
    func configure(withDate date: String) {
        self.backgroundColor = UIColor.clear
        
        self.subviews.forEach{$0.removeFromSuperview()}
        let label = UILabel(frame: self.contentView.frame)
        label.text = "\(date)"
        
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        
        label.textAlignment = .center
        self.addSubview(label)
    }
}
