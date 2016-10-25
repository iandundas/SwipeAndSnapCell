//
//  SwipeableCell.swift
//  Swipeable
//
//  Created by Ian Dundas on 25/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

class SwipeableCell: UITableViewCell{
    
    // MARK: Constants
    
    static let id: String = "Cell"
    static let BoxWidth: CGFloat = 75
    static let DampingAmount: CGFloat = 0.15
    static let SnapAtPercentage: CGFloat = 0.44
    static let SnapAnimationDuration: TimeInterval = 0.4
    
    
    // MARK: Views
    
    let swipeableContentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.white
        return $0
    }(UIView())

    fileprivate let scrollView: UIScrollView = {
        $0.backgroundColor = UIColor(red:0.16, green:0.58, blue:0.87, alpha:1.00)
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UIScrollView())
    
    fileprivate let leftButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.purple
        return $0
    }(UIView())
    
    fileprivate let leftButton: UIButton = {
        $0.backgroundColor = UIColor.red
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .custom))
    
    
    // MARK: Constraints
    
    var boxRightConstraint: NSLayoutConstraint! = nil
    
    
    // MARK: Event or Button taps
    
    var successCallback: (()->())? = {
        print("Success!")
    }
    
    func didSwipePastSnapPoint(){
        successCallback?()
    }
    
    func didTapButton(){
        successCallback?()
    }
    
    
    // MARK: Drawing Subviews
    
    private var hasSetupSubviews = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasSetupSubviews{
            hasSetupSubviews = true
            setupSubviews()
        }
    }
    
    private func setupSubviews(){
        contentView.removeFromSuperview() // pah
        
        // scrollView setup:
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.constrainToEdgesOf(otherView: self)
        
        setNeedsLayout()
        layoutSubviews()
        
        
        // swipeableContentView setup:
        scrollView.addSubview(swipeableContentView)
        
        NSLayoutConstraint.activate([
            swipeableContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            swipeableContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            swipeableContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            swipeableContentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: SwipeableCell.BoxWidth)
            ])
        
        
        // leftButtonContainer setup:
        addSubview(leftButtonContainer)
        
        NSLayoutConstraint.activate([
            leftButtonContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            leftButtonContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            leftButtonContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: SwipeableCell.BoxWidth),
            leftButtonContainer.leftAnchor.constraint(lessThanOrEqualTo: scrollView.leftAnchor),
            ])
        
        boxRightConstraint = leftButtonContainer.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0)
        boxRightConstraint.isActive = true
        
        
        // button setup:
        leftButton.addTarget(self, action: #selector(SwipeableCell.didTapButton), for: .touchUpInside)
        leftButtonContainer.addSubview(leftButton)
        
        leftButton.constrainToEdgesOf(otherView: leftButtonContainer)
        
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentSize = CGSize(width: bounds.width + SwipeableCell.BoxWidth, height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    
    fileprivate var restingContentOffset: CGPoint{
        return CGPoint(x: SwipeableCell.BoxWidth, y: 0)
    }
    fileprivate var calibratedX: CGFloat{
        return -1 * (scrollView.contentOffset.x - restingContentOffset.x)
    }
    fileprivate var isBeyondSnapPoint: Bool{
        return calibratedX >= (bounds.width * SwipeableCell.SnapAtPercentage)
    }
    
    fileprivate var scrollViewDirection: UIScrollView.Direction = .none
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var hasSnappedOut: Bool = false
}


extension SwipeableCell: UIScrollViewDelegate{
    
    private func mutate(layoutConstraint: NSLayoutConstraint, constant: CGFloat, withAnimation: Bool){
        let mutation = {
            layoutConstraint.constant = constant
            self.layoutIfNeeded()
        }
        if withAnimation{
            UIView.animate(withDuration: SwipeableCell.SnapAnimationDuration, delay: 0, options: .curveEaseInOut,
                           animations: mutation, completion: nil)
        }
        else{
            mutation()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDirection = scrollView.scrollDirection(previousContentOffset: lastContentOffset)
        lastContentOffset = scrollView.contentOffset.x
        
        if isBeyondSnapPoint {
            mutate(layoutConstraint: leftButtonContainerRightConstraint, constant: calibratedX, withAnimation: !hasSnappedOut)
            hasSnappedOut = true
        }
        else{
            
            let primaryOffset = min(calibratedX, SwipeableCell.BoxWidth)
            var dampedOffset: CGFloat = 0
            
            if calibratedX > SwipeableCell.BoxWidth {
                let remaining = calibratedX - SwipeableCell.BoxWidth
                dampedOffset = remaining * SwipeableCell.DampingAmount
            }
            
            let totalOffset = primaryOffset + dampedOffset
            
            mutate(layoutConstraint: leftButtonContainerRightConstraint, constant: totalOffset, withAnimation: hasSnappedOut)
            hasSnappedOut = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool){
        if calibratedX < SwipeableCell.BoxWidth{
            switch scrollViewDirection{
            case .right:
                DispatchQueue.main.async {
                    scrollView.setContentOffset(CGPoint(x: SwipeableCell.BoxWidth, y: 0), animated: true)
                }
            default:
                DispatchQueue.main.async {
                    scrollView.setContentOffset(self.restingContentOffset, animated: true)
                }
            }
        }
        else if isBeyondSnapPoint {
            DispatchQueue.main.async {
                self.didSwipePastSnapPoint()
                self.scrollView.setContentOffset(self.restingContentOffset, animated: true)
            }
        }
    }
}
