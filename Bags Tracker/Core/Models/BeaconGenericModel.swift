//
//  BeaconGenericModel.swift
//  Bags Tracker
//
//  Created by Mixaill on 17.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

class BeaconGenericModel: NSObject {

    let uuid: UUID
    let majorValue: NSNumber?
    let minorValue: NSNumber?
    
    required init(uuid: String, majorValue: NSNumber?, minorValue: NSNumber?) {
        self.uuid = UUID(uuidString: uuid)!
        self.majorValue = majorValue
        self.minorValue = minorValue
    }
    
    static func ==(item: BeaconGenericModel, beacon: BeaconGenericModel) -> Bool {
        return ((beacon.uuid.uuidString == item.uuid.uuidString))
            && (Int(truncating: beacon.majorValue ?? 0) == Int(truncating: item.majorValue ?? 0))
            && (Int(truncating: beacon.minorValue ?? 0) == Int(truncating: item.minorValue ?? 0))
    }
    
}
