//
//  MyTableViewCell.swift
//  UICollectionView Practice
//
//  Created by DongMing on 2018-11-04.
//  Copyright © 2018 胡洞明. All rights reserved.
//

import UIKit
import SwipeCellKit

class MyTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var checkBox: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
