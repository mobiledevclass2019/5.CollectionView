//
//  FlickrPhotoCell.swift
//  5.CollectionView
//
//  Created by 李超逸 on 2019/12/01.
//  Copyright © 2019 李超逸. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let leftContraint = NSLayoutConstraint(
            item: self,
            attribute: .left,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .left,
            multiplier: 1,
            constant: 0
        )
        let rightContraint = NSLayoutConstraint(
            item: self,
            attribute: .right,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .right,
            multiplier: 1,
            constant: 0
        )
        let topContraint = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        let bottomContraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        self.addConstraints([leftContraint, rightContraint, topContraint, bottomContraint])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
