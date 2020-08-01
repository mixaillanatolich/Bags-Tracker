//
//  NotificationManager.swift
//  Bags Tracker
//
//  Created by Mixaill on 30.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import UIKit


//let NotificationSafeRideDeviceFoundCategory = "kNotificationSafeRideDeviceFoundCategory"
//
//enum NotificationSafeRideDeviceFoundActions:String{
//    case YES = "YES_ACTION"
//    case NO = "NO_ACTION"
//}

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

fileprivate let NotificationDelaySec: TimeInterval = 10.0

let NotificationCenter = NotificationManager.sharedInstance

class NotificationManager: NSObject {
   

    
   // var safeRideDeviceDiscoveredMessage = "SafeRide is discovered. Are you driving?"
    
    var beaconStates = [String: BeaconNotificationState]()
    
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    
    static let sharedInstance: NotificationManager = {
        let instance = NotificationManager()
        return instance
    }()
    
    override init() {
        super.init()
        //registerNotificationForSafeRideDeviceFound()
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
    
    fileprivate func createNotificationFor(beacon: BeaconModel, eventType: NotificationEventType, mark: String = "") {
        //guard beacon.notificationEvent == eventType else { return }
        self.beaconStates[beacon.identifier] = BeaconNotificationState(event: eventType, date: Date())
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
    
    func checkNotificationFor(beacon: BeaconCLModel, eventType: NotificationEventType) {
        
        guard let beaconId = beacon.identifier else { return }
        
        guard UIApplication.shared.applicationState == .background else { return }
        
        StorageService.beaconBy(id: beaconId) { (aBeacon) in
            guard let theBeacon = aBeacon else { return }
            guard theBeacon.isNotificationEnabled else { return }
            
            guard let lastState = self.beaconStates[theBeacon.identifier] else {
                self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "p1: ")
                return
            }
            
            if Date().timeIntervalSince(lastState.date) > NotificationDelaySec {
                self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "p2: ")
            } else {
                guard eventType != .near else { return }
                
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
                    self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "p3: ")
                    return
                }
                
                self.findPendingNotificationFor(identifier: notificationIdentifier) { (notificationRequest) in
                    guard let notification = notificationRequest else {
                        self.createNotificationFor(beacon: theBeacon, eventType: eventType, mark: "p4: ")
                        return
                    }
                    
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                    // looks like beacon returned to the prev state
                    // so not need show notification
                }
                
            }
            
            
            /*
           // guard theBeacon.notificationEvent == eventType else { return }
            
            var eventStr: String
            var alterNotifIdentifier: String
            switch eventType {
            case .inRange:
                eventStr = " In Range"
                alterNotifIdentifier = theBeacon.notificationId(eventType: .outOfRange)
            case .outOfRange:
                eventStr = " Out Of Range"
                alterNotifIdentifier = theBeacon.notificationId(eventType: .inRange)
            case .near:
                eventStr = " Nearby"
                alterNotifIdentifier = theBeacon.notificationId(eventType: .near)
            }
            
            self.notificationCenter.getPendingNotificationRequests { (notifications) in
                for notification in notifications {
                    if notification.identifier == alterNotifIdentifier {
                        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                        return
                    }
                }
                
                self.showLocalNotificationWith(title: "Beacon \(theBeacon.name)" + eventStr,
                                               message: "\(beacon.timestamp)", delay: NotificationDelaySec,
                                                identifier: theBeacon.notificationId(eventType: eventType))
                
            }
            */
        }
        
    }
    
    func checkNotificationFor2(beacon: BeaconCLModel, eventType: NotificationEventType) {
        
        guard let beaconId = beacon.identifier else { return }
        
        guard UIApplication.shared.applicationState == .background else { return }
        
        StorageService.beaconBy(id: beaconId) { (aBeacon) in
            guard let theBeacon = aBeacon else { return }
            guard theBeacon.isNotificationEnabled else { return }
          //  guard theBeacon.notificationEvent == eventType else { return }
            
            var eventStr: String
            switch eventType {
            case .inRange:
                eventStr = " In Range"
            case .outOfRange:
                eventStr = " Out Of Range"
            case .near:
                eventStr = " Nearby"
            }
            
            self.showLocalNotificationWith(title: "Beacon \(theBeacon.name)" + eventStr,
                                           message: "rise \(beacon.timestamp)", delay: 10,
                                           identifier: theBeacon.notificationId(eventType: eventType)+"1")
            
        }
        
    }
    
    func showLocalNotificationWith(title: String?, message: String?, delay: TimeInterval?, identifier: String) {
        
       // AppManager.removeAllNotifications()
        
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
    
    /*
    // Register notification settings
    func registerNotificationForSafeRideDeviceFound() {
        
        // 1. Create the actions **************************************************
        let action1 = UIMutableUserNotificationAction()
        action1.identifier = NotificationSafeRideDeviceFoundActions.YES.rawValue
        action1.title = "Yes"
        action1.activationMode = UIUserNotificationActivationMode.foreground
        action1.isAuthenticationRequired = true
        action1.isDestructive = false
        
        let action2 = UIMutableUserNotificationAction()
        action2.identifier = NotificationSafeRideDeviceFoundActions.NO.rawValue
        action2.title = "No"
        action2.activationMode = UIUserNotificationActivationMode.background
        action2.isAuthenticationRequired = true
        action2.isDestructive = false
        
        // 2. Create the category ***********************************************
        
        // Category
        let counterCategory = UIMutableUserNotificationCategory()
        counterCategory.identifier = NotificationSafeRideDeviceFoundCategory
        
        // A. Set actions for the default context
        counterCategory.setActions([action1, action2],
            for: UIUserNotificationActionContext.default)
        
        // B. Set actions for the minimal context
        counterCategory.setActions([action1, action2],
            for: UIUserNotificationActionContext.minimal)
        
        
        // 3. Notification Registration *****************************************
        let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
        let settings = UIUserNotificationSettings(types: types, categories: (NSSet(object: counterCategory) as! Set<UIUserNotificationCategory>))
        DispatchQueue.main.async {
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    */
    /*
    func showSafeRideDeviceFoundNotification() {
        
        if AppManager.silentMode {
            return
        }
        
        let notification = UILocalNotification()
        notification.alertBody = "Please open SafeRide now to plan your trip before you drive."
        DispatchQueue.main.async {
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        //showSafeRideDeviceFoundNotification(false)
    }
    */
    /*
    func showSafeRideDeviceFoundNotification(_ afterTimeout: Bool) {
        
        if UIApplication.shared.applicationState == UIApplicationState.background {
            
            AppManager.removeAllNotifications()
            
            let notification = UILocalNotification()
            notification.alertBody = safeRideDeviceDiscoveredMessage
            //notification.soundName = UILocalNotificationDefaultSoundName
            //notification.fireDate = NSDate().dateByAddingTimeInterval(1)
            notification.category = NotificationSafeRideDeviceFoundCategory
            //notification.repeatInterval = NSCalendarUnit.Minute
            
            if (afterTimeout) {
                notification.fireDate = Date().addingTimeInterval(60)
                DispatchQueue.main.async {
                    UIApplication.shared.scheduleLocalNotification(notification)
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.presentLocalNotificationNow(notification)
                }
            }
            
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertView(title: nil, message: self.safeRideDeviceDiscoveredMessage, delegate: self, cancelButtonTitle: "No")
                alert.addButton(withTitle: "Yes")
                alert.show()
            }
        }

    }
    */

    /*
    func showLocalNotificationWithMessage(_ message: String) {
        
        AppManager.removeAllNotifications()
        
        let notification = UILocalNotification()
        notification.alertBody = message
        DispatchQueue.main.async {
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    */
    /*
    func showLocalNotificationWithMessage(_ message: String, alertAction: String?, identifier: String?, repeatNotification: Bool) {
        let notification = UILocalNotification()
        notification.alertBody = message
        if let alertAction = alertAction {
            notification.alertAction = alertAction
        }
        if let identifier = identifier {
            notification.userInfo = ["identifier" : identifier]
        }
        
        AppManager.removeAllNotifications()
        
        if repeatNotification {
            notification.fireDate = Date().addingTimeInterval(1)
            notification.repeatInterval = NSCalendar.Unit.minute
            DispatchQueue.main.async {
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }
    */
    
    func removeAllNotifications() {
        DispatchQueue.main.async {
            
            let application = UIApplication.shared
        
         //   application.applicationIconBadgeNumber = 1
            application.applicationIconBadgeNumber = 0
         //   application.applicationIconBadgeNumber = -1
        
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}
