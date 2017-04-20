//
//  ChartFormatter.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 18/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation
import Charts

class ChartFormatter: NSObject, IAxisValueFormatter {
    var labels: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if ((value < 0) || (value >= Double(labels.count))) {
            return ""
        }
        return labels[Int(value)]
    }
    
    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
}
