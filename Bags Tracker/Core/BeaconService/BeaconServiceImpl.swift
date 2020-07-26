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

let BeaconService: BeaconServiceProtocol = BeaconServiceImpl.sharedInstance

class BeaconServiceImpl: NSObject, BeaconServiceProtocol {
    
    let timer = DispatchSource.makeTimerSource()
    
    let locationManager = CLLocationManager()
    var delegate: BeaconServiceDelegate?
    
    var activeBeacons = [BeaconCLModel]()
    
    static let sharedInstance: BeaconServiceImpl = {
        let instance = BeaconServiceImpl()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
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
    
    func setupDelegate(delegate: BeaconServiceDelegate?) {
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
    
    //didRange beacon: CLBeacon (uuid:FDA50693-A4E2-4FB1-AFCF-C6EB07647825, major:1, minor:2, proximity:3 +/- 21.54m, rssi:-64, timestamp:2020-07-24 05:58:44 +0000)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        for beacon in beacons {
            dLog("didRange beacon: \(beacon)")
            
            guard beacon.proximity != .unknown else {
                continue
            }
            
            if let index = activeBeacons.firstIndex(where: { $0 == beacon}) {
                let activeBeacon = activeBeacons[index]
                activeBeacon.updateWith(clBeacon: beacon)
                delegate?.beaconUpdate(activeBeacon)
            } else {
                let theBeacon = BeaconCLModel(clBeacon: beacon)
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
    
    //CLBeaconRegion (identifier:'053dc9c35570610597386fb1117ee70b', uuid:FDA50693-A4E2-4FB1-AFCF-C6EB07647825, major:1, minor:2)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        
        dLog("didEnterRegion: \(beaconRegion)")
        
        if let index = activeBeacons.firstIndex(where: { $0 == beaconRegion}) {
             let activeBeacon = activeBeacons[index]
             activeBeacon.updateWith(clBeaconRegion: beaconRegion)
             delegate?.beaconUpdate(activeBeacon)
         } else {
            let theBeacon = BeaconCLModel(clBeaconRegion: beaconRegion)
             activeBeacons.append(theBeacon)
             delegate?.beaconFinded(theBeacon)
         }
        
        //TODO need notification?
    }

  //  didExitRegion: CLBeaconRegion (identifier:'053dc9c35570610597386fb1117ee70b', uuid:FDA50693-A4E2-4FB1-AFCF-C6EB07647825, major:1, minor:2)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            return
        }
        dLog("didExitRegion: \(beaconRegion)")
        
        if let index = activeBeacons.firstIndex(where: { $0 == beaconRegion}) {
            let activeBeacon = activeBeacons[index]
            delegate?.beaconLost(activeBeacon)
            activeBeacons.remove(at: index)
        }
        
        //TODO need notification?
    }
 
    
    /*
    *  notifyEntryStateOnDisplay
    *
    *  Discussion:
    *    App will be launched and the delegate will be notified via locationManager:didDetermineState:forRegion:
    *    when the device's screen is turned on and the user is in the region. By default, this is NO.
    */
    //didDetermineState: 1 for region CLBeaconRegion (identifier:'053dc9c35570610597386fb1117ee70b', uuid:FDA50693-A4E2-4FB1-AFCF-C6EB07647825, major:1, minor:2)
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        dLog("didDetermineState: \(state.rawValue) for region \(region)")
        
        //TODO handle that case
    }
    
}

