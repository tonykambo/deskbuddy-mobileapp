//
//  BeaconItem.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 3/11/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconItem {
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var name: String
    var icon : Int
    var uuid: UUID

    init(name: String, icon: Int, uuid: UUID, majorValue: Int, minorValue: Int) {
        self.name = name
        self.icon = icon
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue)
        self.minorValue = CLBeaconMinorValue(minorValue)
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: name)
    }
}
