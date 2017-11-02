//
//  ImageLabelSwitchTableViewCell.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 19/10/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit

class ImageLabelSwitchTableViewCell: UITableViewCell {

    var switchChanged: ((_ isOn: Bool)-> Void)?
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        self.switchChanged?(sender.isOn)
    }
    
}
