//
//  SettingsTableViewCell.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 18/10/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    var notificationChanged: ((_ isOn: Bool) -> Void)?
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var settingsEnabled: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func enableNotifications(_ sender: UISwitch) {
        print("switch changed")
        self.notificationChanged?(sender.isOn)
    }
}
