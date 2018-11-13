//
//  SwipingController.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-12.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "pageCell"

class SwipingController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: - UICollectionViewDelegate

    // MARK: - Buttons Action
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
    }
    
    
    // MARK: - Delegate Flowlayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}
