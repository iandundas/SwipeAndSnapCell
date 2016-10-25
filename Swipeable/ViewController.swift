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
        return 100
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

class Cell: UITableViewCell{
    static let id: String = "Cell"
    
    let scrollView: UIScrollView = {
        $0.backgroundColor = UIColor(red:0.16, green:0.58, blue:0.87, alpha:1.00)
        return $0
    }(UIScrollView())
    
    
    
    let betterContentView = UIView()
    let leftBox = UIView()
    
    var interimConstraint: NSLayoutConstraint? = nil
    var holdBackConstraint: NSLayoutConstraint? = nil
    
    required init?(coder aDecoder: NSCoder){ super.init(coder: aDecoder)}
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.removeFromSuperview()
    }
    
    
    var hasLaidOutFirstTime = false
    override func layoutSubviews() {
        super.layoutSubviews()
    
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
            betterContentView.topAnchor.constraint(equalTo: scrollView.topAnchor)
            // TODO needs X
            ])
        
        
        // leftBox setup:
        scrollView.addSubview(leftBox)
        leftBox.translatesAutoresizingMaskIntoConstraints = false
        leftBox.backgroundColor = UIColor.purple
        
        NSLayoutConstraint.activate([
            leftBox.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5, constant: 0),
            leftBox.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            leftBox.topAnchor.constraint(equalTo: scrollView.topAnchor)
            // TODO needs X
            ])
        
        
        // Join Box and BetterContentView: 
        NSLayoutConstraint.activate([
            betterContentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            ])
        
        
        interimConstraint = leftBox.rightAnchor.constraint(equalTo: betterContentView.leftAnchor)
        interimConstraint?.isActive = true
        
        holdBackConstraint = leftBox.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        holdBackConstraint?.isActive = true
        
        // add inner icon box:
        let icon = UIView()
        icon.backgroundColor = UIColor.red
        icon.translatesAutoresizingMaskIntoConstraints = false
        leftBox.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.rightAnchor.constraint(equalTo: leftBox.rightAnchor, constant: -20),
            icon.topAnchor.constraint(equalTo: leftBox.topAnchor, constant: 20),
            icon.bottomAnchor.constraint(equalTo: leftBox.bottomAnchor, constant: -20),
            icon.widthAnchor.constraint(equalTo: leftBox.heightAnchor, constant: -40)
            ])
        
        scrollView.contentSize = CGSize(width: betterContentView.width + leftBox.width, height: scrollView.height)
        
        
        setNeedsLayout()
        layoutSubviews()
        
        scrollView.contentOffset = restingContentOffset
    }
    
    
    var restingContentOffset: CGPoint{
        return CGPoint(x: 375/2, y: 0)
    }
    
    var click = false
    var disable = false
}


extension Cell: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let interimConstraint = interimConstraint, let holdBackConstraint = holdBackConstraint else {return}
        guard disable == false else {return}
        print("Scrolled to offset: \(scrollView.contentOffset.x) (resting width: \(restingContentOffset.x), leftBox height: \(leftBox.height))")
        
        let excess = (restingContentOffset.x - leftBox.height) - scrollView.contentOffset.x
        if scrollView.contentOffset.x < (restingContentOffset.x - leftBox.height){
            if excess > 120{
                
                if click == false{
                    click = true
                    UIView.animate(withDuration: 0.3, animations: {
                        interimConstraint.constant = 0
                        holdBackConstraint.constant = 0
                        self.layoutIfNeeded()
                    })
                }
            }
            else {
                click = false
                interimConstraint.constant = -excess * 0.75
                holdBackConstraint.constant = -excess * 0.75
                layoutSubviews()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool){
     
        if scrollView.contentOffset.x < 80{
            disable = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.interimConstraint?.constant = 0
                self.holdBackConstraint?.constant = 0
                self.layoutIfNeeded()
                
                scrollView.contentOffset = CGPoint(x: 80, y: 0)
            }, completion: { (completed) in
                self.disable = false
            })
        }
        else if scrollView.contentOffset.x >= 80{
            disable = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.interimConstraint?.constant = 0
                self.holdBackConstraint?.constant = 0
                self.layoutIfNeeded()
                
                scrollView.contentOffset = CGPoint(x: 188.5, y: 0)
                }, completion: { (completed) in
                    self.disable = false
            })
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

