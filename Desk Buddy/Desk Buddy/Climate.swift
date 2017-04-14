//
//  Climate.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 14/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation

struct Climate {
    
    var temperature: Double
    var humidity: Double
    var heatIndex: Double
    var dateTime: Date
}


extension Climate {
    
    init?(json: [String:Any]) {
        guard let temperature = json["temperature"] as? Double,
            let humidity = json["humidity"] as? Double,
            let heatIndex = json["heatIndex"] as? Double,
            let dateTimeRaw = json["dateTime"] as? String
            else {
                return nil
        }
        
        self.temperature = temperature
        self.humidity = humidity
        self.heatIndex = heatIndex
        self.dateTime = Date()
    }
}
