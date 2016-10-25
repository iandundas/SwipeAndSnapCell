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
        //        cell.textLabel?.text = "Working"
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
    func constraintToEdgesOf(otherView: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: otherView.leftAnchor),
            rightAnchor.constraint(equalTo: otherView.rightAnchor),
            topAnchor.constraint(equalTo: otherView.topAnchor),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor),
            ])
    }
}

enum ScrollViewDirection{
    case none
    case left
    case right
}

class Cell: UITableViewCell{
    static let id: String = "Cell"
    static let BoxWidth: CGFloat = 75
    static let DampingAmount: CGFloat = 0.15
    static let SnapAtPercentage: CGFloat = 0.44
    static let SnapAnimationDuration: TimeInterval = 0.4
    
    let scrollView: UIScrollView = {
        $0.backgroundColor = UIColor(red:0.16, green:0.58, blue:0.87, alpha:1.00)
        $0.showsHorizontalScrollIndicator = false
        return $0
    }(UIScrollView())
    
    // Views:
    let betterContentView = UIView()
    let leftBox = UIView()
    
    // Constraints:
    var boxRightConstraint: NSLayoutConstraint! = nil
    
    required init?(coder aDecoder: NSCoder){ super.init(coder: aDecoder)}
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.removeFromSuperview()
    }
    
    
    private var hasLaidOutFirstTime = false
    override func layoutSubviews() {
        super.layoutSubviews()
        // whatever
        
        guard hasLaidOutFirstTime == false else {return}
        hasLaidOutFirstTime = true
        
        // ScrollView setup:
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.constraintToEdgesOf(otherView: self)
        
        setNeedsLayout()
        layoutSubviews()
        
        // betterContentView setup:
        scrollView.addSubview(betterContentView)
        betterContentView.translatesAutoresizingMaskIntoConstraints = false
        betterContentView.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activate([
            betterContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            betterContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            betterContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            betterContentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Cell.BoxWidth)
            
            ])
        
        
        // leftBox setup:
        addSubview(leftBox)
        leftBox.translatesAutoresizingMaskIntoConstraints = false
        leftBox.backgroundColor = UIColor.purple
        
        NSLayoutConstraint.activate([
            leftBox.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            leftBox.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            leftBox.widthAnchor.constraint(greaterThanOrEqualToConstant: Cell.BoxWidth),
            leftBox.leftAnchor.constraint(lessThanOrEqualTo: scrollView.leftAnchor),
            ])
        
        boxRightConstraint = leftBox.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0)
        boxRightConstraint.isActive = true
        
        
        // add button into the box:
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: Selector("didTapButton"), for: .touchUpInside)
        leftBox.addSubview(button)
        
        button.constraintToEdgesOf(otherView: leftBox)
  
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentSize = CGSize(width: bounds.width + Cell.BoxWidth, height: scrollView.height)
        scrollView.contentOffset = restingContentOffset
    }
    
    
    var restingContentOffset: CGPoint{
        return CGPoint(x: Cell.BoxWidth, y: 0)
    }
    var calibratedX: CGFloat{
        return -1 * (scrollView.contentOffset.x - restingContentOffset.x)
    }
    var isBeyondSnapPoint: Bool{
        let result = calibratedX >= (bounds.width * Cell.SnapAtPercentage)
        print("Is beyond: \(result): \(calibratedX) >= \(bounds.width * Cell.SnapAtPercentage)")
        return result
    }
    
    var scrollViewDirection: ScrollViewDirection = .none
    fileprivate var lastContentOffset: CGFloat = 0
    
    fileprivate var hasSnappedOut: Bool = false
    
    
    var selectedDev = false
    
    func didTapButton(){
        print("TAP")
    }
}


extension Cell: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (lastContentOffset > scrollView.contentOffset.x){
            scrollViewDirection = .right
        }
        else if (lastContentOffset < scrollView.contentOffset.x){
            scrollViewDirection = .left
        }
        else{
            scrollViewDirection = .none
        }
        
        self.lastContentOffset = scrollView.contentOffset.x;
        
        
        if !isBeyondSnapPoint {
            let primaryOffset = min(calibratedX, Cell.BoxWidth)
            var dampedOffset: CGFloat = 0
            
            if calibratedX > Cell.BoxWidth {
                // e.g. 150
                let remaining = calibratedX - Cell.BoxWidth // 50
                dampedOffset = remaining * Cell.DampingAmount
            }
            
            let totalOffset = primaryOffset + dampedOffset
            
            if hasSnappedOut{
                hasSnappedOut = false
                UIView.animate(withDuration: Cell.SnapAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    self.boxRightConstraint.constant = totalOffset
                    self.layoutIfNeeded()
                }, completion: {_ in })
            }
            else{
                self.boxRightConstraint.constant = totalOffset
                self.layoutIfNeeded()
            }
        }
        else{
            if !hasSnappedOut{
                hasSnappedOut = true
                UIView.animate(withDuration: Cell.SnapAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    self.boxRightConstraint.constant = self.calibratedX
                    self.layoutIfNeeded()
                }, completion: { _ in})
            }
            else{
                self.boxRightConstraint.constant = self.calibratedX
                self.layoutIfNeeded()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool){
        if calibratedX < Cell.BoxWidth{
            switch scrollViewDirection{
            case .right:
                scrollView.setContentOffset(CGPoint(x: Cell.BoxWidth, y: 0), animated: true)
            default:
                scrollView.setContentOffset(restingContentOffset, animated: true)
            }
        }
        else if isBeyondSnapPoint {
            if selectedDev {
                betterContentView.backgroundColor = UIColor.white
            }
            else{
                betterContentView.backgroundColor = UIColor.red
            }
            
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(self.restingContentOffset, animated: true)
            }
            selectedDev = !selectedDev
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

