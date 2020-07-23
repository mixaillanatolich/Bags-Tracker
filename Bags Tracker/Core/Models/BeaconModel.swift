//
//  BeaconModel.swift
//  Bags Tracker
//
//  Created by Mixaill on 16.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconModel: BeaconGenericModel {
    let identifier: String
    
    init(uuid: String, aIdentifier: String?, majorValue: NSNumber?, minorValue: NSNumber?) {
        self.identifier = aIdentifier ?? UUID().uuidString
        super.init(uuid: UUID(uuidString: uuid)!.uuidString, majorValue: majorValue, minorValue: minorValue)
    }
    
    convenience init(with model: BeaconRealmModel) {
        self.init(uuid: model.uuid,
                  aIdentifier: model.identifier,
                  majorValue: NSNumber(value: model.major),
                  minorValue: NSNumber(value: model.minor))
    }
    
    required init(uuid: String, majorValue: NSNumber?, minorValue: NSNumber?) {
        fatalError("init(uuid:majorValue:minorValue:) has not been implemented")
    }
    
    func beaconRegion() -> CLBeaconRegion {
        guard let majorValue = majorValue else {
            return CLBeaconRegion(uuid: uuid, identifier: identifier)
        }
        
        guard let minorValue = minorValue else {
            return CLBeaconRegion(uuid: uuid, major: CLBeaconMajorValue(majorValue.intValue), identifier: identifier)
        }
    
        return CLBeaconRegion(uuid: uuid,
                              major: CLBeaconMajorValue(majorValue.intValue),
                              minor: CLBeaconMinorValue(minorValue.intValue),
                              identifier: identifier)
    }
    
}
