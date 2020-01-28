//
//  DeviceModel.swift
//  Bags Tracker
//
//  Created by Mixaill on 17/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

public class DeviceModel: NSObject {

    var uuid: String
    var name: String
    var advertisementData: [String : Any]
    var rssi: NSNumber
    
    init?(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let vCBAdvDataServiceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as? [Any], vCBAdvDataServiceUUIDs.count > 0 else {
            return nil
        }
        
        guard let vCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data else {
            return nil
        }
        
//        let manufacturerData = "\(kCBAdvDataManufacturerData)".replacingOccurrences(of: " ", with: "")
//            .replacingOccurrences(of: "<", with: "")
//            .replacingOccurrences(of: ">", with: "").lowercased()
        
        let manufacturerData = vCBAdvDataManufacturerData.hexString().lowercased()
        
        dLog("uuid: \(manufacturerData)")
        
        guard manufacturerData.hasPrefix("8c00") else {
            return nil
        }
        
        dLog("advertisementData: \(advertisementData)")
        
        self.uuid = manufacturerData
        self.advertisementData = advertisementData
        self.rssi = RSSI
        self.name = uuid
    }
    
    func temperature() -> String? {
        
        let kCBAdvDataServiceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as! [Any]
        
        let serviceData = "\(kCBAdvDataServiceUUIDs[0])"
        
        let start = serviceData.index(serviceData.startIndex, offsetBy: 6)
        let end = serviceData.index(serviceData.startIndex, offsetBy: 8)
        let range = start..<end
        let tempStr = String(serviceData[range])
        
      //  dLog("tempStr \(tempStr)")
        
        guard let tempData = tempStr.hexadecimalData() else {
            return nil
        }
        
       // dLog("temp \(tempData.uint8())")
     //   dLog("temp \((tempData.uint8()) - 70)")
        
        let fahrenheit = tempData.uint8() - 70
        
        let celsius = (Double(fahrenheit) - 32) / 1.8
        
        let celsiusStr = String(format: "%.2f", celsius)
        
        dLog("temp \(celsiusStr) C")
        
        return celsiusStr
    }
    
    func save() {
        if let devicesStr = UserDefaults.value(forKey: "kDevices") as? String, !devicesStr.isEmpty {
            var devices = devicesStr.components(separatedBy: ",")
            if !devices.contains(uuid) {
                devices.append(uuid)
                UserDefaults.set(devices.joined(separator: ","), forKey: "kDevices")
            }
        } else {
            UserDefaults.set(uuid, forKey: "kDevices")
        }
    }
    
    func remove() {
        if let devicesStr = UserDefaults.value(forKey: "kDevices") as? String, !devicesStr.isEmpty {
            var devices = devicesStr.components(separatedBy: ",")
            if let index = devices.firstIndex(of: uuid) {
                devices.remove(at: index)
                UserDefaults.set(devices.joined(separator: ","), forKey: "kDevices")
            }
        }
    }
    
    static func allDevices() -> [String] {
        if let devicesStr = UserDefaults.value(forKey: "kDevices") as? String, !devicesStr.isEmpty {
            return devicesStr.components(separatedBy: ",")
        }
        
        return [String]()
    }
    
}
