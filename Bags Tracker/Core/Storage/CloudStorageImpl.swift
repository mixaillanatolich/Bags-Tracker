//
//  CloudStorageImpl.swift
//  Bags Tracker
//
//  Created by Mixaill on 16.09.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit
import CloudKit

let CloudStorage = CloudStorageImpl.sharedInstance

class CloudStorageImpl: NSObject {

    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    static let sharedInstance: CloudStorageImpl = {
        let instance = CloudStorageImpl()
        return instance
    }()
    
    override init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        super.init()
    }
    
    deinit {
    }
    
    //MARK: - API
    
    func loadBeacons(callback: @escaping ([BeaconModel]?, Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Beacons", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { results, error in
            if let error = error {
                dLog("loadBeacons error \(error)")
                DispatchQueue.main.async {
                    callback(nil, error)
                }
                return
            }
            
            guard let devices = results else {
                callback(nil, NSError(domain: "iCloud.com.m-technologies.Bags-Tracker", code: 1, userInfo: [NSLocalizedDescriptionKey : "Empty Response"]))
                return
            }
            
            var beacons = [BeaconModel]()
  
            for device in devices {
                
                guard let uuid = device["uuid"] >>> JSONAsString,
                    let name = device["name"] >>> JSONAsString,
                    let identifier = device["identifier"] >>> JSONAsString,
                    let major = device["major"] >>> JSONAsNumber,
                    let minor = device["minor"] >>> JSONAsNumber
                    else {
                    continue
                }
                
                let beacon = BeaconModel(uuid: uuid, name: name, aIdentifier: identifier, majorValue: major, minorValue: minor)
                beacon.isNotificationEnabled = (device["isNotificationEnabled"] >>> JSONAsBool) ?? false
                if let events = device["notificationEvents"] >>> JSONAsArray {
                    for event in events as! [Int] {
                        beacon.notificationEvents.append(NotificationEventType(rawValue: event)!)
                    }
                }
                beacons.append(beacon)
            }

            DispatchQueue.main.async {
                callback(beacons, nil)
            }
        }
    }
    
    func createBeacon(_ beacon: BeaconModel, callback: @escaping (Error?) -> Void) {
        
        let ckbeacon = createCKBeaconFrom(beacon)

        privateDB.save(ckbeacon) { (record, error) -> Void in
            
            dLog("record \(record.orNil)")
            dLog("error \(error.orNil)")
            
            DispatchQueue.main.sync {
                callback(error)
            }
        }
    }
    
    func updateBeacon(_ beacon: BeaconModel, callback: @escaping (Error?) -> Void) {
        
        let ckbeacon = createCKBeaconFrom(beacon)

//        let query = CKQuery(recordType: "Beacons", predicate: NSPredicate(format: "identifier == %@", beacon.identifier))
//
//        privateDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (results, error) -> Void in
//
//            dLog("records \(results.orNil)")
//            dLog("error \(error.orNil)")
//
//            guard let devices = results, let device = devices.first else {
//                callback(NSError(domain: "iCloud.com.m-technologies.Bags-Tracker", code: 1, userInfo: [NSLocalizedDescriptionKey : "Empty Response"]))
//                return
//            }
//
//            DispatchQueue.main.sync {
//
//            }
//        }
        
        
//        publicData.fetchRecordWithID(recordIDToSave) { (record, error) in
//
//        if let recordToSave =  record {
//
//            //Modify the record value here
//            recordToSave.setObject("value", forKey: "key")
//
//            let modifyRecords = CKModifyRecordsOperation(recordsToSave:[recordToSave], recordIDsToDelete: nil)
//            modifyRecords.savePolicy = CKRecordSavePolicy.AllKeys
//            modifyRecords.qualityOfService = NSQualityOfService.UserInitiated
//            modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                if error == nil {
//                    print("Modified")
//                }else {
//                    print(error)
//                }
//            }
//                publicData.addOperation(modifyRecords)
//            } else {
//                print(error.debugDescription)
//            }
//        }
        
        let modifyRecords = CKModifyRecordsOperation(recordsToSave:[ckbeacon], recordIDsToDelete: nil)
        modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        modifyRecords.qualityOfService = QualityOfService.userInitiated
   
        
        modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error == nil {
                dLog("Modified")
            }else {
                dLog("\(error.orNil)")
            }
        }
        
        privateDB.add(modifyRecords)
//        privateDB.save(ckbeacon) { (record, error) -> Void in
//
//            dLog("record \(record.orNil)")
//            dLog("error \(error.orNil)")
//
//            DispatchQueue.main.sync {
//                callback(error)
//            }
//        }
    }
    
    func deleteBeacon(_ beacon: BeaconModel, callback: @escaping (Error?) -> Void) {
        
        privateDB.delete(withRecordID: CKRecord.ID(recordName: beacon.identifier)) { (recordID, error) -> Void in
            DispatchQueue.main.sync {
                dLog("recordID \(recordID.orNil)")
                dLog("error \(error.orNil)")

                callback(error)
                
            }
        }
        
    }
    
    fileprivate func createCKBeaconFrom(_ beacon: BeaconModel) -> CKRecord {
        let ckbeacon = CKRecord(recordType: "Beacons", recordID: CKRecord.ID(recordName: beacon.identifier) ) //CKRecord(recordType: "Beacons")
        
        ckbeacon.setObject(beacon.uuid.uuidString as __CKRecordObjCValue, forKey: "uuid")
        ckbeacon.setObject(beacon.identifier as __CKRecordObjCValue, forKey: "identifier")
        ckbeacon.setObject(beacon.name as __CKRecordObjCValue, forKey: "name")
        ckbeacon.setObject((beacon.majorValue ?? 0) as __CKRecordObjCValue, forKey: "major")
        ckbeacon.setObject((beacon.minorValue ?? 0) as __CKRecordObjCValue, forKey: "minor")
        ckbeacon.setObject(beacon.isNotificationEnabled as __CKRecordObjCValue, forKey: "isNotificationEnabled")
        var notificationEvents = [Int]()
        for event in beacon.notificationEvents {
            notificationEvents.append(event.rawValue)
        }
        ckbeacon.setObject(notificationEvents as __CKRecordObjCValue, forKey: "notificationEvents")
        
        return ckbeacon
    }
    
}
