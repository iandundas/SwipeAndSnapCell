//
//  ViewController.swift
//  Swipeable
//
//  Created by Ian Dundas on 24/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit

let CellID = "Cell"

class TableViewDataSource: NSObject, UITableViewDataSource{
    
    var swipedCallback: ((IndexPath, SwipeableCell.SwipeSide)->())? = nil
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID) as! SwipeableCell
        
        let label = UILabel()
        label.backgroundColor = UIColor(red:0.65, green:0.78, blue:0.90, alpha:1.00)
        label.font = UIFont(name: "Helvetica", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "😊"
        
        cell.didActivateCallback = { [weak self, unowned label] side in
            self?.swipedCallback?(indexPath, side)
            label.text = "😇"
        }
        
        cell.hostedView = label
        cell.backgroundColor = UIColor.red
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000
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
        
        tableView.register(SwipeableCell.self, forCellReuseIdentifier: CellID)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        
        tableViewDataSource.swipedCallback = { [weak self] indexPath, side in
            let alert = UIAlertController(title: "Activated!", message: "IndexPath: {\(indexPath.section), \(indexPath.row)}, side: \(side)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

