//
//  AddBeaconByUUIDViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 23.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

class AddBeaconByUUIDViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var UUIDTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(AddBeaconByUUIDViewController.onTouchGesture))
        self.view.addGestureRecognizer(tap)
        
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
        
        
        
        
        //todo check fields
        
        //todo add beacon to store
        
        //todo start search ibeacon
        
        
    }
    
    @objc func onTouchGesture() {
        self.view.endEditing(true)
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
