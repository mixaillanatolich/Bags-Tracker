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
    var name: String
    var isNotificationEnabled = false
    var notificationEvents = [NotificationEventType]()
    
    init(uuid: String, name: String?, aIdentifier: String?, majorValue: NSNumber?, minorValue: NSNumber?) {
        let theIdentifier = aIdentifier ?? "\(uuid)+\(majorValue ?? 0)+\(minorValue ?? 0)".md5
        self.identifier = theIdentifier
        self.name = name ?? theIdentifier
        let uuid = UUID(uuidString: uuid) ?? UUID()
        super.init(uuid: uuid.uuidString, majorValue: majorValue, minorValue: minorValue)
    }
    
    convenience init(with model: BeaconRealmModel) {
        self.init(uuid: model.uuid,
                  name: model.name,
                  aIdentifier: model.identifier,
                  majorValue: NSNumber(value: model.major),
                  minorValue: NSNumber(value: model.minor))
        self.isNotificationEnabled = model.isNotificationEnabled
        for notificationEvent in model.notificationEvents {
            notificationEvents.append(NotificationEventType(rawValue: notificationEvent)!)
        }
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
        
        let beaconRegion = CLBeaconRegion(uuid: uuid,
                                          major: CLBeaconMajorValue(majorValue.intValue),
                                          minor: CLBeaconMinorValue(minorValue.intValue),
                                          identifier: identifier)
    
        beaconRegion.notifyOnExit = isNotificationEnabled
        beaconRegion.notifyOnEntry = isNotificationEnabled
        
        return beaconRegion
    }
    
    func notificationId(eventType: NotificationEventType) -> String {
        return identifier + eventType.notificationName()
    }
    
    public override var description: String {
        return "\nBeaconModel:\n\tidentifier: \(identifier)\n\tname: \(name)\n\tisNotificationEnabled: \(isNotificationEnabled)"
    }
}
