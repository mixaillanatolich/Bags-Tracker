//
//  BeaconServiceProtocol+Delegate.swift
//  Bags Tracker
//
//  Created by Mixaill on 23.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

protocol BeaconServiceProtocol {
    func run()
    func setupDelegate(delegate: BeaconDelegate?)
    func startMonitoring(beacons: [BeaconModel])
    func stopMonitoring(beacons: [BeaconModel])
}

protocol BeaconDelegate : NSObjectProtocol {
    func beaconFinded(_ beacon: BeaconCLModel)
    func beaconLost(_ beacon: BeaconCLModel)
    func beaconUpdate(_ beacon: BeaconCLModel)
}
