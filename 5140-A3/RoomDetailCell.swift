//
//  RoomDetailCell.swift
//  5140-A3
//
//  Created by 一川 黄 on 27/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit

class RoomDetailCell: UITableViewCell {

    @IBOutlet var roomNameLabel: UILabel!
    @IBOutlet var plantLabel: UILabel!
    @IBOutlet var aveTempLabel: UILabel!
    @IBOutlet var aveHumidityLabel: UILabel!
    @IBOutlet var waterLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
