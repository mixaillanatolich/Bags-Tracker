//
//  BeaconCLModel.swift
//  Bags Tracker
//
//  Created by Mixaill on 17.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconCLModel: BeaconGenericModel {
    
    var timestamp: Date
    var proximity: CLProximity
    var accuracy: CLLocationAccuracy
    var rssi: Int
    
    required init(clBeacon: CLBeacon) {
        timestamp = clBeacon.timestamp
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
        super.init(uuid: clBeacon.uuid.uuidString, majorValue: clBeacon.major, minorValue: clBeacon.minor)
    }
    
    required init(uuid: String, majorValue: NSNumber?, minorValue: NSNumber?) {
        fatalError("init(uuid:majorValue:minorValue:) has not been implemented")
    }
    
    func updateWith(clBeacon: CLBeacon) {
        timestamp = clBeacon.timestamp
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
    }
    
//    static func ==(item: BeaconCLModel, beacon: CLBeacon) -> Bool {
//        return ((beacon.uuid.uuidString == item.uuid.uuidString))
//            && (Int(truncating: beacon.major) == Int(truncating: item.majorValue ?? 0))
//            && (Int(truncating: beacon.minor) == Int(truncating: item.minorValue ?? 0))
//    }

}
