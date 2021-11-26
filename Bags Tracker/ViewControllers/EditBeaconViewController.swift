//
//  EditBeaconViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 27.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class EditBeaconViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
        
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var UUIDTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationEventsControl: MultiSelectSegmentedControl!
    
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
        
        notificationEventsControl.items = ["In Range", "Out Of Range", "Nearby"]
        notificationEventsControl.selectedSegmentIndex = 0
        notificationEventsControl.delegate = self
        
        notificationEventsControl.tintColor = .white
        notificationEventsControl.selectedSegmentIndexes = IndexSet(beacon.notificationEvents.map { $0.rawValue })
        //notificationEventsControl.selectedBackgroundColor = .systemOrange
        notificationEventsControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
        notificationEventsControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
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
        let notificationStateWasChanged = (beacon.isNotificationEnabled != notificationSwitch.isOn)
        beacon.isNotificationEnabled = notificationSwitch.isOn
        beacon.notificationEvents.removeAll()
        for item in notificationEventsControl.segments.enumerated().filter({ $1.isSelected }).map({ $0.offset }) {
            beacon.notificationEvents.append(NotificationEventType(rawValue: item)!)
        }
        
        if (notificationStateWasChanged) {
            BeaconService.stopMonitoring(beacons: [self.beacon])
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                BeaconService.startMonitoring(beacons: [self.beacon])
            }
        }
        
        StorageService.updateBeacon(beacon) { (error) in
            if let error = error {
                self.showAlert(withTitle: error, andMessage: nil)
            } else {
                self.closeButtonClicked(self)
            }
        }
    }
        
    @objc func onTouchGesture() {
        self.view.endEditing(true)
    }
    
    // buttons for testing cloud kit features
    @IBAction func button1Clicked(_ sender: Any) {
        //list
        
        
        CloudStorage.loadBeacons { (beacons, error) in
            dLog("beacons \(beacons.orNil)")
        }
    }
    
    @IBAction func button2Clicked(_ sender: Any) {
        //create
        
        
//        CloudStorage.createBeacon(beacon) { (error) in
//
//        }
    }
    
    @IBAction func button3Clicked(_ sender: Any) {
        //update
        
//        CloudStorage.updateBeacon(beacon) { (error) in
//
//        }
        
    }
    
    @IBAction func button4Clicked(_ sender: Any) {
        //delete
        
        CloudStorage.deleteBeacon(beacon) { (recordId, error) in
            dLog("record Id \(recordId.orNil)")
            dLog("error \(error.orNil)")
        }
    }
}

extension EditBeaconViewController: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        dLog("\(value) at \(index)")
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
