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
    
    var identifier: String?
    var timestamp: Date
    var proximity: CLProximity?
    var accuracy: CLLocationAccuracy?
    var rssi: Int?
    
    required init(clBeacon: CLBeacon) {
        timestamp = clBeacon.timestamp
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
        super.init(uuid: clBeacon.uuid.uuidString, majorValue: clBeacon.major, minorValue: clBeacon.minor)
        if let major = majorValue?.intValue, let minor = minorValue?.intValue {
            self.identifier = "\(uuid)+\(major)+\(minor)".md5
        }
    }
    
    required init(clBeaconRegion: CLBeaconRegion) {
        identifier = clBeaconRegion.identifier
        timestamp = Date()
        super.init(uuid: clBeaconRegion.uuid.uuidString, majorValue: clBeaconRegion.major, minorValue: clBeaconRegion.minor)
    }
    
    required init(uuid: String, majorValue: NSNumber?, minorValue: NSNumber?) {
        timestamp = Date()
        super.init(uuid: uuid, majorValue: majorValue, minorValue: minorValue)
        //self.identifier = "\(uuid)+\(majorValue!.intValue)+\(minorValue!.intValue)".md5
       // fatalError("init(uuid:majorValue:minorValue:) has not been implemented")
    }
    
    func updateWith(clBeacon: CLBeacon) {
        timestamp = clBeacon.timestamp
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
    }
    
    func updateWith(clBeaconRegion: CLBeaconRegion) {
        timestamp = Date()
        proximity = nil
        accuracy = nil
        rssi = nil
    }
    
    static func ==(item: BeaconCLModel, beacon: CLBeacon) -> Bool {
        return ((beacon.uuid.uuidString == item.uuid.uuidString))
            && (Int(truncating: beacon.major) == Int(truncating: item.majorValue ?? 0))
            && (Int(truncating: beacon.minor) == Int(truncating: item.minorValue ?? 0))
    }

    static func ==(item: BeaconCLModel, beacon: CLBeaconRegion) -> Bool {
        return ((beacon.uuid.uuidString == item.uuid.uuidString))
            && (Int(truncating: beacon.major ?? -1) == Int(truncating: item.majorValue ?? 0))
            && (Int(truncating: beacon.minor ?? -1) == Int(truncating: item.minorValue ?? 0))
    }
}

