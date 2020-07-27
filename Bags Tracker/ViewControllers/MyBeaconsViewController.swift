//
//  MyBeaconsViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

enum FilterType: Int {
    case all = 0
    case nearby = 1
    case sorting = 2
}

class MyBeaconsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterBeaconsControl: UISegmentedControl!
    
    var editedIndex: IndexPath? = nil
    
    var allBeacons = [BeaconModel]()
    var beacons = [BeaconModel]()
    var clBeacons = [BeaconCLModel]()
    
    var currentFilterId: FilterType = .all
    
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
        
        switch currentFilterId {
        case .all:
            beacons = allBeacons
        case .nearby:
            beacons = allBeacons.filter({ (aBeacon) -> Bool in
                clBeacons.firstIndex(where: { $0 == aBeacon}) != nil
            })
//        case .sorting:
//            beacons = allBeacons
        default:
            beacons = allBeacons
        }
        
        tableView.reloadData()
    }
    
    @IBAction func filterBeaconsControlChanged(_ sender: Any) {
        currentFilterId = FilterType(rawValue: filterBeaconsControl.selectedSegmentIndex)!
        prepareBeaconsListAndShow()
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

    fileprivate func updateCell(_ cell: DiscoveredDeviceTableViewCell, for indexPath: IndexPath) {
        cell.resetCell()
        
        let beacon = beacons[indexPath.row]
        cell.deviceName.text = beacon.name
        
        if let clBeacon = clBeacons.first(where: { $0 == beacon }) {
            cell.updateInfo(clBeacon: clBeacon)
        }
    }
    
}

extension MyBeaconsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        updateCell(cell, for: indexPath)
            
        return cell
    }
    
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard currentFilterId == .all else { return nil}
        
        self.editedIndex = indexPath
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let beacon = self.beacons[indexPath.row]
            BeaconService.stopMonitoring(beacons: [beacon])
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}

extension MyBeaconsViewController: BeaconServiceDelegate {
    func beaconFinded(_ beacon: BeaconCLModel) {
        clBeacons.append(beacon)
        
        switch currentFilterId {
        case .all:
            if let index = beacons.firstIndex(where: {$0 == beacon}) {
                reloadCellFor(row: index)
            }
        case .nearby:
            if let theBeacon = allBeacons.first(where: {$0 == beacon}) {
                beacons.append(theBeacon)
                self.tableView.insertRows(at: [IndexPath(item: beacons.count-1, section: 0)], with: .automatic)
            }
        default:
            beacons = allBeacons
        }
    }
    
    func beaconLost(_ beacon: BeaconCLModel) {
        guard let index =  clBeacons.firstIndex(where: {$0 == beacon}) else {
            return
        }
        clBeacons.remove(at: index)
        
        switch currentFilterId {
        case .all:
            if let index = beacons.firstIndex(where: {$0 == beacon}) {
                reloadCellFor(row: index)
            }
        case .nearby:
            if let index = beacons.firstIndex(where: {$0 == beacon}) {
                beacons.remove(at: index)
                let deleteCellPath = IndexPath(item: Int(index), section: 0)
                tableView.deleteRows(at: [deleteCellPath], with: .automatic)
            }
        default:
            beacons = allBeacons
        }

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
//        if editedIndex != reloadCellPath {
//            tableView.reloadRows(at: [reloadCellPath], with: .automatic)
//        }
        
        if let cell = tableView.cellForRow(at: reloadCellPath) as? DiscoveredDeviceTableViewCell {
            updateCell(cell, for: reloadCellPath)
        }
    }
}
