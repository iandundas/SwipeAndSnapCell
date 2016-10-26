//
//  ViewController.swift
//  Swipeable
//
//  Created by Ian Dundas on 24/10/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import SwipeAndSnapCell

let CellID = "Cell"

class CellHostedView: UIView {
    
    let label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        
        super.init(frame: frame)
        
        label.backgroundColor = generateRandomPastelColor(withMixedColor: nil)
        label.font = UIFont(name: "Helvetica", size: 20)
        label.textAlignment = .center
        label.text = "😊"
        
        addSubview(label)
        label.constrainToEdgesOf(otherView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TableViewDataSource: NSObject, UITableViewDataSource{
    
    var swipedCallback: ((IndexPath, SwipeAndSnapCell.SwipeSide)->())? = nil
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID) as! SwipeAndSnapCell
        
        if cell.hostedView == nil{
            let hostedView = CellHostedView()
            cell.hostedView = hostedView
        }
        
        if let hostedView = cell.hostedView as? CellHostedView{
            hostedView.label.text = "Cell: \(indexPath.row)"
            
            cell.didActivateCallback = { [weak self, unowned hostedView] side in
                self?.swipedCallback?(indexPath, side)
                hostedView.label.text = "Activated on \(side) side!"
            }
        }
        
        if cell.leftButton == nil {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor(red:0.99, green:0.19, blue:0.35, alpha:1.00)
            
            let image = UIImage(named: "heart")!
            button.setImage(image, for: .normal)
            cell.leftButton = button
        }
        
        if cell.rightButton == nil {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.00)
            
            let image = UIImage(named: "trash")!
            button.setImage(image, for: .normal)
            cell.rightButton = button
        }
        
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
        title = "Swipe and Snap"
        
        tableView.register(SwipeAndSnapCell.self, forCellReuseIdentifier: CellID)
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        
        tableViewDataSource.swipedCallback = { [weak self] indexPath, side in
//            let alert = UIAlertController(title: "Activated!", message: "IndexPath: {\(indexPath.section), \(indexPath.row)}, side: \(side)", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
//            self?.present(alert, animated: true, completion: nil)
        }
    }
}

