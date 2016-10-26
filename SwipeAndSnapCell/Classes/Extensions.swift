//
//  Extensions.swift
//  Swipeable
//
//  Created by Ian Dundas on 25/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

extension UIView{
    var width: CGFloat{
        return bounds.size.width
    }
    var height: CGFloat{
        return bounds.size.height
    }
}

extension UIView{
    func constrainToEdgesOf(otherView: UIView, withMargin margin: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            leftAnchor.constraintEqualToAnchor(otherView.leftAnchor, constant: margin),
            rightAnchor.constraintEqualToAnchor(otherView.rightAnchor, constant: margin),
            topAnchor.constraintEqualToAnchor(otherView.topAnchor, constant: margin),
            bottomAnchor.constraintEqualToAnchor(otherView.bottomAnchor, constant: margin),
            ])
    }
}

extension UIScrollView{
    enum TravelDirection{
        case none
        case left
        case right
    }
    
    func scrollDirection(previousContentOffset: CGFloat) -> TravelDirection{
        if (previousContentOffset > contentOffset.x){
            return .right
        }
        else if (previousContentOffset < contentOffset.x){
            return .left
        }
        else{
            return .none
        }
    }
}


