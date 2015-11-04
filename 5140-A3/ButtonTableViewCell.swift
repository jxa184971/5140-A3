//
//  ButtonTableViewCell.swift
//  5140-A3
//
//  Created by 一川 黄 on 25/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet var buttonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
