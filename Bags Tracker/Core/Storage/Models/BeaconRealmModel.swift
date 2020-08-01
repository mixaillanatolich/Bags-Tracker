//
//  BeaconRealmModel.swift
//  Bags Tracker
//
//  Created by Mixaill on 16.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import RealmSwift

class BeaconRealmModel: Object {
    @objc dynamic var uuid: String = ""
    @objc dynamic var identifier: String = ""
    @objc dynamic var major: Int = 0
    @objc dynamic var minor: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var isNotificationEnabled = false
    @objc dynamic var notificationEvent: Int = 0
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    required init() {
        super.init()
    }
    
    init(with beaconModel:BeaconModel) {
        self.uuid = beaconModel.uuid.uuidString
        self.major = beaconModel.majorValue!.intValue
        self.minor = beaconModel.minorValue!.intValue
        self.identifier = "\(uuid)+\(major)+\(minor)".md5
        self.name = beaconModel.name
        self.isNotificationEnabled = beaconModel.isNotificationEnabled
        self.notificationEvent = beaconModel.notificationEvent.rawValue
        super.init()
    }
    
//    init(with name: String, uuid: String, major: Int, minor: Int) {
//        self.name = name
//        self.uuid = uuid
//        self.major = major
//        self.minor = minor
//        self.identifier = "\(uuid)+\(major)+\(minor)".md5
//        super.init()
//    }
    
    func paramsForModify() -> [String : Any] {
        var params = [String : Any]()
        params["identifier"] = identifier
        params["name"] = name
        params["isNotificationEnabled"] = isNotificationEnabled
        params["notificationEvent"] = notificationEvent
        return params
    }
}
