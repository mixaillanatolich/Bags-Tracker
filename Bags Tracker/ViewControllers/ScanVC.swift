//
//  ScanVC.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanVC: UIViewController {

    var discoveredDevices = [String: DeviceModel]()
    var allDevicesIds = DeviceModel.allDevices()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     BLEManager.startDiscovery(serviceUUIDs: [CBUUID.init(string: "0000")])
        
        BLEManagerOld.setupDiscoveryNodeCallback { (isNewDevice, device) in
            
            DispatchQueue.main.async {
                
                if !self.allDevicesIds.contains(device.uuid) {
                    
                    if let _ = self.discoveredDevices[device.uuid] {
                        self.discoveredDevices[device.uuid] = device
                        let index = Array(self.discoveredDevices.keys).firstIndex(of: device.uuid)
                        
                        let reloadCellPath = IndexPath(item: index!, section: 0)
                        self.tableView.reloadRows(at: [reloadCellPath], with: .automatic)
                        
                    } else {
                        let addCellPath = IndexPath(item: Int(self.discoveredDevices.count), section: 0)
                        self.discoveredDevices[device.uuid] = device
                        self.tableView.insertRows(at: [addCellPath], with: .automatic)
                    }
                }
            }
            
           // device.temperature()
            
        }
        
    }


}

extension ScanVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        cell.resetCell()
        
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!

        cell.deviceName.text = device.name
        let peripheralRSSI = device.rssi
        cell.rssiLabel.text = "RSSI: \(peripheralRSSI)"
        
        if (peripheralRSSI.intValue > -55) {
            cell.signalLevelIndicator5.backgroundColor=UIColor.black
        }
        if (peripheralRSSI.intValue > -65) {
            cell.signalLevelIndicator4.backgroundColor=UIColor.black
        }
        if (peripheralRSSI.intValue > -75) {
            cell.signalLevelIndicator3.backgroundColor=UIColor.black
        }
        if (peripheralRSSI.intValue > -85) {
            cell.signalLevelIndicator2.backgroundColor=UIColor.black
        }
        if (peripheralRSSI.intValue > -95) {
            cell.signalLevelIndicator1.backgroundColor=UIColor.black
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
        device.save()
        
        discoveredDevices.removeValue(forKey: device.uuid)
        allDevicesIds = DeviceModel.allDevices()
        tableView.reloadData()
    }
}

