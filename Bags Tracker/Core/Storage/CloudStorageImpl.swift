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
    
    let defaultZone = CKRecordZone.default().zoneID
    
    let errorDomain = "iCloud.\(Bundle.main.bundleIdentifier ?? "")"
    
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
        
        privateDB.perform(query, inZoneWith: defaultZone) { results, error in

            dLog("record \(results.orNil)")
            dLog("error \(error.orNil)")
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let devices = results else {
                callback(nil, NSError(domain: self.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : "Empty Response"]))
                return
            }
            
            var beacons = [BeaconModel]()
  
            for device in devices {
                if let beacon = self.parseRecordToBeacon(device) {
                    beacons.append(beacon)
                }
            }

            callback(beacons, nil)
        }
    }
    
    func createBeacon(_ beacon: BeaconModel, callback: @escaping (BeaconModel?, Error?) -> Void) {
        privateDB.save(createRecordFrom(beacon)) { (record, error) -> Void in
            
            dLog("record \(record.orNil)")
            dLog("error \(error.orNil)")
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let beacon = record else {
                callback(nil, NSError(domain: self.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : "Empty Response"]))
                return
            }
            
            guard let theBeacon = self.parseRecordToBeacon(beacon) else {
                callback(nil, NSError(domain: self.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : "Parse error"]))
                return
            }
            
            callback(theBeacon, nil)
        }
    }
    
    func updateBeacon(_ beacon: BeaconModel, callback: @escaping (BeaconModel?, Error?) -> Void) {
        
        let ckbeacon = createRecordFrom(beacon)

        let modifyRecords = CKModifyRecordsOperation(recordsToSave:[ckbeacon], recordIDsToDelete: nil)
        modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        modifyRecords.qualityOfService = QualityOfService.userInitiated
   
        modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            
            dLog("record \(savedRecords.orNil)")
            dLog("error \(error.orNil)")
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let beacons = savedRecords, let beacon = beacons.first else {
                callback(nil, NSError(domain: self.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : "Empty Response"]))
                return
            }
            
            guard let theBeacon = self.parseRecordToBeacon(beacon) else {
                callback(nil, NSError(domain: self.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey : "Parse error"]))
                return
            }
            
            callback(theBeacon, nil)
        }
        
        privateDB.add(modifyRecords)
        
    }
    
    func deleteBeacon(_ beacon: BeaconModel, callback: @escaping (String?, Error?) -> Void) {
        privateDB.delete(withRecordID: CKRecord.ID(recordName: beacon.identifier)) { (recordID, error) -> Void in
            dLog("recordID \(recordID.orNil)")
            dLog("error \(error.orNil)")
            callback(recordID?.recordName, error)
        }
    }
    
    
    //MARK: - private
    fileprivate func parseRecordToBeacon(_ record: CKRecord) -> BeaconModel? {
        guard let uuid = record["uuid"] >>> JSONAsString,
            let name = record["name"] >>> JSONAsString,
            let identifier = record["identifier"] >>> JSONAsString,
            let major = record["major"] >>> JSONAsNumber,
            let minor = record["minor"] >>> JSONAsNumber
            else {
            return nil
        }
        let beacon = BeaconModel(uuid: uuid, name: name, aIdentifier: identifier, majorValue: major, minorValue: minor)
        beacon.isNotificationEnabled = (record["isNotificationEnabled"] >>> JSONAsBool) ?? false
        if let events = (record["notificationEvents"] >>> JSONAsArray) as? [Int] {
            events.forEach({ beacon.notificationEvents.append(NotificationEventType(rawValue: $0)!) })
        }
        beacon.cloudSyncStatus = .synced
        beacon.lastModified = record.modificationDate
        return beacon
    }
    
    fileprivate func createRecordFrom(_ beacon: BeaconModel) -> CKRecord {
        let ckBeacon = CKRecord(recordType: "Beacons", recordID: CKRecord.ID(recordName: beacon.identifier))
        
        ckBeacon["uuid"] = beacon.uuid.uuidString
        ckBeacon["identifier"] = beacon.identifier
        ckBeacon["name"] = beacon.name
        ckBeacon["major"] = beacon.majorValue
        ckBeacon["minor"] = beacon.minorValue
        ckBeacon["isNotificationEnabled"] = beacon.isNotificationEnabled

        var notificationEvents = [Int]()
        beacon.notificationEvents.forEach( { notificationEvents.append($0.rawValue) } )
        
        ckBeacon["notificationEvents"] = notificationEvents
        
        return ckBeacon
    }
}

// just for test

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
        

//        privateDB.save(ckbeacon) { (record, error) -> Void in
//
//            dLog("record \(record.orNil)")
//            dLog("error \(error.orNil)")
//
//            DispatchQueue.main.sync {
//                callback(error)
//            }
//        }
