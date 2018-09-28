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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBarBtn: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var categories: [Category] = []
    let pallet: [UIColor] = [FlatWatermelon(),FlatRed(),FlatOrange(),FlatYellow(),FlatGreen(),FlatLime(),FlatSkyBlue(),FlatMagenta(),FlatPurple()]
    var longPressEnabled = false {
        didSet{
            if longPressEnabled {
                navBarBtn.title = "Done"
            } else {
                navBarBtn.title = "Edit"
            }
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarBtn.title = "Edit"
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPress)
 
        loadData()
        
        if categories.isEmpty {
            let add = Category(context: context)
            add.name = "+"
            add.dateCreated = Date()
            add.colorHex = FlatWatermelon().hexValue()
            categories.append(add)
        }
        
        
        // MARK: - Layouts
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.sectionInset = UIEdgeInsets(top: 10 , left: 0, bottom: 10, right: 0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/2 - 5, height: UIScreen.main.bounds.width/2 - 5)
        layout.sectionInsetReference = .fromSafeArea
    }

    // MARK: - Datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
//        cell.backgroundColor = HexColor("9A9A9A", 0.25)
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
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("Start index: \(sourceIndexPath.item)")
        print("End index: \(destinationIndexPath.item)")
        
        let temp = categories[sourceIndexPath.item]
        categories[sourceIndexPath.item] = categories[destinationIndexPath.item]
        categories[destinationIndexPath.item] = temp
        
        saveData()
    }
    
    // MARK: - Add/Delete categories
    
    @IBAction func addButtonPressed(_ sender: RoundButton) {
        guard sender.currentTitle! == "+" else { return }

        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.colorHex = self.pallet[self.categories.count % self.pallet.count].hexValue()
            newCategory.dateCreated = Date()
            self.categories.insert(newCategory, at: 0)
            
            self.saveData()
            
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Type a new category name"
            textField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        let hitIndex = collectionView.indexPathForItem(at: hitPoint)
        
        context.delete(categories[hitIndex!.row])
        categories.remove(at: hitIndex!.row)
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
            } catch {
                fatalError("unable to save changes due to error: \(error)")
            }
            collectionView.reloadData()
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        do {
            categories = try context.fetch(request)
        } catch {
            print("unable to load data with error \(error)")
        }
    }
    
}

// MARK: - Gesture handling

extension ViewController {
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
//        let cells = collectionView.visibleCells as! [CollectionViewCell]

        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:
            collectionView.endInteractiveMovement()
            longPressEnabled = true

        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}
