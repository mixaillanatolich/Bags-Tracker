//
//  AppDelegate.swift
//  Bags Tracker
//
//  Created by Mixaill on 16/05/2019.
//  Copyright © 2019 M Technologies. All rights reserved.
//

import UIKit
import Firebase
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if (application.applicationState == .background) {
            // run services
        }
        
        NotificationCenter.requestNotifications()
        
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.m-technologies.test", using: nil) { (task) in
            print("Task handler")
            NotificationCenter.testNotification(text: "Bg Hoba")
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
                NotificationCenter.testNotification(text: "Bg expiration")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                NotificationCenter.testNotification(text: "Bg timeout")
                task.setTaskCompleted(success: true)
            }
            
            //todo reschedule
            self.scheduleTestTask()
        }
        
        
        return true
    }

    func scheduleTestTask() {
        dNSLog("====schedule task===")
        let request = BGProcessingTaskRequest(identifier: "com.m-technologies.test")
        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = false
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 20 * 60) // Featch Image Count after 1 minute.
        //Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule image featch: \(error)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        scheduleTestTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.removeAllNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // TODO
    // investigate disable monitoring for beacons in case notification is off
    // investigate push notifications
    
}
