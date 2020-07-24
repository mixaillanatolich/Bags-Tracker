//
//  RealmDbProtocol.swift
//  Bags Tracker
//
//  Created by Mixaill on 24.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

enum RealmOpStatus {
    case unknown
    case success
    case fail
    case error
}

protocol RealmDbProtocol {
    func cleanupDb(callback: @escaping () -> Void);
    func createBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void)
    func updateBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void)
    func removeBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void)
    func beacons(result: @escaping ([BeaconRealmModel], RealmOpStatus) -> Void)
}
