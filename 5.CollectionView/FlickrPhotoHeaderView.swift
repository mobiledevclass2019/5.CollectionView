//
//  FlickrPhotoHeaderView.swift
//  5.CollectionView
//
//  Created by 李超逸 on 2019/12/01.
//  Copyright © 2019 李超逸. All rights reserved.
//

import UIKit

class FlickrPhotoHeaderView: UICollectionReusableView {
    var label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        addSubview(label)
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: label,
            attribute: .centerX,
            multiplier: 1,
            constant: 0)
        let centerYConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: label,
            attribute: .centerY,
            multiplier: 1,
            constant: 0)
        addConstraints([centerXConstraint, centerYConstraint])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
