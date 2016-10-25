////
////  Helpers.swift
////  Swipeable
////
////  Created by Ian Dundas on 24/10/2016.
////  Copyright © 2016 IanDundas. All rights reserved.
////
//
//import UIKit
//
//import UIKit
//
//extension UIView {
//    public func constrainEqual(attribute: NSLayoutAttribute, to: AnyObject, multiplier: CGFloat = 1, constant: CGFloat = 0) {
//        constrainEqual(attribute: attribute, to: to, attribute: attribute, multiplier: multiplier, constant: constant)
//    }
//    
//    public func constrainEqual(attribute: NSLayoutAttribute, to: AnyObject, attribute toAttribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
//            ])
//    }
//    
//    public func constrainEdges(to view: UIView) {
//        constrainEqual(attribute: .top, to: view, attribute: .top)
//        constrainEqual(attribute: .leading, to: view, attribute: .leading)
//        constrainEqual(attribute: .trailing, to: view, attribute: .trailing)
//        constrainEqual(attribute: .bottom, to: view, attribute: .bottom)
//    }
//    
//    /// If the `view` is nil, we take the superview.
//    public func center(in view: UIView? = nil) {
//        guard let container = view ?? self.superview else { fatalError() }
//        centerXAnchor.constrainEqual(anchor: container.centerXAnchor)
//        centerYAnchor.constrainEqual(anchor: container.centerYAnchor)
//    }
//}
//
//extension NSLayoutAnchor {
//    public func constrainEqual(anchor: NSLayoutAnchor, constant: CGFloat = 0) {
//        let c = constraint(equalTo: anchor, constant: constant)
//        c.isActive = true
//    }
//}
