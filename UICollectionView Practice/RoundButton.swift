//
//  RoundButton.swift
//  UICollectionView Practice
//
//  Created by 胡洞明 on 2018/9/26.
//  Copyright © 2018年 胡洞明. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 0.5 * bounds.height
        layer.masksToBounds = true
//        clipsToBounds = true
    }
    
    override var isHighlighted: Bool {
        didSet{
            if isHighlighted { alpha = 0.5 } else { alpha = 1 }
        }
    }

}
