//
//  PhotoCell.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-12-01.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var isAnimated = false
    
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
        plusButton.isHidden = false
        minusButton.isHidden = false
        
        isAnimated = true
    }
    
    func stopAnimate(){
        layer.removeAllAnimations()
        deleteBtn.isHidden = true
        plusButton.isHidden = true
        minusButton.isHidden = true
        isAnimated = false
    }
}
