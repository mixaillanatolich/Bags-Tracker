//
//  SearchBeaconsByIdViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 15.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

class SearchBeaconsByIdViewController: UIViewController {

    var discoveredDevices = [String: BLEPeripheral]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BLEManager.setupDiscoveryDeviceCallback { (isNew, blePeripheral) in
            DispatchQueue.main.async {
                if isNew {
                    let addCellPath = IndexPath(item: Int(self.discoveredDevices.count), section: 0)
                    self.discoveredDevices[blePeripheral.uuid()] = blePeripheral
                    self.tableView.insertRows(at: [addCellPath], with: .automatic)
                } else {
                    self.discoveredDevices[blePeripheral.uuid()] = blePeripheral
                    let index = Array(self.discoveredDevices.keys).firstIndex(of: blePeripheral.uuid())
                    
                    let reloadCellPath = IndexPath(item: index!, section: 0)
                    if let cell = self.tableView.cellForRow(at: reloadCellPath) as? DiscoveredDeviceTableViewCell {
                        cell.deviceName.text = blePeripheral.peripheral.name ?? "Unknown"
                        cell.updateDevice(rssi: blePeripheral.rssi.intValue)
                    }
                }
            }
        }
          
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
              
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            
            if connectStatus == .ready {
                DispatchQueue.main.async {
                   // self.performSegue(withIdentifier: "ShowDeviceControlScreen", sender: self)
                }
            }
              
        }
     
        BLEManager.startDiscovery(serviceUUIDs: nil)
    }

    
    @IBAction func addByIdButtonClicked(_ sender: Any) {
        
        
    }

}

extension SearchBeaconsByIdViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        cell.resetContent()
        
        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!

        cell.deviceName.text = device.peripheral.name ?? "Unknown"
        cell.updateDevice(rssi: device.rssi.intValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
//        device.save()
//
//        discoveredDevices.removeValue(forKey: device.uuid)
//        allDevicesIds = DeviceModel.allDevices()
//        tableView.reloadData()
        
//        let device = discoveredDevices[Array(self.discoveredDevices.keys)[indexPath.row]]!
//
//        if BLEManager.isDiscovering() {
//            startScanButtonClicked(startScanButton!)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            // service [CBUUID(string: "FFE0")]
//            // characteristic [CBUUID(string: "FFE1")]
//            BLEManager.connectToDevice(device.peripheral, deviceType: .expectedDevice, serviceIds: [CBUUID(string: "FFE0")], characteristicIds: [CBUUID(string: "FFE1")], timeout: 10.0)
//        }
        
    }
}
