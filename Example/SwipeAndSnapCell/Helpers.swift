//
//  Helpers.swift
//  SwipeAndSnapCell
//
//  Created by Ian Dundas on 26/10/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension UIView{
    func constrainToEdgesOf(otherView: UIView, withMargin margin: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: otherView.leftAnchor, constant: margin),
            rightAnchor.constraint(equalTo: otherView.rightAnchor, constant: margin),
            topAnchor.constraint(equalTo: otherView.topAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: margin),
            ])
    }
}
