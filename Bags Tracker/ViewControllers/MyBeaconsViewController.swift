//
//  MyBeaconsViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyBeaconsViewController: UIViewController {
    
    var allDevicesIds = DeviceModel.allDevices()
    var allDevices = [String: DeviceModel]()
    
    var editedIndex: IndexPath? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // BLEManagerOld.startDiscovery(serviceUUIDs: [CBUUID.init(string: "0000")])
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        allDevicesIds = DeviceModel.allDevices()
        tableView.reloadData()
        
        BLEManagerOld.setupDiscoveryNodeCallback { (isNewDevice, device) in
            
            DispatchQueue.main.async {
                if self.allDevicesIds.contains(device.uuid) {
                    self.allDevices[device.uuid] = device
                    
                    if let index = self.allDevicesIds.firstIndex(of: device.uuid) {
                        let reloadCellPath = IndexPath(item: Int(index), section: 0)
                        
                        if self.editedIndex != reloadCellPath {
                            self.tableView.reloadRows(at: [reloadCellPath], with: .automatic)
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowScanBLEDevicesScreen", sender: self)
    }

}

extension MyBeaconsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDevicesIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        cell.resetCell()
        
        let deviceId = allDevicesIds[indexPath.row]
        cell.deviceName.text = deviceId
        
        if let device = allDevices[deviceId] {
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
        }
            
        return cell
    }
    

//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        self.editedIndex = indexPath
//
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//
//            let deviceId = self.allDevicesIds[indexPath.row]
//
//            if let device = self.allDevices[deviceId] {
//                device.remove()
//                self.allDevicesIds = DeviceModel.allDevices()
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        }
//        return [delete]
//    }
    
}
