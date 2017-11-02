//
//  SubscribeTagOperation.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 29/10/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation
import BMSCore
import BMSPush

class SubscribeTagOperation: ServiceOperation {
    
    let DEFAULTS_NOTIFICATIONS = "isNotificationsEnabled"
    
    let userDefaults = UserDefaults.standard
    
    private var tag: String
    
    let progressUpdate : ((_ updateMessage: String?)->Void)?
    
    let complete: (_ success: Bool, _ statusCode: Int?, _ error: String?)->Void
    
    // call with tag to subscribe

    init(withTag tag: String, complete: @escaping (_ success: Bool, _ statusCode: Int?, _ error: String?)->Void, progressUpdate: ((_ updateMessage: String?)->Void)?) {
        self.tag = tag
        self.progressUpdate = progressUpdate
        self.complete = complete
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        BMSPushClient.sharedInstance.subscribeToTags(tagsArray: [self.tag], completionHandler: { [unowned self] (response, statusCode, error) in
            if error.isEmpty {
                print("Response during subscribing to tags: \(response!.description) with statusCode: \(statusCode!)")
                
                //self.userDefaults.set(true, forKey: self.DEFAULTS_NOTIFICATIONS)
                
                self.complete(true, statusCode, error)
                
            } else {
                print("Error during subscribing to tags \(error) with statusCode: \(statusCode!)")
                
                self.complete(false, statusCode, error)
                
                
                // automatically disable notifications in settings
                
                
                
//                self.enableNotifications = false
//
//                DispatchQueue.main.async { [unowned self] in
//                    self.tableView.reloadData()
//                }
                
                // Set user defaults notifications setting to off
                
               // self.userDefaults.set(false, forKey: self.DEFAULTS_NOTIFICATIONS)
            }
            
            // complete this operation
            
            self.executing(false)
            self.finish(true)
        })
        
    }
}
