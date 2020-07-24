//
//  RealmDbImpl.swift
//  Bags Tracker
//
//  Created by Mixaill on 24.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import RealmSwift

let RealmDbService: RealmDbProtocol = RealmDbImpl.sharedInstance

class RealmDbImpl: NSObject, RealmDbProtocol {

    let queueName = Bundle.main.bundleIdentifier ?? "" + ".RealmDb"
    
    static let sharedInstance: RealmDbImpl = {
        let instance = RealmDbImpl()
        return instance
    }()
    
    override init() {
        var config = Realm.Configuration()
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("db.realm")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func cleanupDb(callback: @escaping () -> Void) {
        DispatchQueue(label: queueName).async {
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                callback()
            }
        }
    }
    
    func createBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void) {
        DispatchQueue(label: queueName).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let res = self.saveObject(beacon, realmDb: realm)
                    result(res)
                } catch let error as NSError {
                    dLog("\(error)")
                    result(.fail)
                }
            }
        }
    }
    
    func removeBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void) {
        DispatchQueue(label: queueName).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let theBeacon = realm.object(ofType: BeaconRealmModel.self, forPrimaryKey: beacon.identifier) else {
                        result(.fail)
                        return
                    }
                    let res = self.removeObject(theBeacon, realmDb: realm)
                    result(res)
                } catch let error as NSError {
                    dLog("\(error)")
                    result(.fail)
                }
            }
        }
    }
    
    func updateBeacon(_ beacon: BeaconRealmModel, result: @escaping (RealmOpStatus) -> Void) {
        DispatchQueue(label: queueName).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let res = self.updateBeaconObject(beacon, realmDb: realm)
                    result(res)
                } catch let error as NSError {
                    dLog("\(error)")
                    result(.fail)
                }
            }
        }
    }
    
    func beacons(result: @escaping ([BeaconRealmModel], RealmOpStatus) -> Void) {
        DispatchQueue(label: queueName).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    result(realm.objects(BeaconRealmModel.self).materialize(), .success)
                } catch let error as NSError {
                    dLog("\(error)")
                    result([BeaconRealmModel](), .fail)
                }
            }
        }
    }
    
    @discardableResult
    fileprivate func updateBeaconObject(_ beacon: BeaconRealmModel, realmDb: Realm) -> RealmOpStatus {
        do {
            try realmDb.write {
                realmDb.create(BeaconRealmModel.self, value: beacon.paramsForModify(), update: .modified)
            }
            return .success
        } catch let error as NSError {
            dLog("\(error)")
            return .error
        }
    }
    
    @discardableResult
    fileprivate func saveObject(_ device: Object, realmDb: Realm) -> RealmOpStatus {
        do {
            try realmDb.write {
                realmDb.add(device, update: .modified)
            }
            return .success
        } catch let error as NSError {
            dLog("\(error)")
            return .error
        }
    }
    
    @discardableResult
    fileprivate func removeObject(_ device: Object, realmDb: Realm) -> RealmOpStatus {
        do {
            try realmDb.write {
                realmDb.delete(device)
            }
            return .success
        } catch let error as NSError {
            dLog("\(error)")
            return .error
        }
    }
    
}

extension Results {
    func materialize() -> [Element] {
        return Array(self)
    }
}
