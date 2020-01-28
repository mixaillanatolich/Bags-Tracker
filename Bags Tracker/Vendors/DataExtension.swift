//
//  DataExtension.swift
//  Bags Tracker
//
//  Created by Mixaill on 25.01.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

public extension Data {

    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}
