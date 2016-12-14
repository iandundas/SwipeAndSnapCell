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

private class TouchableView:UIView{
    
    var touchesDidBegin: ((TouchableView)->())? = nil
    var touchesDidMove: ((TouchableView)->())? = nil
    var touchesDidEnd: ((TouchableView)->())? = nil
    var touchesDidCancel: ((TouchableView)->())? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesDidBegin?(self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesDidMove?(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesDidEnd?(self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesDidCancel?(self)
    }
}


open class SwipeAndSnapCell: UITableViewCell{
    
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
    
    open var didActivateCallback: ((SwipeSide)->())? = nil
    
    // Hosted View will be stretched (using AutoLayout) to fill the full dimensions of the cell. 
    open var hostedView: UIView? = nil {
        didSet{
            guard let hostedView = hostedView else {
                oldValue?.removeFromSuperview()
                return
            }
            swipeableContentView.addSubview(hostedView)
            hostedView.constrainToEdgesOf(swipeableContentView)
        }
    }
    
    open var rightButton: UIButton? = nil {
        didSet{
            guard let button = rightButton else{
                oldValue?.removeFromSuperview(); return
            }
            rightButtonContainer.addSubview(button)
            button.constrainToEdgesOf(rightButtonContainer)
            
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(SwipeAndSnapCell.didTapRightButton), for: .touchUpInside)
        }
    }
    
    open var leftButton: UIButton? = nil {
        didSet{
            guard let button = leftButton else{
                oldValue?.removeFromSuperview(); return
            }
            leftButtonContainer.addSubview(button)
            button.constrainToEdgesOf(leftButtonContainer)
            
            button.contentHorizontalAlignment = .right
            button.addTarget(self, action: #selector(SwipeAndSnapCell.didTapLeftButton), for: .touchUpInside)
        }
    }
    
    open var underBackgroundColor = UIColor(red:0.86, green:0.87, blue:0.87, alpha:1.00)
    open var overBackgroundColor = UIColor.white{
        didSet{
            self.swipeableContentView.backgroundColor = overBackgroundColor
        }
    }
    open var highlightedBackgroundColor = UIColor.lightGray
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = underBackgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    // MARK: Constants
    
    var boxWidth: CGFloat{
        return self.frame.height
    }
    
    static let DampingAmount: CGFloat = 0.15
    static let SnapAtPercentageWhenHorizontallyCompact: CGFloat = 0.44
    static let SnapAtPercentageWhenHorizontallyRegular: CGFloat = 0.2
    static let SnapAnimationDuration: TimeInterval = 0.3
    
    
    // MARK: Views
    
    fileprivate lazy var swipeableContentView: TouchableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = self.overBackgroundColor
        
        $0.touchesDidBegin = { [weak self] view in
            view.backgroundColor = self?.highlightedBackgroundColor
        }
        $0.touchesDidEnd = { [weak self] view in
            view.backgroundColor = self?.overBackgroundColor
        }
        $0.touchesDidCancel = { [weak self] view in
            view.backgroundColor = self?.overBackgroundColor
        }
        return $0
    }(TouchableView())

    fileprivate let scrollView: UIScrollView = {
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UIScrollView())
    
    fileprivate let leftButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    fileprivate let rightButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    
    // MARK: Constraints
    
    fileprivate var leftButtonContainerRightConstraint: NSLayoutConstraint? = nil
    fileprivate var rightButtonContainerLeftConstraint: NSLayoutConstraint? = nil
    
    // MARK: State
    
    fileprivate var restingContentOffset: CGPoint{
        return CGPoint(x: boxWidth, y: 0)
    }
    fileprivate var calibratedX: CGFloat{
        return abs(scrollView.contentOffset.x - restingContentOffset.x)
    }
    
    fileprivate var isBeyondSnapPoint: Bool{
        switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass){
        case (.compact, .regular): // iPhone Plus in landscape
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyRegular)
        case (.compact, .compact): // iPhone in landscape
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyRegular)
        default:
            return calibratedX >= (bounds.width * SwipeAndSnapCell.SnapAtPercentageWhenHorizontallyCompact)
        }
    }
    
    fileprivate var scrollViewDirection: UIScrollView.TravelDirection = .none
    
    fileprivate var activeSide: SwipeSide {
        let offset = (scrollView.contentOffset.x - restingContentOffset.x)
        if offset == 0 { return .none }
        else if offset < 0 { return .left }
        else { return .right }
    }
    
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var hasSnappedOut: Bool = false{
        didSet{
            if hasSnappedOut != oldValue{
                hapticGenerator.impactOccurred()
                hapticGenerator.prepare()
            }
        }
    }
    
    fileprivate func constraintForSide(_ side: SwipeSide) -> NSLayoutConstraint?{
        guard activeSide != .none else {return nil}
        return activeSide == .left ? leftButtonContainerRightConstraint : rightButtonContainerLeftConstraint
    }
    
    fileprivate func constraintForOtherSideOf(_ side: SwipeSide) -> NSLayoutConstraint?{
        guard activeSide != .none else {return nil}
        return activeSide == .left ? rightButtonContainerLeftConstraint : leftButtonContainerRightConstraint
    }
    
    // MARK: Event or Button taps
    
    fileprivate func didSwipePastSnapPoint(_ side: SwipeSide){
        didActivateCallback?(side)
    }
    
    @objc fileprivate func didTapLeftButton(){
        self.resetPosition()
        didActivateCallback?(activeSide)
    }
    
    @objc fileprivate func didTapRightButton(){
        self.resetPosition()
        didActivateCallback?(activeSide)
    }
    
    
    // MARK: Haptics
    fileprivate let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    
    // MARK: Reuse
    
    open override func prepareForReuse() {
        leftButtonContainerRightConstraint?.constant = 0
        rightButtonContainerLeftConstraint?.constant = 0
        setNeedsLayout()
        
        scrollView.contentOffset = restingContentOffset
        
        (hostedView as? Reusable)?.prepareForReuse()
        
        super.prepareForReuse()
    }
    
    // MARK: rotation

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        super.traitCollectionDidChange(previousTraitCollection)
        
        scrollView.contentSize = CGSize(width: bounds.width + (boxWidth * 2), height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    // MARK: Resetting:
    
    open func manuallyBecomeSwiped(side side: SwipeSide) {
        guard let left = leftButtonContainerRightConstraint, let right = rightButtonContainerLeftConstraint else {return}
        let timing: TimeInterval = 1.5
        
        switch side {
        case .left:
            UIView.animate(withDuration: timing) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
            mutate(left, constant: boxWidth, withAnimationDuration: timing)
            mutate(right, constant: 0, withAnimationDuration: timing)
        
        case .right:
            UIView.animate(withDuration: timing) {
                self.scrollView.contentOffset = CGPoint(x: 2*self.boxWidth, y: 0)
            }
            mutate(left, constant: 0, withAnimationDuration: timing)
            mutate(right, constant: boxWidth, withAnimationDuration: timing)
            break;
            
        default:
            resetPosition()
        }
    }
    
    open func resetPosition(){
        scrollView.setContentOffset(self.restingContentOffset, animated: true)
    }
    
    // MARK: Drawing Subviews
    
    fileprivate var hasSetupSubviews = false

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasSetupSubviews{
            hasSetupSubviews = true
            setupSubviews()
            setupGestureRecognisers()
        }
    }
    
    
    fileprivate func setupSubviews(){
        contentView.removeFromSuperview() // pah
        
        // scrollView setup:
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.constrainToEdgesOf(self)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        setNeedsLayout()
        layoutSubviews()
        
        
        // swipeableContentView setup:
        scrollView.addSubview(swipeableContentView)
        
        NSLayoutConstraint.activate([
            swipeableContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            swipeableContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            swipeableContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            swipeableContentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: boxWidth)
            ])
        
        
        // leftButtonContainer setup:
        addSubview(leftButtonContainer)
        
        NSLayoutConstraint.activate([
            leftButtonContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            leftButtonContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            leftButtonContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: boxWidth),
            leftButtonContainer.leftAnchor.constraint(lessThanOrEqualTo: scrollView.leftAnchor),
            ])
        
        leftButtonContainerRightConstraint = leftButtonContainer.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0)
        leftButtonContainerRightConstraint?.isActive = true
        
        // rightButtonContainer setup:
        addSubview(rightButtonContainer)
        
        NSLayoutConstraint.activate([
            rightButtonContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            rightButtonContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            rightButtonContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: boxWidth),
            rightButtonContainer.rightAnchor.constraint(greaterThanOrEqualTo: scrollView.rightAnchor),
            ])
        
        rightButtonContainerLeftConstraint = rightButtonContainer.leftAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0)
        rightButtonContainerLeftConstraint?.isActive = true
        
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentSize = CGSize(width: bounds.width + (boxWidth * 2), height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    fileprivate func setupGestureRecognisers(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(SwipeAndSnapCell.didTapCell))
        swipeableContentView.addGestureRecognizer(tap)
    }
    
    func didTapCell(){
        var view: UIView? = self
        while let superview = view?.superview{
            if let tableView = superview as? UITableView, let indexPath = tableView.indexPath(for: self), let delegate = tableView.delegate {
                delegate.tableView?(tableView, didSelectRowAt: indexPath)
                return
            }
            view = superview
        }
    }
}


