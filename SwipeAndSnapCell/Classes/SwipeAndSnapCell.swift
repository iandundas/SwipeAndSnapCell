//
//  SwipeAndSnapCell.swift
//  Swipeable
//
//  Created by Ian Dundas on 25/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

public protocol Reusable{
    func prepareForReuse()
}

public class SwipeAndSnapCell: UITableViewCell{
    
    public enum SwipeSide{
        case none
        case left
        case right
        
        var description: String{
            switch self{
            case .none: return "centered"
            case .left: return "left"
            case .right: return "right"
            }
        }
    }
    
    public var didActivateCallback: ((SwipeSide)->())? = nil
    
    // Hosted View will be stretched (using AutoLayout) to fill the full dimensions of the cell. 
    public var hostedView: UIView? = nil {
        didSet{
            guard let hostedView = hostedView else {
                oldValue?.removeFromSuperview()
                return
            }
            swipeableContentView.addSubview(hostedView)
            hostedView.constrainToEdgesOf(swipeableContentView)
        }
    }
    
    public var rightButton: UIButton? = nil {
        didSet{
            guard let button = rightButton else{
                oldValue?.removeFromSuperview(); return
            }
            rightButtonContainer.addSubview(button)
            button.constrainToEdgesOf(rightButtonContainer)
            
            button.contentHorizontalAlignment = .Left
            button.addTarget(self, action: #selector(SwipeAndSnapCell.didTapRightButton), forControlEvents: .TouchUpInside)
        }
    }
    
    public var leftButton: UIButton? = nil {
        didSet{
            guard let button = leftButton else{
                oldValue?.removeFromSuperview(); return
            }
            leftButtonContainer.addSubview(button)
            button.constrainToEdgesOf(leftButtonContainer)
            
            button.contentHorizontalAlignment = .Right
            button.addTarget(self, action: #selector(SwipeAndSnapCell.didTapLeftButton), forControlEvents: .TouchUpInside)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(red:0.86, green:0.87, blue:0.87, alpha:1.00)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    // MARK: Constants
    
    static let BoxWidth: CGFloat = 75
    static let DampingAmount: CGFloat = 0.15
    static let SnapAtPercentageWhenHorizontallyCompact: CGFloat = 0.44
    static let SnapAtPercentageWhenHorizontallyRegular: CGFloat = 0.2
    static let SnapAnimationDuration: NSTimeInterval = 0.3
    
    
    // MARK: Views
    
     let swipeableContentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.whiteColor()
        return $0
    }(UIView())

     let scrollView: UIScrollView = {
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UIScrollView())
    
     let leftButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
     let rightButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    
    // MARK: Constraints
    
     var leftButtonContainerRightConstraint: NSLayoutConstraint? = nil
     var rightButtonContainerLeftConstraint: NSLayoutConstraint? = nil
    
    // MARK: State
    
     var restingContentOffset: CGPoint{
        return CGPoint(x: SwipeAndSnapCell.BoxWidth, y: 0)
    }
     var calibratedX: CGFloat{
        return abs(scrollView.contentOffset.x - restingContentOffset.x)
    }
    
     var isBeyondSnapPoint: Bool{
        switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass){
        case (.Compact, .Regular): // iPhone Plus in landscape
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyRegular)
        case (.Compact, .Compact): // iPhone in landscape
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyRegular)
        default:
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyCompact)
        }
    }
    
     var scrollViewDirection: ScrollViewTravelDirection = .None
    
     var activeSide: SwipeSide {
        let offset = (scrollView.contentOffset.x - restingContentOffset.x)
        if offset == 0 { return .none }
        else if offset < 0 { return .left }
        else { return .right }
    }
    
     var lastContentOffset: CGFloat = 0
     var hasSnappedOut: Bool = false
    
     func constraintForSide(side: SwipeSide) -> NSLayoutConstraint?{
        guard activeSide != .none else {return nil}
        return activeSide == .left ? leftButtonContainerRightConstraint : rightButtonContainerLeftConstraint
    }
    
     func constraintForOtherSideOf(side: SwipeSide) -> NSLayoutConstraint?{
        guard activeSide != .none else {return nil}
        return activeSide == .left ? rightButtonContainerLeftConstraint : leftButtonContainerRightConstraint
    }
    
    // MARK: Event or Button taps
    
     func didSwipePastSnapPoint(side: SwipeSide){
        didActivateCallback?(side)
    }
    
    @objc  func didTapLeftButton(){
        self.resetPosition()
        didActivateCallback?(activeSide)
    }
    
    @objc  func didTapRightButton(){
        self.resetPosition()
        didActivateCallback?(activeSide)
    }
    
    // MARK: Reuse
    
    public override func prepareForReuse() {
        leftButtonContainerRightConstraint?.constant = 0
        rightButtonContainerLeftConstraint?.constant = 0
        setNeedsLayout()
        
        scrollView.contentOffset = restingContentOffset
        
        (hostedView as? Reusable)?.prepareForReuse()
        
        super.prepareForReuse()
    }
    
    // MARK: rotation

    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?){
        super.traitCollectionDidChange(previousTraitCollection)
        
        scrollView.contentSize = CGSize(width: bounds.width + (SwipeAndSnapCell.BoxWidth * 2), height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    // MARK: Resetting:
    
    public func resetPosition(){
        scrollView.setContentOffset(self.restingContentOffset, animated: true)
    }
    
    // MARK: Drawing Subviews
    
    private var hasSetupSubviews = false

    override public func layoutSubviews() {
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
        scrollView.constrainToEdgesOf(self)
        
        setNeedsLayout()
        layoutSubviews()
        
        
        // swipeableContentView setup:
        scrollView.addSubview(swipeableContentView)
        
        NSLayoutConstraint.activateConstraints([
            swipeableContentView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor),
            swipeableContentView.heightAnchor.constraintEqualToAnchor(scrollView.heightAnchor),
            swipeableContentView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor),
            swipeableContentView.leftAnchor.constraintEqualToAnchor(scrollView.leftAnchor, constant: SwipeAndSnapCell.BoxWidth)
            ])
        
        
        // leftButtonContainer setup:
        addSubview(leftButtonContainer)
        
        NSLayoutConstraint.activateConstraints([
            leftButtonContainer.heightAnchor.constraintEqualToAnchor(scrollView.heightAnchor),
            leftButtonContainer.topAnchor.constraintEqualToAnchor(scrollView.topAnchor),
            
            leftButtonContainer.widthAnchor.constraintGreaterThanOrEqualToConstant(SwipeAndSnapCell.BoxWidth),
            leftButtonContainer.leftAnchor.constraintLessThanOrEqualToAnchor(scrollView.leftAnchor),
            ])
        
        leftButtonContainerRightConstraint = leftButtonContainer.rightAnchor.constraintEqualToAnchor(scrollView.leftAnchor, constant: 0)
        leftButtonContainerRightConstraint?.active = true
        
        // rightButtonContainer setup:
        addSubview(rightButtonContainer)
        
        NSLayoutConstraint.activateConstraints([
            rightButtonContainer.heightAnchor.constraintEqualToAnchor(scrollView.heightAnchor),
            rightButtonContainer.topAnchor.constraintEqualToAnchor(scrollView.topAnchor),
            
            rightButtonContainer.widthAnchor.constraintGreaterThanOrEqualToConstant(SwipeAndSnapCell.BoxWidth),
            rightButtonContainer.rightAnchor.constraintGreaterThanOrEqualToAnchor(scrollView.rightAnchor),
            ])
        
        rightButtonContainerLeftConstraint = rightButtonContainer.leftAnchor.constraintEqualToAnchor(scrollView.rightAnchor, constant: 0)
        rightButtonContainerLeftConstraint?.active = true
        
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentSize = CGSize(width: bounds.width + (SwipeAndSnapCell.BoxWidth * 2), height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
}


extension SwipeAndSnapCell: UIScrollViewDelegate{
    
    private func mutate(layoutConstraint: NSLayoutConstraint, constant: CGFloat, withAnimation: Bool){
        let mutation = {
            layoutConstraint.constant = constant
            self.layoutIfNeeded()
        }
        if withAnimation{
            UIView.animateWithDuration(SwipeAndSnapCell.SnapAnimationDuration, delay: 0, options: .CurveEaseInOut,
                           animations: mutation, completion: nil)
        }
        else{
            mutation()
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollViewDirection = scrollView.scrollDirection(lastContentOffset)
        lastContentOffset = scrollView.contentOffset.x
        
        guard let constraint = constraintForSide(activeSide), let otherConstraint = constraintForOtherSideOf(activeSide) else {
            // The last pass fires when contentOffset back to normal, but we haven't fully applied it to the buttons yet. Do it here:
            self.leftButtonContainerRightConstraint?.constant = 0
            self.rightButtonContainerLeftConstraint?.constant = 0
            self.layoutIfNeeded()
            return
        }
        
        let inverter: CGFloat = activeSide == .left ? 1 : -1
        
        if isBeyondSnapPoint {
            mutate(constraint, constant: calibratedX * inverter, withAnimation: !hasSnappedOut)
            mutate(otherConstraint, constant: 0, withAnimation: false)
            hasSnappedOut = true
        }
        else{
            let primaryOffset = min(calibratedX, SwipeAndSnapCell.BoxWidth)
            let dampedOffset: CGFloat = {
                if calibratedX > SwipeAndSnapCell.BoxWidth {
                    let remaining = calibratedX - SwipeAndSnapCell.BoxWidth
                    return remaining * SwipeAndSnapCell.DampingAmount
                }
                return 0
            }()
            let totalOffset = primaryOffset + dampedOffset
            
            mutate(constraint, constant: totalOffset * inverter, withAnimation: hasSnappedOut)
            mutate(otherConstraint, constant: 0, withAnimation: false)
            hasSnappedOut = false
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool){
        if calibratedX < SwipeAndSnapCell.BoxWidth{
            switch (activeSide, scrollViewDirection) {
                case (.left, .Right):
                    dispatch_async(dispatch_get_main_queue()) {
                        scrollView.setContentOffset(CGPoint(x: SwipeAndSnapCell.BoxWidth, y: 0), animated: true)
                    }
                
                case (.right, .Left):
                    dispatch_async(dispatch_get_main_queue()){
                        scrollView.setContentOffset(CGPoint(x: self.restingContentOffset.x+SwipeAndSnapCell.BoxWidth, y: 0), animated: true)
                    }
                
                default:
                    dispatch_async(dispatch_get_main_queue()){
                        self.resetPosition()
                    }
            }
        }
        else if isBeyondSnapPoint {
            dispatch_async(dispatch_get_main_queue()) {
                self.didSwipePastSnapPoint(self.activeSide)
                self.resetPosition()
            }
        }
    }
}
