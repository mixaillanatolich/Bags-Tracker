//
//  ApplicationManager.swift
//  Bags Tracker
//
//  Created by Mixaill on 29.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

let UserDefaults = Foundation.UserDefaults.standard

let AppManager = ApplicationManager.sharedInstance

class ApplicationManager: NSObject {

    static let sharedInstance: ApplicationManager = {
        let instance = ApplicationManager()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
    var isRunningOnSimulator: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }()
    
}
