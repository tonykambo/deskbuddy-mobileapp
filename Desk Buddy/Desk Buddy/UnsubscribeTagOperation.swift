//
//  UnsubscribeTagOperation.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 12/11/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation
import BMSCore
import BMSPush

class UnsubscribeTagOperation: ServiceOperation {
    
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
        BMSPushClient.sharedInstance.unsubscribeFromTags(tagsArray: [self.tag], completionHandler: { [unowned self] (response, statusCode, error) in
            if error.isEmpty {
                print("Response during unsubscribing to tags: \(response!.description) with statusCode: \(statusCode!)")
                self.complete(true, statusCode, error)
            } else {
                print("Error during unsubscribing to tags \(error) with statusCode: \(statusCode!)")
                self.complete(false, statusCode, error)
            }
            // complete this operation
            self.executing(false)
            self.finish(true)
        })
        
    }
}
