//
//  BTCentralManager.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import Foundation
import CoreBluetooth

public let BLEManager = BTCentralManager.sharedInstance

public class BTCentralManager: NSObject, CBCentralManagerDelegate {

    fileprivate var serviceUUIDs: [CBUUID] = [CBUUID.init(string: "0000")]
    
    fileprivate var centralManager:CBCentralManager!
    fileprivate var bluetoothThread = DispatchQueue(label: "com.m-technology.bags-tracker.bluetooth", attributes: DispatchQueue.Attributes.concurrent)
    
    fileprivate var isScanning: Bool = false
    fileprivate var isPoweredOn: Bool = false
    
    fileprivate var uniqueDevicesSet = NSMutableSet()
    
    public typealias DiscoveryDeviceCallbackClosure = (_ newDevice: Bool, _ device: DeviceModel) -> Void
    fileprivate var DiscoveryDeviceCallback: DiscoveryDeviceCallbackClosure?
    
    public static let sharedInstance: BTCentralManager = {
        let instance = BTCentralManager()
        return instance
    }()
    
    override init() {
        super.init()
        centralManager = CBCentralManager.init(delegate: self, queue: self.bluetoothThread)
    }
    
    deinit {
        
    }
    
    //MARK: - Public
    
    public func setupDiscoveryNodeCallback(_ callback: DiscoveryDeviceCallbackClosure?) {
        self.DiscoveryDeviceCallback = callback
    }
    
    public func startDiscovery(serviceUUIDs: [CBUUID]) {
        
        if isScanning {
            return
        }
        
        self.serviceUUIDs = serviceUUIDs
        
        uniqueDevicesSet.removeAllObjects()
        isScanning = true
        startScanIfNecessary()
    }
    
    public func stopDiscovery() {
        stopScanIfNecessary()
        isScanning = false
        uniqueDevicesSet.removeAllObjects()
    }
    
    public func bluetoothEnabled() -> Bool {
        return isPoweredOn
    }
    
    // MARK: - Private
    
    fileprivate func startScanIfNecessary() {
        if isScanning && isPoweredOn {
            dLog("Start ble scan")
            centralManager?.scanForPeripherals(withServices: nil /*serviceUUIDs*/, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    fileprivate func stopScanIfNecessary() {
        if isScanning && isPoweredOn {
            centralManager?.stopScan()
        }
    }
    
    
    
    // MARK: - Central Manager Delegate Methods
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            isPoweredOn = false
            break
        case .unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
        case .unknown:
            // Wait for another event
            break
        case .poweredOn:
            isPoweredOn = true
            startScanIfNecessary()
        case .resetting:
            break
        case .unsupported:
            break
        @unknown default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        dLog("========Discovered \(peripheral.identifier) at \(RSSI)=========")
//        dLog("name: \(peripheral.name ?? "=???=")")
//        dLog("advertisementData: \(advertisementData)")
//        dLog("kCBAdvDataServiceUUIDs: \(advertisementData["kCBAdvDataServiceUUIDs"].orNil)")
//        dLog("kCBAdvDataLocalName: \(advertisementData["kCBAdvDataLocalName"].orNil)")
//        dLog("kCBAdvDataManufacturerData: \(advertisementData["kCBAdvDataManufacturerData"].orNil)")
//        dLog("kCBAdvDataIsConnectable: \(advertisementData["kCBAdvDataIsConnectable"].orNil)")
//        dLog("===============================================================")
        
        /*
         
         "960C4A9B-244C-11E2-B299-00A0C60077AD" represents:
         Battery level = 0xa - 8 = 2
         8 is the fixed offset
         Temperature = 0x9b - 70 = 85 °F
         70 is the fixed offset
         
         "8C00453659EC9C476B84CE" is the payload that is looked up in the cloud service (0x008c is the Gimbal Company ID).
         
         If you modify https://github.com/sandeepmistry/noble/blob/master/examples/advertisement-discovery.js to start scanning with duplicates, you can use the above info to extract battery level and temp
         the 0x8c.... is the value of the manufacturer data
         
         */
        
        /*
        advertisementData: ["kCBAdvDataServiceUUIDs": <__NSArrayM 0x282b0b360>(
        960C4A94-244C-11E2-B299-00A0C60077AD
        )
        , "kCBAdvDataManufacturerData": <8c00cdd4 04ff0e97 d68b30>, "kCBAdvDataIsConnectable": 0]
        */
        
        //8c001107bfeced872551ee
        //8c00820e8cc74b29e2def9
        
        guard let device = DeviceModel(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI) else {
            return
        }
        
        var isNewDevice = false
        
        if !uniqueDevicesSet.contains(peripheral) {
            uniqueDevicesSet.add(peripheral)
            isNewDevice = true
        }
        
        DiscoveryDeviceCallback?(isNewDevice, device)
    }
    
    
    
}
