//
//  AddBeaconByUUIDViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 23.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class AddBeaconByUUIDViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var UUIDTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationEventsControl: MultiSelectSegmentedControl!
    
    var theUuid: String?
    var theMajor: String?
    var theMinor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(AddBeaconByUUIDViewController.onTouchGesture))
        self.view.addGestureRecognizer(tap)
        
        notificationEventsControl.items = ["In Range", "Out Of Range", "Nearby"]
        notificationEventsControl.selectedSegmentIndex = 0
        notificationEventsControl.delegate = self
        
        notificationEventsControl.tintColor = .white
        //notificationEventsControl.selectedBackgroundColor = .systemOrange
        notificationEventsControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
        notificationEventsControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        UUIDTextField.text = theUuid
        majorTextField.text = theMajor
        minorTextField.text = theMinor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifcationListenerForScrollView(scrollView)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        removeKeyboardNotificationListeners()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(withTitle: nil, andMessage: "Please enter Beacon name")
            return
        }
        
        guard let uuidStr = UUIDTextField.text, !uuidStr.isEmpty else {
            showAlert(withTitle: nil, andMessage: "Please enter Beacon Proximity UUID")
            return
        }
        // FDA50693-A4E2-4FB1-AFCF-C6EB07647825
        // E621E1F8-C36C-495A-93FC-0C247A3E6E5F
        // fda50693-a4e2-4fb1-afcf-c6eb07647825
        dLog("uuid str \(uuidStr.lowercased())")
        
        guard let uuid = UUID(uuidString: uuidStr) else {
            showAlert(withTitle: "Please enter valid Beacon Proximity UUID", andMessage: "Format of valid Beacon UUID: ffffffff-ffff-ffff-ffff-ffffffffffff")
            return
        }
        
        guard let majorValue = majorTextField.text, majorValue.isNumeric, let major = Int(majorValue), major > 0, major < 65536 else {
            showAlert(withTitle: nil, andMessage: "Please enter valid major value")
            return
        }
        
        guard let minorValue = minorTextField.text, minorValue.isNumeric, let minor = Int(minorValue), minor > 0, minor < 65536 else {
            showAlert(withTitle: nil, andMessage: "Please enter valid minor value")
            return
        }
        
        let beacon = BeaconModel(uuid: uuid.uuidString, name: name, aIdentifier: nil, majorValue: NSNumber(value: major), minorValue: NSNumber(value: minor))
        beacon.isNotificationEnabled = notificationSwitch.isOn
     //   beacon.notificationEvent = NotificationEventType(rawValue: notificationEventControl.selectedSegmentIndex)!
        
        for item in notificationEventsControl.segments.enumerated().filter({ $1.isSelected }).map({ $0.offset }) {
            beacon.notificationEvents.append(NotificationEventType(rawValue: item)!)
        }
        
        StorageService.saveBeacon(beacon) { (error) in
            if let error = error {
                self.showAlert(withTitle: error, andMessage: nil)
            } else {
                BeaconService.startMonitoring(beacons: [beacon])
                
                self.showAlert(withTitle: "iBeacon was added successfully", andMessage: nil) {
                    self.closeButtonClicked(self)
                }
            }
        }

    }
    
    @objc func onTouchGesture() {
        self.view.endEditing(true)
    }
}

extension AddBeaconByUUIDViewController: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        dLog("\(value) at \(index)")
    }
}

extension AddBeaconByUUIDViewController: UITextFieldDelegate {
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
