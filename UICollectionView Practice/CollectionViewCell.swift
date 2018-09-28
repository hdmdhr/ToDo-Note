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
    
    var isAnimate = false
    
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
        deleteBtn.isHidden = false
        isAnimate = true
    }
    
    func stopAnimate(){
        layer.removeAllAnimations()
        deleteBtn.isHidden = true
        isAnimate = false
    }
}
