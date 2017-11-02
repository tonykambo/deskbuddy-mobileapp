//
//  AppDelegate.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 13/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit
import UserNotifications
import BMSCore
import BMSPush


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let yesActionIdentifier = "YES_IDENTIFIER"
    let noActionIdentifier = "NO_IDENTIFIER"
    let comingToWorkCategoryIdentifier = "COMINGTOWORK_CATEGORY"

    func registerForBluemixPushNotifications(pushObserver: BMSPushObserver) {
        
        //BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        
        BMSPushClient.sharedInstance.delegate = pushObserver
        BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: "21389e62-6bb3-4039-80aa-8aa2e7224ad3", clientSecret: "e78030ec-aec5-4f88-987e-2946be161d60")
    }
    
    func deregisterForBluemixPushNotifications(completionHandler: @escaping (String?, Int?, String)->Void) {
        print("Deregistering from Bluemix Push Notifications")
        BMSPushClient.sharedInstance.unregisterDevice(completionHandler: completionHandler)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            let yesAction = UNNotificationAction(identifier: self.yesActionIdentifier, title: "Yes", options: [])
            let noAction = UNNotificationAction(identifier: self.noActionIdentifier, title: "No", options: [])
            let comingToWorkCategory = UNNotificationCategory(identifier: self.comingToWorkCategoryIdentifier, actions: [yesAction,noAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([comingToWorkCategory])
            
            self.getNotificationSettings()
        }
    }
    
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    func onChangePermission(status: Bool) {
        print("Bluemix Push Notifications is enabled: \(status)" as String)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { (data) -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
 
        BMSPushClient.sharedInstance.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) in
            if error.isEmpty {
                print("Bluemix Push response during registration: \(response?.debugDescription ?? "none") and status code is: \(statusCode.debugDescription)")
            } else {
                print("Bluemix Push error during registration: \(error.debugDescription) and status code is: \(statusCode.debugDescription)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // These were for standard notifications direct with APNS
        //UNUserNotificationCenter.current().delegate = self
        //registerForPushNotifications()
        
        // Register for Bluemix push notifications
        
       // registerForBluemixPushNotifications()
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        let userAction = response.actionIdentifier
        
        print("received notification response \(aps["category"].debugDescription)")
        
        let statusService = StatusService()
        
        if (userAction == yesActionIdentifier) {
            statusService.changeStatus(status: "here") { (result) in
                print("user action = here")
                completionHandler()
            }
        } else {
            statusService.changeStatus(status: "away") { (result) in
                print("user action = away")
                completionHandler()
            }
        }
    }
}
