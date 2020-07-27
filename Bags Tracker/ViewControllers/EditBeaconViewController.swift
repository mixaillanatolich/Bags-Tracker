//
//  EditBeaconViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 27.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

class EditBeaconViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
        
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var UUIDTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    var beacon: BeaconModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(EditBeaconViewController.onTouchGesture))
        self.view.addGestureRecognizer(tap)
        
        nameTextField.text = beacon.name
        UUIDTextField.text = beacon.uuid.uuidString
        majorTextField.text = "\(beacon.majorValue!.intValue)"
        minorTextField.text = "\(beacon.minorValue!.intValue)"
        
        UUIDTextField.isUserInteractionEnabled = false
        majorTextField.isUserInteractionEnabled = false
        minorTextField.isUserInteractionEnabled = false
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
        
        beacon.name = name
        
        StorageService.updateBeacon(beacon) { (error) in
            if let error = error {
                self.showAlert(withTitle: error, andMessage: nil)
            } else {
                self.showAlert(withTitle: "iBeacon was updated successfully", andMessage: nil) {
                    self.closeButtonClicked(self)
                }
            }
        }
        
//
//        guard let uuidStr = UUIDTextField.text, !uuidStr.isEmpty else {
//            showAlert(withTitle: nil, andMessage: "Please enter Beacon Proximity UUID")
//            return
//        }
//        // FDA50693-A4E2-4FB1-AFCF-C6EB07647825
//        // E621E1F8-C36C-495A-93FC-0C247A3E6E5F
//        // fda50693-a4e2-4fb1-afcf-c6eb07647825
//        dLog("uuid str \(uuidStr.lowercased())")
//
//        guard let uuid = UUID(uuidString: uuidStr) else {
//            showAlert(withTitle: "Please enter valid Beacon Proximity UUID", andMessage: "Format of valid Beacon UUID: ffffffff-ffff-ffff-ffff-ffffffffffff")
//            return
//        }
//
//        guard let majorValue = majorTextField.text, majorValue.isNumeric, let major = Int(majorValue), major > 0, major < 65536 else {
//            showAlert(withTitle: nil, andMessage: "Please enter valid major value")
//            return
//        }
//
//        guard let minorValue = minorTextField.text, minorValue.isNumeric, let minor = Int(minorValue), minor > 0, minor < 65536 else {
//            showAlert(withTitle: nil, andMessage: "Please enter valid minor value")
//            return
//        }
//
//        let beacon = BeaconModel(uuid: uuid.uuidString, name: name, aIdentifier: nil, majorValue: NSNumber(value: major), minorValue: NSNumber(value: minor))
//
//        StorageService.saveBeacon(beacon) { (error) in
//            if let error = error {
//                self.showAlert(withTitle: error, andMessage: nil)
//            } else {
//                BeaconService.startMonitoring(beacons: [beacon])
//
//                self.showAlert(withTitle: "iBeacon was added successfully", andMessage: nil) {
//                    self.closeButtonClicked(self)
//                }
//            }
//        }

    }
        
    @objc func onTouchGesture() {
        self.view.endEditing(true)
    }
}

extension EditBeaconViewController: UITextFieldDelegate {
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
