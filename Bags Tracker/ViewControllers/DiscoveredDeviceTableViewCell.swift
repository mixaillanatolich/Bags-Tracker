//
//  DiscoveredDeviceTableViewCell.swift
//  Bags Tracker
//
//  Created by Mixaill on 17/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit

class DiscoveredDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
   // @IBOutlet weak var servicesLabel: UILabel!
   // @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var signalLevelIndicator1: UIView!
    @IBOutlet weak var signalLevelIndicator2: UIView!
    @IBOutlet weak var signalLevelIndicator3: UIView!
    @IBOutlet weak var signalLevelIndicator4: UIView!
    @IBOutlet weak var signalLevelIndicator5: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func resetCell() {
        
        rssiLabel.text = "RSSI: n/a"
        
        signalLevelIndicator5.backgroundColor=UIColor.lightGray
        signalLevelIndicator4.backgroundColor=UIColor.lightGray
        signalLevelIndicator3.backgroundColor=UIColor.lightGray
        signalLevelIndicator2.backgroundColor=UIColor.lightGray
        signalLevelIndicator1.backgroundColor=UIColor.lightGray
    }
    
}
