//
//  ViewController.swift
//  Swipeable
//
//  Created by Ian Dundas on 24/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.id) as! Cell
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
class TableViewDelegate: NSObject, UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

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

class Cell: UITableViewCell{
    
    // MARK: Constants
    
    static let id: String = "Cell"
    static let BoxWidth: CGFloat = 75
    static let DampingAmount: CGFloat = 0.15
    static let SnapAtPercentage: CGFloat = 0.44
    static let SnapAnimationDuration: TimeInterval = 0.4
    
    // MARK: Views
    
    let scrollView: UIScrollView = {
        $0.backgroundColor = UIColor(red:0.16, green:0.58, blue:0.87, alpha:1.00)
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UIScrollView())
    
    let swipeableContentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.white
        return $0
    }(UIView())
    
    let leftButtonContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.purple
        return $0
    }(UIView())
    
    let leftButton: UIButton = {
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
            swipeableContentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Cell.BoxWidth)
            ])
        
        
        // leftButtonContainer setup:
        addSubview(leftButtonContainer)
        
        NSLayoutConstraint.activate([
            leftButtonContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            leftButtonContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            leftButtonContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: Cell.BoxWidth),
            leftButtonContainer.leftAnchor.constraint(lessThanOrEqualTo: scrollView.leftAnchor),
            ])
        
        boxRightConstraint = leftButtonContainer.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0)
        boxRightConstraint.isActive = true
        
        
        // button setup:
        leftButton.addTarget(self, action: #selector(Cell.didTapButton), for: .touchUpInside)
        leftButtonContainer.addSubview(leftButton)
        
        leftButton.constrainToEdgesOf(otherView: leftButtonContainer)
        
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentSize = CGSize(width: bounds.width + Cell.BoxWidth, height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    
    fileprivate var restingContentOffset: CGPoint{
        return CGPoint(x: Cell.BoxWidth, y: 0)
    }
    fileprivate var calibratedX: CGFloat{
        return -1 * (scrollView.contentOffset.x - restingContentOffset.x)
    }
    fileprivate var isBeyondSnapPoint: Bool{
        return calibratedX >= (bounds.width * Cell.SnapAtPercentage)
    }
    
    fileprivate var scrollViewDirection: UIScrollView.Direction = .none
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var hasSnappedOut: Bool = false
}


extension Cell: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDirection = scrollView.scrollDirection(previousContentOffset: lastContentOffset)
        lastContentOffset = scrollView.contentOffset.x
        
        if isBeyondSnapPoint {
            let mutation = {
                self.boxRightConstraint.constant = self.calibratedX
                self.layoutIfNeeded()
            }
            
            if !hasSnappedOut{
                hasSnappedOut = true
                UIView.animate(withDuration: Cell.SnapAnimationDuration, delay: 0, options: .curveEaseInOut,
                               animations: mutation, completion: nil)
            }
            else{
                mutation()
            }
        }
        else{
            
            let primaryOffset = min(calibratedX, Cell.BoxWidth)
            var dampedOffset: CGFloat = 0
            
            if calibratedX > Cell.BoxWidth {
                let remaining = calibratedX - Cell.BoxWidth
                dampedOffset = remaining * Cell.DampingAmount
            }
            
            let totalOffset = primaryOffset + dampedOffset
            
            let mutation = {
                self.boxRightConstraint.constant = totalOffset
                self.layoutIfNeeded()
            }
            
            if hasSnappedOut{
                hasSnappedOut = false
                UIView.animate(withDuration: Cell.SnapAnimationDuration, delay: 0, options: .curveEaseInOut,
                               animations: mutation, completion: nil)
            }
            else{
                mutation()
            }

        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool){
        if calibratedX < Cell.BoxWidth{
            switch scrollViewDirection{
            case .right:
                DispatchQueue.main.async {
                    scrollView.setContentOffset(CGPoint(x: Cell.BoxWidth, y: 0), animated: true)
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

class ViewController: UITableViewController {
    
    let tableViewDelegate = TableViewDelegate()
    let tableViewDataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.id)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
    }
}

