//
//  NearbyDevicesViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 20/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class NearbyDevicesViewController: UIViewController {

    var discoveredDevices = [String: DeviceModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BLEManager.startDiscovery(serviceUUIDs: [CBUUID.init(string: "0000")])
        
        BLEManager.setupDiscoveryNodeCallback { (isNewDevice, device) in
            
            DispatchQueue.main.async {
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
    }

}

extension NearbyDevicesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        cell.resetCell()
        
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
        
        cell.deviceName.text = device.name
        let peripheralRSSI = device.rssi
        cell.rssiLabel.text = "RSSI: \(peripheralRSSI)   temperature: \(device.temperature() ?? "n/a") C"
        
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

}
