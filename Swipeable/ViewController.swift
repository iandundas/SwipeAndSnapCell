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
        let cell = tableView.dequeueReusableCell(withIdentifier: SwipeableCell.id) as! SwipeableCell
        
        // Not the best but will do for now:
        cell.swipeableContentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Cool"
        
        cell.successCallback = { [unowned label] in
            label.text = "DROOL"
        }
        
        cell.swipeableContentView.addSubview(label)
        label.constrainToEdgesOf(otherView: cell.swipeableContentView)
        
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


class ViewController: UITableViewController {
    
    let tableViewDelegate = TableViewDelegate()
    let tableViewDataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SwipeableCell.self, forCellReuseIdentifier: SwipeableCell.id)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
    }
}

