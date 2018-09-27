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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var categories: [Category] = []
    var cateNumbers = 0
    let pallet: [UIColor] = [FlatWatermelon(),FlatRed(),FlatOrange(),FlatYellow(),FlatGreen(),FlatLime(),FlatSkyBlue(),FlatMagenta(),FlatPurple()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        loadData()
        
        if categories.isEmpty {
            let addCategory = Category(context: context)
            addCategory.name = "Add"
            addCategory.dateCreated = Date()
            addCategory.colorHex = FlatWatermelon().hexValue()
            categories.append(addCategory)
        }
        
        
        // MARK: - Layouts
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.sectionInset = UIEdgeInsets(top: 10 , left: 0, bottom: 10, right: 0)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        layout.itemSize = CGSize(width: collectionView.bounds.width/2 - 2, height: collectionView.bounds.width/2 - 2)
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
        
        return cell
    }
    
    // MARK: - Delegate Methods
    
    
    // MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: RoundButton) {
        guard sender.currentTitle! == "Add" else { return }
        
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
    
    // MARK: - Data manipulation
    
    func saveData() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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

