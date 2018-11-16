//
//  ViewController.swift
//  Todoey
//
//  Created by 胡洞明 on 2018/5/3.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import SwipeCellKit
import TableViewDragger

class ToDoVC: SwipeTableViewController {
    
 let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dragger: TableViewDragger!
    
    private var items: [ToDoItems] = []
    private var sortedItems: [ExpandableItems] = []
    private var todoItems = ExpandableItems(items: [], isExpanded: true)
    private var doneItems = ExpandableItems(items: [], isExpanded: true)
    private var failedItems = ExpandableItems(items: [], isExpanded: true)
    
    var category : Category! {
        didSet{
            loadItemsUnderCurrentCategory()  // load all the items under current category
            navigationItem.title = category.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragger = TableViewDragger(tableView: tableView)
        dragger.availableHorizontalScroll = true
        dragger.dataSource = self
        dragger.delegate = self
        dragger.alphaForCell = 0.7
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.backgroundColor = UIColor(hexString: category.colorHex!)

        guard let navBar = navigationController?.navigationBar else { fatalError("No nav controller") }
//        guard let barColor = UIColor(hexString: category.colorHex) else { fatalError() }
        navBar.barTintColor = UIColor(hexString: category.colorHex!)
        navBar.tintColor = ContrastColorOf(navBar.barTintColor!, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor]
        
        searchBar.barTintColor = HexColor(category.colorHex!)
    }
    
    // MARK: - Table Header Appearance
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        switch sortedItems[section].items.first?.done {
        case "ToDo":
            headerView.backgroundColor = FlatBlue()
        case "Done":
            headerView.backgroundColor = FlatMint()
        case "Failed":
            headerView.backgroundColor = FlatGray()
        default:
            break
        }
        
        let label = UILabel()
        label.text = sortedItems[section].items.first?.done
        label.textColor = FlatWhite()
        label.font = UIFont.systemFont(ofSize: 18)
        label.frame = CGRect(x: 10, y: 5, width: 80, height: 30)
        headerView.addSubview(label)
    
        let button = UIButton(type: .system)
        let isExpanded = sortedItems[section].isExpanded
        button.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)
        if button.currentTitle == "Expand" {
            button.tintColor = FlatWhite()
        } else {
            button.tintColor = FlatWhite().darken(byPercentage: 0.2)
        }
        button.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: 5, width: 80, height: 30)
        button.titleLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        button.tag = section
        button.addTarget(self, action: #selector(expandCollaspseBtnPressed), for: .touchUpInside)
        headerView.addSubview(button)

        return headerView
    }
    
    @objc func expandCollaspseBtnPressed(button: UIButton){
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        
        for row in sortedItems[section].items.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = sortedItems[section].isExpanded
        sortedItems[section].isExpanded = !sortedItems[section].isExpanded
        switch sortedItems[section].items.first?.done {
        case "ToDo":
            category.toDoExpanded = sortedItems[section].isExpanded
        case "Done":
            category.doneExpanded = sortedItems[section].isExpanded
        case "Failed":
            category.failedExpanded = sortedItems[section].isExpanded
        default:
            break
        }
        saveItems()
        
        button.setTitle(isExpanded ? "Expand" : "Collapse", for: .normal)
        if button.currentTitle == "Expand" {
            button.tintColor = FlatWhite()
        } else {
            button.tintColor = FlatWhite().darken(byPercentage: 0.2)
        }

        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    
    //MARK: - Tableview Datasource

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !sortedItems[section].isExpanded {
            return 0
        }
        
        return sortedItems[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! MyTableViewCell
        
        let item = sortedItems[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title

            switch item.done {
            case "Failed":
                cell.checkBox.setImage(UIImage(named: "crossed"), for: .normal)
            case "Done":
                cell.checkBox.setImage(UIImage(named: "checked"), for: .normal)
            default:
                cell.checkBox.setImage(UIImage(named: "empty"), for: .normal)
            }
        
        cell.backgroundColor = UIColor(hexString: category.colorHex!)!.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(sortedItems[indexPath.section].items.count)) * 0.15)
        cell.textLabel?.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        
        
        return cell
    }

    // MARK: - Tableview Delegate & Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowNotes", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)   // 选中后一闪而过

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNotes" {
            let noteVC = segue.destination as! NotesVC
            guard let index = tableView.indexPathForSelectedRow else {fatalError("No selected row")}
            noteVC.currentItem = sortedItems[index.section].items[index.row]
        }
    }
    
    // MARK: - Add New Items
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Todo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Create newItem，Set its properties，Save
            let newItem = ToDoItems(context: self.context)
            newItem.title = textField.text
            newItem.done = "ToDo"
            newItem.parentCategory = self.category
            
            self.saveItems()
            self.loadItemsUnderCurrentCategory()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Swipe Functions
    
    // MARK:  Delete Data by Swipe to Left
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(sortedItems[indexPath.section].items[indexPath.row])
        sortedItems[indexPath.section].items.remove(at: indexPath.row)
        saveItems()
        loadItemsUnderCurrentCategory()
    }
    
    // MARK: Mark Item as Failed
    
    override func failingItemAt(_ indexPath: IndexPath) {
        if sortedItems[indexPath.section].items[indexPath.row].done == "Failed" {
            sortedItems[indexPath.section].items[indexPath.row].done = "ToDo"
        } else {
            sortedItems[indexPath.section].items[indexPath.row].done = "Failed"
        }
        saveItems()
        tableView.reloadRows(at: [indexPath], with: .right)
        loadItemsUnderCurrentCategory()
    }
    
    // MARK:  Change Color
    
    override func changeColor(at indexPath: IndexPath) {

        let index = Settings.palletHex.firstIndex(of: category.colorHex!)!
        category.colorHex = Settings.palletHex[(index + 1) % Settings.palletHex.count]
        saveItems()
        let cells = tableView.visibleCells
        var i = 0
        for cell in cells {
            cell.backgroundColor = HexColor(category.colorHex!)?.darken(byPercentage: CGFloat(i) / CGFloat(cells.count) * 0.15)
            i += 1
        }
        
        viewWillAppear(true)
    }
    
    // MARK: - User Tapped Checkbox
    
    @IBAction func checkBoxPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: tableView)
        guard let hitIndex = tableView.indexPathForRow(at: hitPoint) else { fatalError("cannot find hit index") }
        switch sortedItems[hitIndex.section].items[hitIndex.row].done {
        case "ToDo":
            sortedItems[hitIndex.section].items[hitIndex.row].done = "Done"
        case "Done":
            sortedItems[hitIndex.section].items[hitIndex.row].done = "ToDo"
        default:
            sortedItems[hitIndex.section].items[hitIndex.row].done = "ToDo"
        }
        
        saveItems()
        
        loadItemsUnderCurrentCategory()

    }
    
    
    // MARK: - Data Manipulation Methods
    
    func saveItems(){
        do {
            try context.save()
            print("Changes saved")
        } catch {
            print("Error with saving: \(error)")
        }
    }
    
    func loadItemsUnderCurrentCategory(with request: NSFetchRequest<ToDoItems> = ToDoItems.fetchRequest(), _ predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", category.name!)
        
        if let predicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            fatalError("Error fetching data, \(error)")
        }

        todoItems.items.removeAll()
        doneItems.items.removeAll()
        failedItems.items.removeAll()
        sortedItems.removeAll()
        
        for item in items {
            switch item.done {
            case "ToDo":
                todoItems.items.append(item)
            case "Done":
                doneItems.items.append(item)
            case "Failed":
                failedItems.items.append(item)
            default:
                break
            }
        }
        
        todoItems.isExpanded = category.toDoExpanded
        doneItems.isExpanded = category.doneExpanded
        failedItems.isExpanded = category.failedExpanded
        
        if !todoItems.items.isEmpty { sortedItems.append(todoItems) }
        if !doneItems.items.isEmpty { sortedItems.append(doneItems) }
        if !failedItems.items.isEmpty { sortedItems.append(failedItems) }

        UIView.transition(with: tableView, duration: 1, options: .curveEaseInOut, animations: {
            self.tableView.reloadData()
        }, completion: nil)
//            tableView.reloadData()
        }

}



// MARK: - Search Bar Functions

extension ToDoVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchByTitle()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {  // Dynamic Search
        if searchBar.text?.count == 0 {
            loadItemsUnderCurrentCategory()
        } else {
            searchByTitle()
        }
    }
    
    func searchByTitle() {
        let request : NSFetchRequest<ToDoItems> = ToDoItems.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItemsUnderCurrentCategory(with: request, predicate)
    }
}

extension ToDoVC: TableViewDraggerDataSource, TableViewDraggerDelegate {
    
    func dragger(_ dragger: TableViewDragger, moveDraggingAt indexPath: IndexPath, newIndexPath: IndexPath) -> Bool {
        if indexPath.section == newIndexPath.section {  // only allow drag within the same section
            let itemToMove = sortedItems[indexPath.section].items.remove(at: indexPath.row)
            sortedItems[newIndexPath.section].items.insert(itemToMove, at: newIndexPath.row)
            
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
            return true
        } else {
            return false
        }
    }

}
