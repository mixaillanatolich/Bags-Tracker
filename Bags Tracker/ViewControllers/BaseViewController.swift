//
//  BaseViewController.swift
//  Bags Tracker
//
//  Created by Mixaill on 23.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showAlert(withTitle title: String?, andMessage message: String?, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            callback?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue,
                      sender: sender)
        if let prepareBlock = sender as? (UIViewController)->() {
            prepareBlock(segue.destination)
        }
    }
}
