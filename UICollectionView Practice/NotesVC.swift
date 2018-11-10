//
//  NotesVC.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-05.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit
import CoreData

class NotesVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    var currentItem: ToDoItems?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = currentItem?.title

    }
    
    // MARK: - TextField Delegate Methods
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: - 将修改的title保存
    }

    
    // MARK: - TextView Delegate Methods
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // TODO: - 将修改好的note保存至当前item下
    }

    
    // TODO: - 为当前note添加图片，显示当前item的创建日期，完成日期

}
