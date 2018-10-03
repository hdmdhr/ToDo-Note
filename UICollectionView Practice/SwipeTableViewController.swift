//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by 胡洞明 on 2018/5/10.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit
import SwipeCellKit

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
        guard orientation == .right else {  // .left时可以改变颜色
            let changeColorAction = SwipeAction(style: .default, title: "Change") { action, indexPath in  // 修改颜色并修改category数据库
                self.changeColor(at: indexPath)
            }
            
            // customize the action appearance
            changeColorAction.image = UIImage(named: "color-wheel")
            
            return [changeColorAction]
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash-Icon")
        
        return [deleteAction]
    }
    
    // MARK: Swipe far enough to delete
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()

        if orientation == .right{
            options.expansionStyle = .destructive
        } else {
            options.expansionStyle = .selection
        }
        return options
    }

    // MARK: - Convenient Methods
    
    func updateModel(at indexPath: IndexPath) {
        
    }
    
    func changeColor(at indexPath: IndexPath) {
        
    }

}
