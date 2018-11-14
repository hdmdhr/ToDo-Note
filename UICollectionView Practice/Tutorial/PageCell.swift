//
//  PageCell.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-12.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit
import ChameleonFramework

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet{
            guard let page = page else { return }
            pageImage.image = UIImage(named: page.imageName)
            headerLabel.text = page.headerText
            bodyTextView.text = page.bodyText
            pageControl.currentPage = page.currentPage
        }
    }
    
    @IBOutlet weak var pageImage: UIImageView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
}
