//
//  NotesVC.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-05.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Photos

class NotesVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var currentItem: ToDoItems! {
        didSet{
            loadImagesUnderCurrentItem()
        }
    }
    var images: [Image] = []
    
    let imagePicker = UIImagePickerController()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let saveQueue = DispatchQueue(label: "saveQueue", attributes: .concurrent)
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var longPressEnabled = false {
        didSet{
            let cells = collectionView.visibleCells as! [PhotoCell]
            for cell in cells {
                if longPressEnabled {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBarBtnPressed))
                    cell.startAnimate()
                } else {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraBtnPressed))
                    cell.stopAnimate()
                }
            }
        }
    }
    
    @objc func doneBarBtnPressed(){
        longPressEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = currentItem.title
        noteTextView.text = currentItem.note ?? "Add details here..."
        if noteTextView.text == "Add details here..." { noteTextView.textColor = .lightGray }
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraBtnPressed))
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        collectionView.addGestureRecognizer(longPress)
        
    }
    
    @objc func dismissKeyboard(_: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)

        if textField.text != "Title" {
            currentItem.title = textField.text
            saveData()
        }
    }

    
    // MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add details here...", textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Add details here..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        
        if textView.text !=  "Add details here..." {
            currentItem.note = textView.text
            saveData()
        }
    }
    
    // MARK: - Data Manipulation
    
    func saveData(){
            do {
                try context.save()
                print("Changes under current item are saved")
            } catch {
                print("Error with saving: \(error)")
            }
    }
    
    func loadImagesUnderCurrentItem(with predicate: NSPredicate? = nil){
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        let allImagePredicate = NSPredicate(format: "fromItem.title MATCHES %@", currentItem.title!)
        request.predicate = allImagePredicate
        
        do {
            images = try context.fetch(request)
        } catch {
            fatalError("Error while fetching images, \(error)")
        }
    }

    
    // MARK: - Editing Picture (delete, enlarge, shrink)
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        print("Delete picture button pressed")
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else {
            print("cannot find index for the point you hit")
            return
        }
        
        context.delete(images[hitIndex.item])
        saveData()
        
        images.remove(at: hitIndex.item)
        
        collectionView.deleteItems(at: [hitIndex])
    }
    
    
    // MARK: - Long Press Gesture to Enable Animation and Move Cells

    // TODO: Move Cells
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer){
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
}

// MARK: - Picture Collection View

extension NotesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Picture Collection View Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.isEmpty {
            return 1
        } else {
            return images.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! PhotoCell
        cell.pictureView.image = UIImage(named: "plus")
        // TODO: set image to loaded images array
        
        return cell
    }
    
    // MARK: Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        if cell.pictureView.image == UIImage(named: "plus") {
            
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            let libraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch libraryAuthorizationStatus {
            case .denied: break
            case .authorized:
                showImagePicker()
            case .restricted: break
            case .notDetermined:
                // Prompting user for the permission to use the photo library.
                PHPhotoLibrary.requestAuthorization { (newStatus) in
                    if newStatus == .authorized {
                        self.showImagePicker()
                    } else {
                        print("Denied access")
                    }
                }
            }
        }
    }
}

extension NotesVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func cameraBtnPressed(){
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camera not supported by this device")
            return
        }
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            imagePicker.sourceType = .camera
            showImagePicker()
        case .denied: break
        case .restricted: break
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    self.showImagePicker()
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    func showImagePicker() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        var userPickedImage: UIImage?
        if picker.sourceType == .camera {
            userPickedImage = info[.originalImage] as? UIImage
        } else if picker.sourceType == .photoLibrary {
            userPickedImage = info[.editedImage] as? UIImage
        }
        guard userPickedImage != nil else { fatalError("User picked image is nil") }
        
        // TODO: 1.Show picked image in picture collection  2. Convert image to NSData   3. Save the data
    }
}
