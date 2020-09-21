//
//  StorageServiceImpl.swift
//  Bags Tracker
//
//  Created by Mixaill on 24.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation

enum CloudSyncStatusType: Int {
    case none = 0
    case create = 1
    case update = 2
    case delete = 3
    case synced = 4
}

let StorageService = StorageServiceImpl.sharedInstance

class StorageServiceImpl: NSObject {
    
    var beacons = [BeaconModel]()
    var removedBeacons = [BeaconModel]()
    
    static let sharedInstance: StorageServiceImpl = {
        let instance = StorageServiceImpl()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
    //MARK: - api
    func loadBeacons(callback: @escaping ([BeaconModel]) -> Void) {
        self.localBeacons { (beacons) in
            DispatchQueue.main.async {
                self.beacons = beacons.filter( { $0.cloudSyncStatus != .delete })
                self.removedBeacons = beacons.filter( { $0.cloudSyncStatus == .delete })
                
                callback(self.beacons)
                
                DispatchQueue.global(qos: .background).async {
                    self.syncDbWithCloud()
                }
            }
        }
    }
    
    func beaconBy(id: String, callback: @escaping (BeaconModel?) -> Void) {
        RealmDbService.beaconBy(identifier: id) { (realmBeacon) in
            guard let beacon = realmBeacon else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                return
            }
            let theBeacon = BeaconModel(with: beacon)
            DispatchQueue.main.async {
                callback(theBeacon)
            }
        }
    }
    
    func createBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        
        if let removedBeacon = self.removedBeacons.filter( { $0 == beacon} ).first {
            dLog("restore beacon from removed")
            removedBeacon.cloudSyncStatus = .create
            removedBeacon.lastModified = Date()
            updateLocal(beacon: removedBeacon) { (error) in
                guard error == nil else {
                    callback(error)
                    return
                }
                self.beacons.append(removedBeacon)
                if let index = self.removedBeacons.firstIndex(where: { $0 == beacon }) {
                    self.removedBeacons.remove(at: index)
                }
                callback(nil)
                
                self.syncCreateWithCloud(beacon: beacon)
            }
            return
        }
        
        guard self.beacons.firstIndex(where: { $0 == beacon }) == nil else {
            callback("iBeacon Already Exist")
            return
        }
        
