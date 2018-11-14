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
    
    let pages = [
        Page(imageName: "color-wheel", headerText: "Tap On + To Add A New Category!", bodyText: "Long Press to modify existing categories,\nLong Press and drag to change orders.", currentPage: 0),
        Page(imageName: "plus", headerText: "Add Something New To Do!", bodyText: "Swipe to Left to configure or delete,\nLong Press to rearrange orders.", currentPage: 1),
        Page(imageName: "crossed", headerText: "Record Your Accomplishment!", bodyText: "You can always come back later to modify\nor make changes to your notes.", currentPage: 2)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView?.isPagingEnabled = true


        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    override func viewWillAppear(_ animated: Bool) {
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
        return pages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
    
        let page = pages[indexPath.item]
        cell.page = page
        
        return cell
    }

    // MARK: - UICollectionViewDelegate

    // MARK: - Buttons Action
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { fatalError("cannot find index") }
        let prePage = max(hitIndex.item - 1, 0)
        let preIndex = IndexPath(item: prePage, section: 0)
        collectionView.scrollToItem(at: preIndex, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        guard let hitIndex = collectionView.indexPathForItem(at: hitPoint) else { fatalError("cannot find index") }
        let nextPage = min(hitIndex.item + 1, pages.count - 1)
        let nextIndex = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: nextIndex, at: .centeredHorizontally, animated: true)
    }
    
    
    // MARK: - Delegate Flowlayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height)
    }
    
}
