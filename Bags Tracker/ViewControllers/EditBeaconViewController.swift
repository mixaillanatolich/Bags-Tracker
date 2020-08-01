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
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationEventControl: UISegmentedControl!
    
    var beacon: BeaconModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(EditBeaconViewController.onTouchGesture))
        self.view.addGestureRecognizer(tap)
        
        nameTextField.text = beacon.name
        UUIDTextField.text = beacon.uuid.uuidString
        majorTextField.text = "\(beacon.majorValue!.intValue)"
        minorTextField.text = "\(beacon.minorValue!.intValue)"
        
        notificationSwitch.isOn = beacon.isNotificationEnabled
        notificationEventControl.selectedSegmentIndex = beacon.notificationEvent.rawValue
        
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
        beacon.isNotificationEnabled = notificationSwitch.isOn
        beacon.notificationEvent = NotificationEventType(rawValue: notificationEventControl.selectedSegmentIndex)!
        
        StorageService.updateBeacon(beacon) { (error) in
            if let error = error {
                self.showAlert(withTitle: error, andMessage: nil)
            } else {
                self.showAlert(withTitle: "iBeacon was updated successfully", andMessage: nil) {
                    self.closeButtonClicked(self)
                }
            }
        }

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
