//
//  CategoryViewController.swift
//  UICollectionView Practice
//
//  Created by 胡洞明 on 2018/9/25.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import MessageUI

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBarBtn: UIBarButtonItem!
    @IBOutlet weak var menuTable: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sizeSetter = UserDefaults.standard.integer(forKey: "categorySize") {
        didSet{
            if sizeSetter > 4 { sizeSetter = 4 } else if sizeSetter < 2 { sizeSetter = 2 }
            UserDefaults.standard.set(sizeSetter, forKey: "categorySize")  // save category size
        }
    }
    
    var categories: [Category] = []
    let menuOptions = [("Version 1.0", "tool"),
                       ("Show Tutorial", "book"),
                       ("Report Bugs", "notification"),
                       ("Contact Developer", "mail")
    ]

    var longPressEnabled = false {
        didSet{
            let cells = collectionView.visibleCells as! [CollectionViewCell]
            for cell in cells {
                if longPressEnabled {
                    navBarBtn.title = "Done"
                    cell.startAnimate()
                } else {
                    navBarBtn.title = "Edit"
                    cell.stopAnimate()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navBarBtn.title = "Edit"
        menuTable.tableFooterView = UIView()
        
        // MARK: Add gestures
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPress)

        // MARK: Add + button data
        if categories.isEmpty {
            let add = Category(context: context)
            add.name = "+"
            add.dateCreated = Date()
            add.colorHex = FlatWhiteDark().hexValue()
            add.order = 0
            add.toDoExpanded = true
            add.doneExpanded = true
            add.failedExpanded = true
            categories.append(add)
        }
        
        
        // MARK: - Set Layouts
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
//        layout.estimatedItemSize = layout.collectionViewContentSize
//        layout.sectionInset = UIEdgeInsets(top: 10 , left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/2 - 5, height: UIScreen.main.bounds.width/2 - 5)
//        layout.sectionInsetReference = .fromSafeArea
//        print("item size: \(layout.itemSize)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("No nav controller") }
        navBar.tintColor = ContrastColorOf(navBar.barTintColor!, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor]
        collectionView.reloadData()
    }

    // MARK: - Datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.roundBtn.setImage(nil, for: .normal)
        if categories[indexPath.item].name == "+" {
            cell.roundBtn.setImage(UIImage(named: "add"), for: .normal)
        }
        cell.layer.borderWidth = 1
        cell.layer.borderColor = FlatGray().withAlphaComponent(0.15).cgColor
        cell.roundBtn.setTitle(categories[indexPath.item].name, for: .normal)
        cell.roundBtn.backgroundColor = HexColor(categories[indexPath.item].colorHex!, 0.9)
        cell.roundBtn.tintColor = ContrastColorOf(cell.roundBtn.backgroundColor!, returnFlat: true)
        
        if longPressEnabled {
            cell.startAnimate()
        } else {
            cell.stopAnimate()
        }
        
        return cell
    }
    
    // MARK: - Delegate Methods
    
    // MARK: Set cell size
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/CGFloat(sizeSetter) - 5, height: UIScreen.main.bounds.width/CGFloat(sizeSetter) - 5)
    }
    
    // MARK: - Add/Delete/Edit/Change categories & Navigation
    
    var tappedCategory: Category?
    
    @IBAction func roundButtonPressed(_ sender: RoundButton) {
        if sender.currentTitle == "+" {
            addButtonPressed()
        } else {
            let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
            let hitIndex = collectionView.indexPathForItem(at: hitPoint)
            tappedCategory = categories[hitIndex!.item]
            
            longPressEnabled = false
            performSegue(withIdentifier: "ShowItems", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItems" {
            let toDoVC = segue.destination as! ToDoVC
            toDoVC.category = tappedCategory
        }
    }
    
    private func addButtonPressed(){
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.colorHex = Settings.palletHex[self.categories.count % Settings.palletHex.count]
            newCategory.dateCreated = Date()
            newCategory.order = self.categories[0].order + 1
            newCategory.toDoExpanded = true
            newCategory.doneExpanded = true
            newCategory.failedExpanded = true
            self.categories.insert(newCategory, at: 0)
            
            self.saveData()
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }
        
        alert.addTextField { (field) in
            field.placeholder = "New category name"
            textField = field
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { fatalError("cannot find tapped index") }
        
        if categories[hitIndex.row].itemsToDo?.count == 0 {
            deleteDataWithHitIndex(hitIndex)  // if category has no item, delete without alert
        } else {
            let alert = UIAlertController(title: "Are you sure ?", message: "Will also delete all items and notes under the selected category", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.deleteDataWithHitIndex(hitIndex)
            })
            
            alert.addAction(deleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func deleteDataWithHitIndex(_ hitIndex: IndexPath) {
        if categories[hitIndex.row].name != "+" {
            let itemsUnderCategory = categories[hitIndex.row].itemsToDo?.allObjects as! [ToDoItems]
            for item in itemsUnderCategory {
                context.delete(item)  // delete all items under category first
            }
            context.delete(categories[hitIndex.row])
            categories.remove(at: hitIndex.row)
            saveData()
            collectionView.deleteItems(at: [hitIndex])
        }
    }
    
    @IBAction func changeColorBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        let hitIndex = collectionView.indexPathForItem(at: hitPoint)

        let currentColorHex = categories[hitIndex!.row].colorHex!
        let index = Settings.palletHex.firstIndex(of: currentColorHex)!
        categories[hitIndex!.row].colorHex! = Settings.palletHex[(index + 1) % Settings.palletHex.count]
        if let cell = collectionView.cellForItem(at: hitIndex!) as? CollectionViewCell {
            cell.roundBtn.backgroundColor = HexColor(categories[hitIndex!.row].colorHex!)
            cell.roundBtn.tintColor = ContrastColorOf(cell.roundBtn.backgroundColor!, returnFlat: true)
        }
        
        saveData()
    }
    
    @IBAction func changeCellSizeBtnPressed(_ sender: UIButton) {
        switch sender.tag {
        case 4:
            // enlarge
            sizeSetter -= 1
            collectionView.collectionViewLayout.invalidateLayout()
        case 3:
            sizeSetter += 1
            collectionView.collectionViewLayout.invalidateLayout()
        default:
            return
        }
        collectionView.layoutIfNeeded()
//        let cells = collectionView.visibleCells as! [CollectionViewCell]
//        for cell in cells {
//            cell.roundBtn.titleLabel?.adjustsFontSizeToFitWidth
//        }
    }
    
    @IBAction func navBarBtnPressed(_ sender: UIBarButtonItem) {
        longPressEnabled = !longPressEnabled
    }
    
    // MARK: - Show / Hide Menu
    
    @IBOutlet weak var veil: UIView!
    var menuIsOpen = false
    
    @IBAction func menuBtnPressed(_ sender: UIBarButtonItem) {
        if menuIsOpen {
            handleDismiss()
        } else {
            veil.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.veil.alpha = 0.4
                self.menuTable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
            }, completion: nil)
            menuIsOpen = true
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            self.veil.alpha = 0
            self.menuTable.frame = CGRect(x: -UIScreen.main.bounds.width / 2, y: 0, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
        }
        menuIsOpen = false
    }
    
    // MARK: - Data manipulation
    
    func saveData() {
        if context.hasChanges {
            do {
                try context.save()
                print("changes saved")
            } catch {
                fatalError("unable to save changes due to error: \(error)")
            }
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        do {
            categories = try context.fetch(request)
        } catch {
            print("unable to load data with error \(error)")
        }
    }
    
}

// MARK: - Menu Table

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 3 * ( #imageLiteral(resourceName: "notification").size.height)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == menuTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            cell?.textLabel?.text = menuOptions[indexPath.row].0
            cell?.imageView?.image = UIImage(named: menuOptions[indexPath.row].1)
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menuTable.deselectRow(at: indexPath, animated: true)
        switch menuTable.cellForRow(at: indexPath)!.textLabel?.text {
        case "Show Tutorial":
            performSegue(withIdentifier: "ShowTutorial", sender: self)
        case "Report Bugs", "Contact Developer" :
            sendEmail(with: indexPath)
        default:
            break
        }
        handleDismiss()
    }
    
    func sendEmail(with indexPath: IndexPath){
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["hdmdhr@gmail.com"])
        mailComposerVC.setSubject(menuTable.cellForRow(at: indexPath)!.textLabel?.text ?? "Hello")
        mailComposerVC.setMessageBody("Hi Dear Developer, ", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Gesture to Move Cells

extension CategoryViewController {
    
    //    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    //        return longPressEnabled
    //    }  --- No Longer Needed Because of The Following Methond ---
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = categories.remove(at: sourceIndexPath.item)
        categories.insert(temp, at: destinationIndexPath.item)
        // Whenever reorder happens, give all categories a new order number
        var i = categories.count
        for category in categories {
            category.order = Int32(i - 1)
            i -= 1
        }
        
        saveData()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            longPressEnabled = true

            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:
            collectionView.endInteractiveMovement()

        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//
//        if longPressEnabled {
//            switch gesture.state {
//            case .began:
//                guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
//
//                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
//            case .changed:
//                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//
//            case .ended:
//                collectionView.endInteractiveMovement()
//
//            default:
//                collectionView.cancelInteractiveMovement()
//            }
//        }
//    }
}
