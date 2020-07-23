//
//  BeaconServiceImpl.swift
//  Bags Tracker
//
//  Created by Mixaill on 23.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import CoreLocation

let TimeToLostBeacon: TimeInterval = 30.0

class BeaconServiceImpl: NSObject, BeaconServiceProtocol {
    
    let timer = DispatchSource.makeTimerSource()
    
    let locationManager = CLLocationManager()
    var delegate: BeaconDelegate?
    
    var activeBeacons = [BeaconCLModel]()
    
    func run() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        timer.schedule(deadline: .now(), repeating: .seconds(30), leeway: .seconds(1))
        timer.setEventHandler {
            DispatchQueue.main.async {
                self.checkActiveBeacons()
            }
        }
        timer.resume()
    }
    
    func setupDelegate(delegate: BeaconDelegate?) {
        self.delegate = delegate
    }
    
    func startMonitoring(beacons: [BeaconModel]) {
        for beacon in beacons {
            startMonitoring(region: beacon.beaconRegion())
        }
    }
    
    func stopMonitoring(beacons: [BeaconModel]) {
        for beacon in beacons {
            stopMonitoring(region: beacon.beaconRegion())
        }
    }
    
    fileprivate func startMonitoring(region: CLBeaconRegion) {
        locationManager.startMonitoring(for: region)
        locationManager.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
    }
    
    fileprivate func stopMonitoring(region: CLBeaconRegion) {
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(satisfying: region.beaconIdentityConstraint)
    }
    
    fileprivate func checkActiveBeacons() {
        activeBeacons = activeBeacons.filter { (beacon) -> Bool in
            if Date().timeIntervalSince(beacon.timestamp) > TimeToLostBeacon {
                delegate?.beaconLost(beacon)
                return false
            }
            return true
        }
    }
}


extension BeaconServiceImpl: CLLocationManagerDelegate {
    
    //didRange beacon: CLBeacon (uuid:Bwer, major:21, minor:3, proximity:1 +/- 0.08m, rssi:-89, timestamp:2020-07-23 14:48:45 +0000)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        for beacon in beacons {
            dLog("didRange beacon: \(beacon)")
            
//            guard beacon.proximity == .near || beacon.proximity == .immediate else {
//                continue
//            }
            
            let theBeacon = BeaconCLModel(clBeacon: beacon)
            
            let aBeacon = activeBeacons.filter { (aBeacon) -> Bool in
                aBeacon == beacon
            }.first
            
            if let activeBeacon = aBeacon {
                activeBeacon.updateWith(clBeacon: beacon)
                delegate?.beaconUpdate(theBeacon)
            } else {
                activeBeacons.append(theBeacon)
                delegate?.beaconFinded(theBeacon)
            }
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        dLog("didFailRangingFor: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        dLog("monitoringDidFailFor: \(error.localizedDescription)")
    }
  
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        dLog("didStartMonitoringFor: \(beaconRegion)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        
        dLog("didEnterRegion: \(beaconRegion)")
        
        //TODO handle that case
    }
    //didEnterRegion: CLBeaconRegion (identifier:'qwe', uuid:sdfw3, major:(null), minor:(null))
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        dLog("didExitRegion: \(beaconRegion)")
        
        //TODO handle that case
    }
 
    
    /*
    *  notifyEntryStateOnDisplay
    *
    *  Discussion:
    *    App will be launched and the delegate will be notified via locationManager:didDetermineState:forRegion:
    *    when the device's screen is turned on and the user is in the region. By default, this is NO.
    */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        dLog("didDetermineState: \(state) for region \(region)")
        
        //TODO handle that case
    }
    
}

