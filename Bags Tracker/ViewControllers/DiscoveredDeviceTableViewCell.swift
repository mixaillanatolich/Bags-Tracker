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
    
    func updateDeviceRSSI(rssi: Int) {
//        resetCell()
//
//        rssiLabel.text = "RSSI: \(rssi)"
        
        if (rssi > -55) {
            signalLevelIndicator5.backgroundColor=UIColor.systemBlue
        }
        if (rssi > -65) {
            signalLevelIndicator4.backgroundColor=UIColor.systemBlue
        }
        if (rssi > -75) {
            signalLevelIndicator3.backgroundColor=UIColor.systemBlue
        }
        if (rssi > -85) {
            signalLevelIndicator2.backgroundColor=UIColor.systemBlue
        }
        if (rssi > -95) {
            signalLevelIndicator1.backgroundColor=UIColor.systemBlue
        }
    }
    
    func updateInfo(clBeacon: BeaconCLModel) {
        
        var rssiStr = "n/a"
        if let rssi = clBeacon.rssi, rssi != 0 {
            updateDeviceRSSI(rssi: rssi)
            rssiStr = "\(rssi)"
        }
        
        var distance: String
        switch clBeacon.proximity {
        case .unknown:
            distance = "Unknown"
        case .far:
            distance = "Far"
        case .immediate:
            distance = "Immediate"
        case .near:
            distance = "Near"
        case .none:
            distance = "None"
        @unknown default:
            distance = "Unknown"
        }
        
        rssiLabel.text = "RSSI: \(rssiStr),  Distance: \(distance)"
        
    }
    
}
