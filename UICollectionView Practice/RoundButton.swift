//
//  RoundButton.swift
//  UICollectionView Practice
//
//  Created by 胡洞明 on 2018/9/26.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        print("button bounds size: \(bounds.size)")
//        layer.cornerRadius = 0.5 * layer.bounds.width
        layer.masksToBounds = true
//        clipsToBounds = true
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        layer.cornerRadius = 0.5 * layer.bounds.width
    }
    override var isHighlighted: Bool {
        didSet{
            if isHighlighted { alpha = 0.5 } else { alpha = 1 }
        }
    }

}
