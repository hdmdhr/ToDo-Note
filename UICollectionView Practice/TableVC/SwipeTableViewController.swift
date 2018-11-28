//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by 胡洞明 on 2018/5/10.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 3 * ( #imageLiteral(resourceName: "color-wheel").size.height)
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    
    // MARK: - Swipe to Delete
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
            self.updateModel(at: indexPath)
        }
        
        let failAction = SwipeAction(style: .default, title: "Failed") { (_, indexPath) in
            self.failingItemAt(indexPath)
        }
        
        let changeColorAction = SwipeAction(style: .default, title: "Change") { _, indexPath in
            self.changeColor(at: indexPath)  // Change color and update database
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-Icon")
        failAction.image = UIImage(named: "small-cross")
        changeColorAction.image = UIImage(named: "color-wheel")
        failAction.backgroundColor = FlatWhiteDark()
        
        return [deleteAction, failAction,changeColorAction]
    }
    
    // MARK: Swipe far enough to delete
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()

        options.expansionStyle = .none
        options.transitionStyle = .border
        
        return options
    }

    // MARK: - Convenient Methods
    
    func updateModel(at indexPath: IndexPath) {
        
    }
    
    func failingItemAt(_ indexPath: IndexPath) {
        
    }
    
    func changeColor(at indexPath: IndexPath) {
        
    }

}
