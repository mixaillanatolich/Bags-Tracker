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
    
//    var allDevicesIds = DeviceModel.allDevices()
//    var allDevices = [String: DeviceModel]()
//
//    var editedIndex: IndexPath? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var allBeacons = [BeaconModel]()
    var beacons = [BeaconModel]()
    var clBeacons = [BeaconCLModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // BLEManagerOld.startDiscovery(serviceUUIDs: [CBUUID.init(string: "0000")])
        
        BeaconService.run()
        
        BeaconService.setupDelegate(delegate: self)
        
        StorageService.loadBeacons { (beacons) in
            dLog("\(beacons)")
            BeaconService.startMonitoring(beacons: beacons)
            self.prepareBeaconsListAndShow()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        prepareBeaconsListAndShow()
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//
//        allDevicesIds = DeviceModel.allDevices()
//        tableView.reloadData()
//
//        BLEManagerOld.setupDiscoveryNodeCallback { (isNewDevice, device) in
//
//            DispatchQueue.main.async {
//                if self.allDevicesIds.contains(device.uuid) {
//                    self.allDevices[device.uuid] = device
//
//                    if let index = self.allDevicesIds.firstIndex(of: device.uuid) {
//                        let reloadCellPath = IndexPath(item: Int(index), section: 0)
//
//                        if self.editedIndex != reloadCellPath {
//                            self.tableView.reloadRows(at: [reloadCellPath], with: .automatic)
//                        }
//                    }
//
//                }
//            }
//        }
    }
    
    
    fileprivate func prepareBeaconsListAndShow() {
        allBeacons = StorageService.beacons
        beacons = allBeacons
        tableView.reloadData()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        //self.performSegue(withIdentifier: "ShowScanBLEDevicesScreen", sender: self)
        
        let alert = UIAlertController(title: "Add a new iBeacon", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add By UUID", style: .default, handler: { action in
            self.performSegue(withIdentifier: "ShowAddNewBeaconScreen", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Search By UUID", style: .default, handler: { action in
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        self.present(alert, animated: true)
    }

}

extension MyBeaconsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DiscoveredDeviceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        cell.resetCell()
        
        let beacon = beacons[indexPath.row]
        cell.deviceName.text = beacon.name
        
        if let clBeacon = clBeacons.first(where: { $0 == beacon }) {
            cell.updateInfo(clBeacon: clBeacon)
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

extension MyBeaconsViewController: BeaconServiceDelegate {
    func beaconFinded(_ beacon: BeaconCLModel) {
        clBeacons.append(beacon)
        
        tableView.reloadData()
    }
    
    func beaconLost(_ beacon: BeaconCLModel) {
        guard let index =  clBeacons.firstIndex(where: {$0 == beacon}) else {
            return
        }
        clBeacons.remove(at: index)
        
        tableView.reloadData()
    }
    
    func beaconUpdate(_ beacon: BeaconCLModel) {
        guard let index =  clBeacons.firstIndex(where: {$0 == beacon}) else {
            return
        }
        clBeacons[index] = beacon
        
        tableView.reloadData()
        
    }
}
