//
//  SettingsTableViewController.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 18/10/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit
import BMSCore
import BMSPush

class SettingsTableViewController: UITableViewController, BMSPushObserver {
    
    let userDefaults = UserDefaults.standard
  
    let DEFAULTS_ISNOTIFICATIONENABLED = "isNotificationsEnabled"
    
    var enableNotifications = false
    var isNotificationsEnabled = false
    
    let notificationOptionsDescriptions = ["Travel time updates","Set status reminders"]

    var notificationOptionsSelected : [Bool] = [false,false]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // check if we previously have notifications enabled
        print("viewDidLoad called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear called")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        let notificationsEnabled = self.userDefaults.bool(forKey: self.DEFAULTS_ISNOTIFICATIONENABLED)
        print("viewWillAppear:Loading notification settings from user defaults - notificationsEnabled=[\(notificationsEnabled)]")
        if (notificationsEnabled == true) {
            self.enableNotifications = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0) {
            if (enableNotifications == true) {
                return 1+notificationOptionsDescriptions.count
            } else {
                return 1
            }
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath) as! SettingsTableViewCell
                
                cell.settingsName.text = "Enable push notifications"
                cell.settingsEnabled.isOn = self.enableNotifications
                cell.selectionStyle = .none
                cell.notificationChanged = { (isOn) in
                    print("SettingsTableViewController:switch changed to \(isOn)")
                    
                    if (isOn == true) {
                        self.enableNotifications = true
                        
                        DispatchQueue.main.async { [unowned self] in
                            self.tableView.reloadData()
                        }
                    
                        // enable notifications
                        // register for push notifications
                   
                        self.appDelegate.registerForBluemixPushNotifications(pushObserver: self)
                        
//
//                        if (NotificationsManager.shared.registerNotifications()) {
//                            // user gave permission for notifications and notifications are registered
//                        }
//
//                    } else {
//
//                        // disable notifications
//
//                    }
                    } else {
                        // 1. Switch off notifications
                        // 2. Deregister from Bluemix notifications
                        // (Note: deregitering from Bluemix notifications should hopefully unsubscribe you from the tags)
                        
                        
                        self.appDelegate.deregisterForBluemixPushNotifications(completionHandler: { (response, statusCode, error) in
                            print("successfully deregistered from Bluemix push")
                            // set defaults to false
                            self.userDefaults.set(false, forKey: self.DEFAULTS_ISNOTIFICATIONENABLED)
                            self.enableNotifications = false
                            
                            DispatchQueue.main.async { [unowned self] in
                                self.tableView.reloadData()
                            }
                        })
                    }
                    
  
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageLabelSwitch", for: indexPath) as! ImageLabelSwitchTableViewCell
                
                cell.descriptionLabel.text = notificationOptionsDescriptions[indexPath.row-1]
                cell.selectionStyle = .none
                cell.onOffSwitch.isOn = notificationOptionsSelected[indexPath.row-1]
                cell.switchChanged = { (isOn) in
                    print("SwettingsTableViewController:notification switch set")
                    
                    //let currentOption = NotificationsManager.shared.notificationOptionsSelected[indexPath.row-1]
                    
                    //NotificationsManager.shared.notificationOptionsSelected[indexPath.row-1] = !currentOption
                    
                    if (isOn == true) {
                        // This notification was switched on so subscribe to the associated tag
                        
                        
                    } else {
                        // This notification was switched off so unsubscribe from the associated tag
                        
                    }
                    
                }
                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic")!
            return cell
        }

        
    }
    
    @IBAction func closeSettings(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
        
    
    func onChangePermission(status: Bool) {
        if (status == true) {
            // notifications were accepted by user
            print("User allowed permission to receive notifications")
            self.enableNotifications = true
            
            // Set user defualts
            self.userDefaults.set(true, forKey: self.DEFAULTS_ISNOTIFICATIONENABLED)
            
            // Update the table accordingly
            
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
           //UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // now we subscribe to the default list of notifications
            let subscribeQueue = OperationQueue()
            // Subscribe to StatusReminder
            let travelTimeTagOperation = SubscribeTagOperation(withTag: "TravelTime", complete: { (success, statusCode, error) in
                print("Returned from subscribing to TravelTime with success [\(String(success)) statusCode [\(String(describing: statusCode))]")
                if ((success == true) || (statusCode == 8)) {
                    // set the switch to On
                    self.notificationOptionsSelected[1] = true
                } else {
                    // set the switch to Off
                    self.notificationOptionsSelected[1] = false
                }
                // update the table
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            }, progressUpdate: nil)
            
            // Subscribe to StatusReminder
            let statusReminderTagOperation = SubscribeTagOperation(withTag: "StatusReminder", complete: { (success, statusCode, error) in
                print("Returned from subscribing to StatusReminder with success [\(String(success)) statusCode [\(String(describing: statusCode))]")
                if ((success == true) || (statusCode == 8)) {
                    // set the switch to On
                    self.notificationOptionsSelected[0] = true
                } else {
                    // set the switch to Off
                    self.notificationOptionsSelected[0] = false
                }
                // update the table
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            }, progressUpdate: nil)
            
            subscribeQueue.addOperations([statusReminderTagOperation,travelTimeTagOperation], waitUntilFinished: false)
            
            
            // Subscribe to motion alerts
//
//            BMSPushClient.sharedInstance.subscribeToTags(tagsArray: ["StatusReminder"], completionHandler: { (response, statusCode, error) in
//                if error.isEmpty {
//                    print("Response during subscribing to tags: \(response!.description) with statusCode: \(statusCode!)")
//                } else {
//                    print("Error during subscribing to tags \(error) with statusCode: \(statusCode!)")
//
//                 // automatically disable notifications in settings
//
//                    self.enableNotifications = false
//
//                    DispatchQueue.main.async { [unowned self] in
//                        self.tableView.reloadData()
//                    }
//
//                }
//            })
            
            
        } else {
            // user did not allow notifications
            
            // 1. Switch off notifications 
            // 2. Deregister from Bluemix notifications
            // (Note: deregitering from Bluemix notifications should hopefully unsubscribe you from the tags)
            
            // switch off the setting
            
            print("User did not alow for notifications")
            
            // Set user defualts
            self.userDefaults.set(false, forKey: self.DEFAULTS_ISNOTIFICATIONENABLED)
            self.enableNotifications = false
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
        
    }
   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
