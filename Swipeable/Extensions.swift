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
    func constrainToEdgesOf(otherView: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: otherView.leftAnchor),
            rightAnchor.constraint(equalTo: otherView.rightAnchor),
            topAnchor.constraint(equalTo: otherView.topAnchor),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor),
            ])
    }
}

extension UIScrollView{
    enum Direction{
        case none
        case left
        case right
    }
    
    func scrollDirection(previousContentOffset: CGFloat) -> Direction{
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