        beacon.cloudSyncStatus = .create
        beacon.lastModified = Date()
        
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.createBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    self.beacons.append(beacon)
                    callback(nil)
                    self.syncCreateWithCloud(beacon: beacon)
                } else if status == .error {
                    callback("Error on save iBeacon")
                } else if status == .fail {
                    callback("Fail on save iBeacon")
                }
            }
        }
    }
    
    func updateBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        beacon.cloudSyncStatus = .update
        beacon.lastModified = Date()
        updateLocal(beacon: beacon) { (error) in
            guard error == nil else {
                callback(error)
                return
            }
            
            if let index = self.beacons.firstIndex(where: { $0 == beacon }) {
                self.beacons[index] = beacon
            }
            callback(nil)
            
            self.syncUpdateWithCloud(beacon: beacon)
        }
    }
    
    func removeBeacon(_ beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        beacon.cloudSyncStatus = .delete
        beacon.lastModified = Date()
        updateLocal(beacon: beacon) { (error) in
            guard error == nil else {
                callback(error)
                return
            }
            
            if let index = self.beacons.firstIndex(where: { $0 == beacon }) {
                self.beacons.remove(at: index)
            }
            self.removedBeacons.append(beacon)
            callback(nil)
            
            self.syncDeleteWithCloud(beacon: beacon)
        }
    }
    
    //MARK: - private
    
    func localBeacons(callback: @escaping ([BeaconModel]) -> Void) {
        RealmDbService.beacons { (realmBeacons, opStatus) in
            var beacons = [BeaconModel]()
            if opStatus == .success {
                for realmBeacon in realmBeacons {
                    beacons.append(BeaconModel(with: realmBeacon))
                }
            }
            callback(beacons)
        }
    }
    
    fileprivate func updateLocal(beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.updateBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    callback(nil)
                } else if status == .error {
                    callback("Error on update iBeacon")
                } else if status == .fail {
                    callback("Fail on update iBeacon")
                }
            }
        }
    }
    
    fileprivate func removeLocal(beacon: BeaconModel, callback: @escaping (_ error: String?) -> Void) {
        let realmBeacon = BeaconRealmModel(with: beacon)
        RealmDbService.removeBeacon(realmBeacon) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    callback(nil)
                } else if status == .error {
                    callback("Error on remove iBeacon")
                } else if status == .fail {
                    callback("Fail on remove iBeacon")
                }
            }
        }
    }
    
    fileprivate func syncDbWithCloud() {
        
        let groupDisp = DispatchGroup()
        
        for beacon in removedBeacons {
            groupDisp.enter()
            syncDeleteWithCloud(beacon: beacon) {
                groupDisp.leave()
            }
        }
        
        groupDisp.notify(queue: .global(qos: .background)) {
            for beacon in self.beacons {
                if beacon.cloudSyncStatus == .create || beacon.cloudSyncStatus == .none {
                    groupDisp.enter()
                    self.syncCreateWithCloud(beacon: beacon) {
                        groupDisp.leave()
                    }
                } else if beacon.cloudSyncStatus == .update {
                    groupDisp.enter()
                    self.syncUpdateWithCloud(beacon: beacon) {
                        groupDisp.leave()
                    }
                }
            }
            
            groupDisp.notify(queue: .global(qos: .background)) {
                CloudStorage.loadBeacons { (aCloudBeacons, error) in
                    guard error == nil, let cloudBeacons = aCloudBeacons else { return }
                    for cloudBeacon in cloudBeacons {
                        if let index = self.beacons.firstIndex(where: { $0 == cloudBeacon }) {
                            let beacon = self.beacons[index]
                            if let lastModified = beacon.lastModified {
                                if lastModified.compare(cloudBeacon.lastModified!) != .orderedSame {
                                    groupDisp.enter()
                                    self.updateLocal(beacon: cloudBeacon) { (error) in
                                        groupDisp.leave()
                                        dLog("\(error.orNil)")
                                    }
                                }
                            } else {
                                groupDisp.enter()
                                self.updateLocal(beacon: cloudBeacon) { (error) in
                                    groupDisp.leave()
                                    dLog("\(error.orNil)")
                                }
                            }
                        } else {
                            groupDisp.enter()
                            RealmDbService.createBeacon(BeaconRealmModel(with: cloudBeacon)) { (status) in
                                groupDisp.leave()
                            }
                        }
                    }
                    
                    for beacon in self.beacons {
                        if !cloudBeacons.contains(where: { $0 == beacon} ) {
                            groupDisp.enter()
                            self.removeLocal(beacon: beacon) { (error) in
                                groupDisp.leave()
                            }
                        }
                    }
                    
                    groupDisp.notify(queue: .global(qos: .background)) {
                        self.localBeacons { (beacons) in
                            DispatchQueue.main.async {
                                self.beacons = beacons.filter( { $0.cloudSyncStatus != .delete })
                                self.removedBeacons = beacons.filter( { $0.cloudSyncStatus == .delete })
                                NotificationCenter.post(name: NSNotification.Name(rawValue: BeaconsSyncedWithCloudNotification), object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func syncCreateWithCloud(beacon: BeaconModel, callback: (() -> Void)? = nil) {
        CloudStorage.createBeacon(beacon) { (newCloudBeacon, error) in
            guard error == nil, let theBeacon = newCloudBeacon else { return }
            self.updateBeaconInDbAfterSyncWithCloud(beacon: theBeacon, callback: callback)
        }
    }
    
    fileprivate func syncUpdateWithCloud(beacon: BeaconModel, callback: (() -> Void)? = nil) {
        CloudStorage.updateBeacon(beacon) { (newCloudBeacon, error) in
            guard error == nil, let theBeacon = newCloudBeacon else { return }
            self.updateBeaconInDbAfterSyncWithCloud(beacon: theBeacon, callback: callback)
        }
    }
    
    fileprivate func syncDeleteWithCloud(beacon: BeaconModel, callback: (() -> Void)? = nil) {
        CloudStorage.deleteBeacon(beacon) { (recordId, error) in
            guard error == nil, let _ = recordId else { return }
            self.removeLocal(beacon: beacon) { (error) in
                guard error == nil else { return }
                DispatchQueue.main.async {
                    if let index = self.removedBeacons.firstIndex(where: { $0 == beacon }) {
                        self.removedBeacons.remove(at: index)
                    }
                    DispatchQueue.global(qos: .background).async {
                        callback?()
                    }
                }
            }
        }
    }
    
    fileprivate func updateBeaconInDbAfterSyncWithCloud(beacon: BeaconModel, callback: (() -> Void)? = nil) {
        RealmDbService.updateBeacon(BeaconRealmModel(with: beacon)) { (status) in
            DispatchQueue.main.async {
                if status == .success {
                    if let index = self.beacons.firstIndex(where: { $0 == beacon }) {
                        self.beacons[index] = beacon
                    }
                    DispatchQueue.global(qos: .background).async {
                        callback?()
                    }
                }
            }
        }
    }
}
