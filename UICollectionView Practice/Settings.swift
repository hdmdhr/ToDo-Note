//
//  Settings.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-01.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import Foundation
import ChameleonFramework

struct Settings {
    static let palletHex: [String] =
        [         FlatPink().hexValue(),
                  FlatWatermelon().hexValue(),
                  FlatOrange().hexValue(),
                  FlatYellow().hexValue(),
                  FlatGreen().hexValue(),
                  FlatLime().hexValue(),
                  FlatSkyBlue().hexValue(),
                  FlatMagenta().hexValue(),
                  FlatPurple().hexValue()]
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
