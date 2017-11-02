//
//  NotificationsManager.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 19/10/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation
import BMSCore
import BMSPush

class NotificationsManager {
    static let shared = NotificationsManager()
    
    var notificationOptionsSelected : [Bool] = [false,false]
    
    private init() {
        print("NotificationManager initialised")
    }
    
    func registerNotifications() -> Bool {
        
        // request permission for notifications
        
        // if allowd return true otherwise false
        return true
    }
    
    func registerForBluemixPushNotifications() {
        
        BMSClient.sharedInstance.initialize(bluemixRegion: BMSClient.Region.usSouth)
        BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: "21389e62-6bb3-4039-80aa-8aa2e7224ad3", clientSecret: "e78030ec-aec5-4f88-987e-2946be161d60")
    }
}
