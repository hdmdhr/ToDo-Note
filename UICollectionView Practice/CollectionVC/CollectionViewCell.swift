//
//  CollectionViewCell.swift
//  UICollectionView Practice
//
//  Created by 胡洞明 on 2018/9/25.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var roundBtn: RoundButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var changeColorBtn: UIButton!
    
    @IBOutlet weak var plusBtn: UIButton!
    
    @IBOutlet weak var minusBtn: UIButton!
    
    var isAnimate = false
    
    override func awakeFromNib() {
        //        print("cell size: \(bounds.size)")
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = size.height
//        layoutAttributes.frame = frame
//        
//        return layoutAttributes
//    }
    
    func startAnimate() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.15
        shakeAnimation.repeatCount = 99999
        shakeAnimation.autoreverses = true
        
        let startAngle = 2 * Double.pi / 180
        let stopAngle = -startAngle
        
        shakeAnimation.fromValue = startAngle
        shakeAnimation.toValue = stopAngle * 3
        shakeAnimation.timeOffset = 290 * drand48()
        
        layer.add(shakeAnimation, forKey: "animate")
        
        if roundBtn.currentTitle != "+" {
            deleteBtn.isHidden = false
            changeColorBtn.isHidden = false
            plusBtn.isHidden = false
            minusBtn.isHidden = false
        } else {
            deleteBtn.isHidden = true
            changeColorBtn.isHidden = true
            plusBtn.isHidden = false
            minusBtn.isHidden = false
        }
        isAnimate = true
    }
    
    func stopAnimate(){
        layer.removeAllAnimations()
        deleteBtn.isHidden = true
        changeColorBtn.isHidden = true
        plusBtn.isHidden = true
        minusBtn.isHidden = true
        isAnimate = false
    }
}
