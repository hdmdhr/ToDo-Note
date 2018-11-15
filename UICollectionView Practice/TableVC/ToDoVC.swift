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

class ToDoVC: SwipeTableViewController {
    
 let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var items: [ToDoItems] = []
    private var sorttedItems: [ExpandableItems] = []
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
        let view = UIView()
        switch sorttedItems[section].items.first?.done {
        case "ToDo":
            view.backgroundColor = FlatBlue()
        case "Done":
            view.backgroundColor = FlatMint()
        case "Failed":
            view.backgroundColor = FlatGray()
        default:
            break
        }
    
        let button = UIButton(type: .system)
        button.setTitle("collapse", for: .normal)
        button.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: 5, width: 80, height: 30)
        button.tintColor = FlatWhite()
        button.titleLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        button.tag = section
        button.addTarget(self, action: #selector(expandCollaspseBtnPressed), for: .touchUpInside)
        view.addSubview(button)
        
        let label = UILabel()
        label.text = sorttedItems[section].items.first?.done
        label.textColor = FlatWhite()
        label.font = UIFont.systemFont(ofSize: 18)
        label.frame = CGRect(x: 10, y: 5, width: 80, height: 30)
        view.addSubview(label)

        return view
    }
    
    @objc func expandCollaspseBtnPressed(button: UIButton){
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        
        for row in sorttedItems[section].items.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = sorttedItems[section].isExpanded
        sorttedItems[section].isExpanded = !sorttedItems[section].isExpanded
        
        button.setTitle(isExpanded ? "Expand" : "Collapse", for: .normal)
        if button.currentTitle == "Expand" {
            button.tintColor = FlatWhite().darken(byPercentage: 0.15)
        } else {
            button.tintColor = FlatWhite()
        }

        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    
    //MARK: - Tableview Datasource

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sorttedItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !sorttedItems[section].isExpanded {
            return 0
        }
        
        return sorttedItems[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! MyTableViewCell
        
        let item = sorttedItems[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title

            switch item.done {
            case "Failed":
                cell.checkBox.setImage(UIImage(named: "crossed"), for: .normal)
            case "Done":
                cell.checkBox.setImage(UIImage(named: "checked"), for: .normal)
            default:
                cell.checkBox.setImage(UIImage(named: "empty"), for: .normal)
            }
        
        cell.backgroundColor = UIColor(hexString: category.colorHex!)!.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(sorttedItems[indexPath.section].items.count)) * 0.15)
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
            noteVC.currentItem = sorttedItems[index.section].items[index.row]
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
        context.delete(sorttedItems[indexPath.section].items[indexPath.row])
        sorttedItems[indexPath.section].items.remove(at: indexPath.row)
        saveItems()
        loadItemsUnderCurrentCategory()
    }
    
    // MARK: Mark Item as Failed
    
    override func failingItemAt(_ indexPath: IndexPath) {
        if sorttedItems[indexPath.section].items[indexPath.row].done == "Failed" {
            sorttedItems[indexPath.section].items[indexPath.row].done = "ToDo"
        } else {
            sorttedItems[indexPath.section].items[indexPath.row].done = "Failed"
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
        switch sorttedItems[hitIndex.section].items[hitIndex.row].done {
        case "ToDo":
            sorttedItems[hitIndex.section].items[hitIndex.row].done = "Done"
        case "Done":
            sorttedItems[hitIndex.section].items[hitIndex.row].done = "ToDo"
        default:
            sorttedItems[hitIndex.section].items[hitIndex.row].done = "ToDo"
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
        sorttedItems.removeAll()
        
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
        if !todoItems.items.isEmpty { sorttedItems.append(todoItems) }
        if !doneItems.items.isEmpty { sorttedItems.append(doneItems) }
        if !failedItems.items.isEmpty { sorttedItems.append(failedItems) }

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

