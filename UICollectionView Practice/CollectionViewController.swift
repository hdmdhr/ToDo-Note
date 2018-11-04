//
//  ViewController.swift
//  UICollectionView Practice
//
//  Created by 胡洞明 on 2018/9/25.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBarBtn: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var categories: [Category] = []

    var longPressEnabled = false {
        didSet{
            let cells = collectionView.visibleCells as! [CollectionViewCell]
            if longPressEnabled {
                navBarBtn.title = "Done"
                for cell in cells {
                    cell.startAnimate()
                }
            } else {
                navBarBtn.title = "Edit"
                for cell in cells {
                    cell.stopAnimate()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadData()
        navBarBtn.title = "Edit"
        
        // MARK: Add gestures
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPress)

//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        collectionView.addGestureRecognizer(panGesture)

        // MARK: Add + button data
        if categories.isEmpty {
            let add = Category(context: context)
            add.name = "+"
            add.dateCreated = Date()
            add.colorHex = FlatWhiteDark().hexValue()
            add.order = 0
            categories.append(add)
        }
        
        
        // MARK: - Set Layouts
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.minimumInteritemSpacing = 2
//        layout.minimumLineSpacing = 4
//        layout.estimatedItemSize = layout.collectionViewContentSize
//        layout.sectionInset = UIEdgeInsets(top: 10 , left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/2 - 5, height: UIScreen.main.bounds.width/2 - 5)
//        layout.sectionInsetReference = .fromSafeArea
//        print("item size: \(layout.itemSize)")
    }

    // MARK: - Datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
//        cell.backgroundColor = HexColor("9A9A9A", 0.25)
        cell.roundBtn.layer.cornerRadius = 0.5 * 7 * (UIScreen.main.bounds.width/2 - 5) / 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = FlatGray().withAlphaComponent(0.25).cgColor
        cell.roundBtn.setTitle(categories[indexPath.item].name, for: .normal)
        cell.roundBtn.backgroundColor = HexColor(categories[indexPath.item].colorHex ?? FlatWatermelon().hexValue(), 0.85)
        
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
        return CGSize(width: UIScreen.main.bounds.width/2 - 5, height: UIScreen.main.bounds.width/2 - 5)
    }
    
    // MARK: Move cells
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("Start index: \(sourceIndexPath.item)")
        print("End index: \(destinationIndexPath.item)")
        
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
    
    // MARK: - Add/Delete/Edit/Change categories
    var tappedCategory: Category?
    
    @IBAction func roundButtonPressed(_ sender: RoundButton) {
        if sender.currentTitle! == "+" {
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
            let destinationVC = segue.destination as! ToDoVC
            destinationVC.category = tappedCategory
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
            self.categories.insert(newCategory, at: 0)
            
            self.saveData()
            self.collectionView.reloadData()
            
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
        
        let alert = UIAlertController(title: "will also delete ALL items and notes the category contains", message: "", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteActionWithHitIndex(hitIndex)
        })
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteActionWithHitIndex(_ hitIndex: IndexPath) {
        if categories[hitIndex.row].name != "+" {
            let itemsUnderCategory = categories[hitIndex.row].itemsToDo?.allObjects as! [ToDoItems]
            for item in itemsUnderCategory {
                context.delete(item)
            }
            context.delete(categories[hitIndex.row])
            categories.remove(at: hitIndex.row)
            saveData()
            collectionView.reloadData()
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
        }
        
        saveData()
    }
    

    @IBAction func navBarBtnPressed(_ sender: UIBarButtonItem) {
        longPressEnabled = !longPressEnabled
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
//            collectionView.reloadData()
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

// MARK: - Gesture handling

extension CollectionViewController {
    
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
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        if longPressEnabled {
            switch gesture.state {
            case .began:
                guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
                
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                
            case .ended:
                collectionView.endInteractiveMovement()
                
            default:
                collectionView.cancelInteractiveMovement()
            }
        }
    }
}