extension SwipeAndSnapCell: UIScrollViewDelegate{
    
    fileprivate func mutate(_ layoutConstraint: NSLayoutConstraint, constant: CGFloat, withAnimationDuration: TimeInterval){
        let mutation = {
            layoutConstraint.constant = constant
            self.layoutIfNeeded()
        }
        
        if withAnimationDuration > 0 {
            UIView.animate(withDuration: withAnimationDuration, delay: 0, options: .curveEaseInOut,
                           animations: mutation, completion: nil)
        }
        else{
            mutation()
        }
    }
    
    fileprivate func mutate(_ layoutConstraint: NSLayoutConstraint, constant: CGFloat, withAnimation: Bool){
        mutate(layoutConstraint, constant: constant, withAnimationDuration: withAnimation ? SwipeAndSnapCell.SnapAnimationDuration : 0)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hapticGenerator.prepare()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            let primaryOffset = min(calibratedX, boxWidth)
            let dampedOffset: CGFloat = {
                if calibratedX > boxWidth {
                    let remaining = calibratedX - boxWidth
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
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool){
        if calibratedX < boxWidth{
            switch (activeSide, scrollViewDirection) {
                case (.left, .right):
                    DispatchQueue.main.async {
                        scrollView.setContentOffset(CGPoint(x: self.boxWidth, y: 0), animated: true)
                    }
                
                case (.right, .left):
                    DispatchQueue.main.async {
                        scrollView.setContentOffset(CGPoint(x: self.restingContentOffset.x+self.boxWidth, y: 0), animated: true)
                    }
                
                default:
                    DispatchQueue.main.async {
                        self.resetPosition()
                    }
            }
        }
        else if isBeyondSnapPoint {
            DispatchQueue.main.async {
                self.didSwipePastSnapPoint(self.activeSide)
                self.resetPosition()
            }
        }
    }
}
