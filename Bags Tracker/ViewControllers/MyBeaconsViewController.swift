//
//  MyBeaconsViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyBeaconsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var editedIndex: IndexPath? = nil
    
    var allBeacons = [BeaconModel]()
    var beacons = [BeaconModel]()
    var clBeacons = [BeaconCLModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
       // self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
    
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        self.editedIndex = indexPath
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let beacon = self.beacons[indexPath.row]
            StorageService.removeBeacon(beacon) { (error) in
                if let error = error {
                    self.showAlert(withTitle: error, andMessage: nil)
                } else {
                    self.beacons.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self.editedIndex = nil
            }
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
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
        if let index = beacons.firstIndex(where: {$0 == beacon}) {
            reloadCellFor(row: index)
        }
        
//        let deleteCellPath = IndexPath(item: Int(index), section: 0)
//        self.tableView.deleteRows(at: [deleteCellPath], with: .automatic)
    }
    
    func beaconUpdate(_ beacon: BeaconCLModel) {
        guard let index =  clBeacons.firstIndex(where: {$0 == beacon}) else {
            return
        }
        clBeacons[index] = beacon
        if let index = beacons.firstIndex(where: {$0 == beacon}) {
            reloadCellFor(row: index)
        }
    }
    
    fileprivate func reloadCellFor(row: Int) {
        let reloadCellPath = IndexPath(item: row, section: 0)
        if self.editedIndex != reloadCellPath {
            self.tableView.reloadRows(at: [reloadCellPath], with: .automatic)
        }
    }
}
