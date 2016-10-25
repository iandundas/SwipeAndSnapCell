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
        
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: otherView.leftAnchor, constant: margin),
            rightAnchor.constraint(equalTo: otherView.rightAnchor, constant: margin),
            topAnchor.constraint(equalTo: otherView.topAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: margin),
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


