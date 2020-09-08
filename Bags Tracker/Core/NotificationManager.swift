//
//  NotificationManager.swift
//  Bags Tracker
//
//  Created by Mixaill on 30.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit

enum NotificationEventType: Int {
    case inRange = 0
    case outOfRange = 1
    case near = 2
    
    func notificationName() -> String {
        switch self {
        case .inRange:
            return "In Range"
        case .outOfRange:
            return "Out Of Range"
        case .near:
            return "Nearby"
        }
    }
}

struct BeaconNotificationState {
    var event: NotificationEventType
    var date: Date
}

fileprivate let NotificationDelaySec: TimeInterval = 11.6

let NotificationCenter = NotificationManager.sharedInstance

class NotificationManager: NSObject {
    
    var beaconStates = [String: BeaconNotificationState]()
    
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    
    static let sharedInstance: NotificationManager = {
        let instance = NotificationManager()
        return instance
    }()
    
    override init() {
        super.init()
    }

    func requestNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                dLog("error: \(error.localizedDescription)")
            } else {
                dLog("Notification allowed")
            }
        }
    }
    
    func removeAllNotifications() {
        DispatchQueue.main.async {
            
            let application = UIApplication.shared

            application.applicationIconBadgeNumber = 0
        
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    func checkNotificationFor(beacon: BeaconCLModel, eventType: NotificationEventType) {
        
        guard let beaconId = beacon.identifier else { return }
        
        guard UIApplication.shared.applicationState == .background else { return }
        
        StorageService.beaconBy(id: beaconId) { (aBeacon) in
            guard let theBeacon = aBeacon else { return }
            guard theBeacon.isNotificationEnabled else { return }
            
            let statekey = theBeacon.identifier + (eventType == .near ? "+near" : "")
            
            guard let lastState = self.beaconStates[statekey] else {
                self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "")
                return
            }
            
            guard eventType != .near else {
                if Date().timeIntervalSince(lastState.date) > 60.0 {
                    self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "")
                }
                return
            }
            
            if Date().timeIntervalSince(lastState.date) > NotificationDelaySec {
                self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "")
            } else {
                var notifIdentifier: String?
                switch eventType {
                case .inRange:
                    notifIdentifier = theBeacon.notificationId(eventType: .outOfRange)
                case .outOfRange:
                    notifIdentifier = theBeacon.notificationId(eventType: .inRange)
                default:
                    break
                }
                
                guard let notificationIdentifier = notifIdentifier else {
                    self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "")
                    return
                }
                
                self.findPendingNotificationFor(identifier: notificationIdentifier) { (notificationRequest) in
                    guard let notification = notificationRequest else {
                        self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "")
                        return
                    }
                    
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                    //self.beaconStates[statekey] = BeaconNotificationState(event: theBeacon.identifier, date: Date())
                    // looks like beacon returned to the prev state
                    // so not need show notification
                }
                
            }
        }
        
    }
    
    func testNotification(text: String) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        let dateStr = timeFormatter.string(from: Date())
        self.showLocalNotificationWith(title: text, message: "\(dateStr)", delay: nil, identifier: "com.app.test" + UUID().uuidString)
    }
    
    fileprivate func createNotificationFor(beacon: BeaconModel, eventType: NotificationEventType, mark: String = "") {
        let statekey = beacon.identifier + (eventType == .near ? "+near" : "")
        self.beaconStates[statekey] = BeaconNotificationState(event: eventType, date: Date())
        guard beacon.notificationEvents.contains(eventType) else { return }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        let dateStr = timeFormatter.string(from: Date())
        self.showLocalNotificationWith(title: "Beacon \(beacon.name) " + eventType.notificationName(),
                                       message: mark + "\(dateStr)", delay: NotificationDelaySec,
                                       identifier: beacon.notificationId(eventType: eventType))
    }
    
    fileprivate func findPendingNotificationFor(identifier: String, result: @escaping (UNNotificationRequest?)->() ) {
        self.notificationCenter.getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                if notification.identifier == identifier {
                    result(notification)
                    return
                }
            }
            result(nil)
        }
    }
    
    fileprivate func showLocalNotificationWith(title: String?, message: String?, delay: TimeInterval?, identifier: String) {
        
        let content = UNMutableNotificationContent()
        
        if let title = title {
            content.title = title
        }
        if let message = message {
            content.body = message
        }
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        var trigger:UNCalendarNotificationTrigger? = nil
        if let delay = delay {
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: Date(timeIntervalSinceNow: delay))
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                dLog("Error \(error.localizedDescription)")
            }
        }
    }
    
}
