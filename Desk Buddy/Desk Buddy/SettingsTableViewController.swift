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
    let DEFAULTS_NOTIFICATIONOPTIONSSELECTED = "notificationOptionsSelected"
    
    var enableNotifications = false
    var isNotificationsEnabled = false
    
    let notificationOptionsDescriptions = ["Travel time updates","Set status reminders"]

   // var notificationOptionsSelected : [Bool] = [false,false]
    
    struct NotificationOption: Codable {
        var optionName: String
        var isOptionSelected: Bool
        init(optionName: String, isOptionSelected: Bool) {
            self.optionName = optionName
            self.isOptionSelected = isOptionSelected
        }
    }
    
    var notificationOptionsSelected: [NotificationOption] = []
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let subscribeQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // check if we previously have notifications enabled
        print("viewDidLoad called")

        self.notificationOptionsSelected.append(NotificationOption(optionName: "TravelTime", isOptionSelected: false))
        self.notificationOptionsSelected.append(NotificationOption(optionName: "StatusReminder", isOptionSelected: false))
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
        
        //let notificationOptions: [NotificationOption]? = self.userDefaults.object(forKey: self.DEFAULTS_NOTIFICATIONOPTIONSSELECTED) as? [NotificationOption]
    
        readNotificationOptionsSelected()
//        guard let data = self.userDefaults.value(forKey: self.DEFAULTS_NOTIFICATIONOPTIONSSELECTED) as? Data else { return }
//        guard let notificationOptionsSelected = try? PropertyListDecoder().decode(Array<NotificationOption>.self, from: data) else { return }
//        self.notificationOptionsSelected = notificationOptionsSelected
        
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
                        // register for push notifications
                        self.appDelegate.registerForBluemixPushNotifications(pushObserver: self, completeBluemixPushRegistration: { (response, statusCode, error) in
                            print("SettingsTableViewController: received response back from device registration. Can now subscribe to tags")
                            // now set the default notifications
                            self.requestDefaultNotifications()
                        })
                    } else {
                        // deregister from push notifications
                        self.deregisterBluemixNotifications()
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageLabelSwitch", for: indexPath) as! ImageLabelSwitchTableViewCell
                cell.descriptionLabel.text = notificationOptionsDescriptions[indexPath.row-1]
                cell.iconImage.image = UIImage(named: notificationOptionsSelected[indexPath.row-1].optionName)
                cell.selectionStyle = .none
                cell.onOffSwitch.isOn = notificationOptionsSelected[indexPath.row-1].isOptionSelected
                cell.switchChanged = { (isOn) in
                    print("SwettingsTableViewController:notification switch set")
                    if (isOn == true) {
                        // This notification was switched on so subscribe to the associated tag
                        self.subscribeToTag(tagName: self.notificationOptionsSelected[indexPath.row-1].optionName)
                    } else {
                        // This notification was switched off so unsubscribe from the associated tag
                        self.unsubscribeFromTag(tagName: self.notificationOptionsSelected[indexPath.row-1].optionName)
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
    
    func subscribeToTag(tagName: String) {
        guard let indexOfOption = self.notificationOptionsSelected.index(where: { (item) -> Bool in
            item.optionName == tagName
        }) else { return }
        // Subscribe to tag
        let operation = SubscribeTagOperation(withTag: tagName, complete: { (success, statusCode, error) in
            print("Returned from subscribing to \(tagName) with success [\(String(success)) statusCode [\(String(describing: statusCode))]")
            if ((success == true) || (statusCode == 8)) {
                // set the switch to On
                self.notificationOptionsSelected[indexOfOption].isOptionSelected = true
            } else {
                // set the switch to Off
                self.notificationOptionsSelected[indexOfOption].isOptionSelected = false
            }
            self.saveNotificationOptionsSelected()
            // update the table
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }, progressUpdate: nil)
        subscribeQueue.addOperation(operation)
    }
    
    
    func unsubscribeFromTag(tagName: String) {
        guard let indexOfOption = self.notificationOptionsSelected.index(where: { (item) -> Bool in
            item.optionName == tagName
        }) else { return }
        // Unsubscribe from tag
        let operation = UnsubscribeTagOperation(withTag: tagName, complete: { (success, statusCode, error) in
            print("Returned from unsubscribing to \(tagName) with success [\(String(success)) statusCode [\(String(describing: statusCode))]")
            if ((success == true) || (statusCode == 8)) {
                // set the switch to On
                self.notificationOptionsSelected[indexOfOption].isOptionSelected = false
            } else {
                // set the switch to Off
                self.notificationOptionsSelected[indexOfOption].isOptionSelected = true
            }
            self.saveNotificationOptionsSelected()
            // update the table
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }, progressUpdate: nil)
        subscribeQueue.addOperation(operation)
    }
    
    func requestDefaultNotifications() {
        subscribeToTag(tagName: "TravelTime")
        subscribeToTag(tagName: "StatusReminder")
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
    
    func deregisterBluemixNotifications() {
        // 1. Switch off notifications
        // 2. Deregister from Bluemix notifications
        // (Note: deregitering from Bluemix notifications should hopefully unsubscribe you from the tags)
        
        self.appDelegate.deregisterForBluemixPushNotifications(completionHandler: { (response, statusCode, error) in
            print("successfully deregistered from Bluemix push")
            // set defaults to false
            self.userDefaults.set(false, forKey: self.DEFAULTS_ISNOTIFICATIONENABLED)
            self.enableNotifications = false
            // set all notifications to false as deregistering device will unsubscribe them in Bluemix Push service
            for index in 0...self.notificationOptionsSelected.count-1 {
                self.notificationOptionsSelected[index].isOptionSelected = false
            }
            // commit the updated notifiation options selected to user defualts
            self.saveNotificationOptionsSelected()
            // reload the table to adjust the options selected
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        })
        
    }
   
    func saveNotificationOptionsSelected() {
        self.userDefaults.set(try? PropertyListEncoder().encode(self.notificationOptionsSelected), forKey: self.DEFAULTS_NOTIFICATIONOPTIONSSELECTED)
    }
    
    func readNotificationOptionsSelected()  {
        guard let data = self.userDefaults.value(forKey: self.DEFAULTS_NOTIFICATIONOPTIONSSELECTED) as? Data else { return }
        guard let notificationOptionsSelected = try? PropertyListDecoder().decode(Array<NotificationOption>.self, from: data) else { return }
        self.notificationOptionsSelected = notificationOptionsSelected
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
