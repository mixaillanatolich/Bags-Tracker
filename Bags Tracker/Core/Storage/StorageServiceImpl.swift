//
//  StorageServiceImpl.swift
//  Bags Tracker
//
//  Created by Mixaill on 24.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

let StorageService = StorageServiceImpl.sharedInstance

class StorageServiceImpl: NSObject {
    
    var beacons = [BeaconModel]()
    
    static let sharedInstance: StorageServiceImpl = {
        let instance = StorageServiceImpl()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
    func loadBeacons(callback: @escaping ([BeaconModel]) -> Void) {
        RealmDbService.beacons { (realmBeacons, opStatus) in
            if opStatus == .success {
                var beaconsArr = [BeaconModel]()
                for realmBeacon in realmBeacons {
                    beaconsArr.append(BeaconModel(with: realmBeacon))
                }
                DispatchQueue.main.async {
                    self.beacons = beaconsArr
                    callback(self.beacons)
                }
            }
        }
    }
    
    func saveBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        
        guard self.beacons.firstIndex(where: { $0 == beacon }) == nil else {
            callback("iBeacon Already Exist")
            return
        }
        
//        for theBeacon in beacons {
//            dLog("0: \(theBeacon == beacon)")
//            dLog("1: \(beacon.uuid.uuidString == theBeacon.uuid.uuidString)")
//            dLog("2: \(Int(truncating: beacon.majorValue ?? 0) == Int(truncating: theBeacon.majorValue ?? 0))")
//            dLog("3: \(Int(truncating: beacon.majorValue ?? 0) == Int(truncating: theBeacon.minorValue ?? 0))")
//        }
        
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.createBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    self.beacons.append(beacon)
                    callback(nil)
                } else if status == .error {
                    callback("Error on save iBeacon")
                } else if status == .fail {
                    callback("Fail on save iBeacon")
                }
            }
        }
        
    }
    
    func updateBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.updateBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    if let index = self.beacons.firstIndex(where: { $0 == beacon }) {
                        self.beacons.remove(at: index)
                    }
                    self.beacons.append(beacon)
                    callback(nil)
                } else if status == .error {
                    callback("Error on update iBeacon")
                } else if status == .fail {
                    callback("Fail on update iBeacon")
                }
            }
        }
        
    }
    
    func removeBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.removeBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    if let index = self.beacons.firstIndex(where: { $0 == beacon }) {
                        self.beacons.remove(at: index)
                    }
                    callback(nil)
                } else if status == .error {
                    callback("Error on remove iBeacon")
                } else if status == .fail {
                    callback("Fail on remove iBeacon")
                }
            }
        }
        
    }
}
