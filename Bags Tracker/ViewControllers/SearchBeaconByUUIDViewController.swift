//
//  SearchBeaconByUUIDViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 08.09.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

class SearchBeaconByUUIDViewController: BaseViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var UUIDTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var clBeacons = [BeaconCLModel]()
    fileprivate var beaconForSearch: BeaconModel?
    
    fileprivate var uuid: String?
    fileprivate var major: Int?
    fileprivate var minor: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTouchGesture))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BeaconService.setupDelegate(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        removeKeyboardNotificationListeners()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        if let beacon = beaconForSearch {
            BeaconService.stopMonitoring(beacons: [beacon])
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        onTouchGesture()
        
        var aMajor: Int?
        var aMinor: Int?
        
        guard let uuidStr = UUIDTextField.text, !uuidStr.isEmpty else {
            showAlert(withTitle: nil, andMessage: "Please enter Beacon Proximity UUID")
            return
        }
           
        guard let uuid = UUID(uuidString: uuidStr) else {
            showAlert(withTitle: "Please enter valid Beacon Proximity UUID", andMessage: "Format of valid Beacon UUID: ffffffff-ffff-ffff-ffff-ffffffffffff")
            return
        }
        
        if let majorValue = majorTextField.text, !majorValue.isEmpty {
            guard majorValue.isNumeric, let major = Int(majorValue), major > 0, major < 65536 else {
                showAlert(withTitle: nil, andMessage: "Please enter valid major value")
                return
            }
            aMajor = major
        }
           
        if let minorValue = minorTextField.text, !minorValue.isEmpty {
            guard  minorValue.isNumeric, let minor = Int(minorValue), minor > 0, minor < 65536 else {
                showAlert(withTitle: nil, andMessage: "Please enter valid minor value")
                return
            }
            aMinor = minor
        }
        
        self.uuid = uuid.uuidString
        self.major = aMajor
        self.minor = aMinor
        
        if let beacon = beaconForSearch {
            BeaconService.stopMonitoring(beacons: [beacon])
        }
        
        beaconForSearch = BeaconModel(uuid: self.uuid!, name: nil, aIdentifier: nil,
                                 majorValue: major == nil ? nil : NSNumber(value: major!),
                                 minorValue: minor == nil ? nil : NSNumber(value: minor!))
        
        clBeacons.removeAll()
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            BeaconService.startMonitoring(beacons: [self.beaconForSearch!])
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: tableView) == true {
            return false
         }
         return true
    }
    
    @objc func onTouchGesture() {
        self.view.endEditing(true)
    }

}

extension SearchBeaconByUUIDViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == UIReturnKeyType.next) {
            if let next = textField.superview?.viewWithTag(textField.tag+1) as? UITextField {
                next.becomeFirstResponder()
                return false
            }
        }
        textField.resignFirstResponder()
        return false
    }
}

extension SearchBeaconByUUIDViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func updateCell(_ cell: DiscoveredDeviceTableViewCell, for indexPath: IndexPath) {
        cell.resetCell()
        let beacon = clBeacons[indexPath.row]
        let major = (beacon.majorValue != nil) ? "\(beacon.majorValue!)" : "n/a"
        let minor = (beacon.minorValue != nil) ? "\(beacon.minorValue!)" : "n/a"
        cell.deviceName.text = "Major: \(major) Minor: \(minor)"
        
        cell.updateInfo(clBeacon: beacon)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clBeacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell")! as! DiscoveredDeviceTableViewCell
        updateCell(cell, for: indexPath)
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beacon = clBeacons[indexPath.row]
        self.performSegue(withIdentifier: "ShowAddNewBeaconScreen", sender: { (destVC: UIViewController) in
            let vc = destVC as? AddBeaconByUUIDViewController
            vc?.theUuid = beacon.uuid.uuidString
            vc?.theMajor = (beacon.majorValue != nil) ? "\(beacon.majorValue!)" : nil
            vc?.theMinor = (beacon.minorValue != nil) ? "\(beacon.minorValue!)" : nil
        })
    }
}

extension SearchBeaconByUUIDViewController: BeaconServiceDelegate {
    
    fileprivate func isExpectedBeacon(_ beacon: BeaconCLModel) -> Bool {
        guard let theUuid = uuid else { return false }
        guard beacon.uuid.uuidString == theUuid else { return false }
        
        if let theMajor = major, let beaconMajor = beacon.majorValue {
            guard theMajor == beaconMajor.intValue else { return false}
        }
        
        if let theMinor = minor, let beaconMinor = beacon.minorValue {
            guard theMinor == beaconMinor.intValue else { return false}
        }
        
        return true
    }
    
    func beaconFinded(_ beacon: BeaconCLModel) {
        guard isExpectedBeacon(beacon) else { return }
        
        clBeacons.append(beacon)
        tableView.insertRows(at: [IndexPath(item: clBeacons.count-1, section: 0)], with: .automatic)
    }
    
    func beaconLost(_ beacon: BeaconCLModel) {

    }
    
    func beaconUpdate(_ beacon: BeaconCLModel) {
        if let index = clBeacons.firstIndex(where: {$0 == beacon}) {
            clBeacons[index] = beacon
            tableView.reloadData()
        } else {
            beaconFinded(beacon)
        }
    }
}
