//
//  NearbyDevicesViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 20/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class NearbyDevicesViewController: UIViewController {

    var discoveredDevices = [String: DeviceModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BLEManagerOld.startDiscovery(serviceUUIDs: [CBUUID.init(string: "0000")])
        
        Analytics.logEvent("start_discovery_devices", parameters: [
            "device": UUID().uuidString,
            "some_key": "a_value"
        ])
    
        
        BLEManagerOld.setupDiscoveryNodeCallback { (isNewDevice, device) in
            
            Analytics.logEvent("device_discovered", parameters: [
                "device": device.uuid,
                "name": device.name,
                "rssi": device.rssi
            ])
            
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

    @IBAction func closeButtonClicked(_ sender: Any) {
        
     //   fatalError()

        
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
            cell.signalLevelIndicator5.backgroundColor=UIColor.blue
        }
        if (peripheralRSSI.intValue > -65) {
            cell.signalLevelIndicator4.backgroundColor=UIColor.blue
        }
        if (peripheralRSSI.intValue > -75) {
            cell.signalLevelIndicator3.backgroundColor=UIColor.blue
        }
        if (peripheralRSSI.intValue > -85) {
            cell.signalLevelIndicator2.backgroundColor=UIColor.blue
        }
        if (peripheralRSSI.intValue > -95) {
            cell.signalLevelIndicator1.backgroundColor=UIColor.blue
        }
        
        
        return cell
    }

}
