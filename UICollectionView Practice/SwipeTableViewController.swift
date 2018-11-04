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
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    
    // MARK: - Swipe to Delete
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let alert = UIAlertController(title: "Delete selected item and notes", message: "", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.updateModel(at: indexPath)
            })
            
            alert.addAction(deleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let changeColorAction = SwipeAction(style: .default, title: "Change") { action, indexPath in
            self.changeColor(at: indexPath)  // Change color and update database
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-Icon")
        changeColorAction.image = UIImage(named: "color-wheel")
        changeColorAction.backgroundColor = FlatWhiteDark()
        
        return [deleteAction, changeColorAction]
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
    
    func changeColor(at indexPath: IndexPath) {
        
    }

}
