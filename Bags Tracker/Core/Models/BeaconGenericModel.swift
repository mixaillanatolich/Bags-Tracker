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
    
}
