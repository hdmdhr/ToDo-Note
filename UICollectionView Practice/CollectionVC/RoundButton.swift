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
        layer.masksToBounds = true
//        clipsToBounds = true
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        layer.cornerRadius = 0.25 * layer.bounds.width
    }

}

extension UIButton {
    override open var isHighlighted: Bool {
        didSet{
            if isHighlighted { alpha = 0.5 } else { alpha = 1 }
        }
    }
}
