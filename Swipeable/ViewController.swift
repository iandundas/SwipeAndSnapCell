//
//  ViewController.swift
//  Swipeable
//
//  Created by Ian Dundas on 24/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource{
    
    var swipedCallback: ((IndexPath, SwipeableCell.SwipeSide)->())? = nil
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwipeableCell.id) as! SwipeableCell
        cell.swipeableContentView.backgroundColor = UIColor(red:0.65, green:0.78, blue:0.90, alpha:1.00)
        
        // Not the best but will do for now:
        cell.swipeableContentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "😊"
        
        cell.successCallback = { [weak self, unowned label] side in
            self?.swipedCallback?(indexPath, side)
            label.text = "😇"
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
        
        tableViewDataSource.swipedCallback = { [weak self] indexPath, side in
            let alert = UIAlertController(title: "Activated!", message: "IndexPath: {\(indexPath.section), \(indexPath.row)}, side: \(side)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

