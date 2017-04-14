//
//  ViewController.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 13/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit
import SwiftChart

class ViewController: UIViewController, ChartDelegate {
    
    @IBOutlet weak var chart: Chart!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let chart = Chart(frame: CGRect.zero)
//        let series = ChartSeries([0, 6.5, 2, 8, 4.1, 7, -3.1, 10, 8])
//        chart.add(series)
//        let data = [(x: 0, y: 0), (x: 0.5, y: 3.1), (x: 1.2, y: 2), (x: 2.1, y: -4.2), (x: 2.6, y: 1.1)]
        
      //  let data : Array<Float> = [0, 6.5, 2.8, 8, 4.1, 8, 4, 5, 8]
//        let series = ChartSeries(data: data)
//        chart.add(series)
        
        chart.delegate = self
//        
        let temperature = [(x: 0.0, y: 23.5), (x: 3, y: 23.4), (x: 4, y: 23.7), (x: 5, y: 24.3), (x: 7, y: 25), (x: 8, y: 26.2), (x: 9, y: 23)]
        let series = ChartSeries(data: temperature)
        series.color = ChartColors.blueColor()
        series.area = true
        chart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
        chart.xLabelsFormatter = { String(Int(round($1))) + "h" }
        chart.minY = 0.0
        chart.add(series)
        
        let humidity = [(x: 0.0, y: 53.5), (x: 3, y: 53.4), (x: 4, y: 53.7), (x: 5, y: 64.3), (x: 7, y: 45), (x: 8, y: 66.2), (x: 9, y: 53)]
        let humiditySeries = ChartSeries(data: humidity)
        humiditySeries.color = ChartColors.greenColor()
        
        chart.add(humiditySeries)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
            }
        }
    }
    
    @IBAction func requestWeather(_ sender: UIButton) {
        
        let weatherService = TemperatureService()
        
        weatherService.requestTemperature()
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        // nothing
    }
    
//    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
//        for (serieIndex, dataIndex) in indexes.enumerated() {
//            if dataIndex != nil {
//                // The series at serieIndex has been touched
//                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
//            }
//        }
//    }
//
//    func didFinishTouchingChart(chart: Chart) {
//        // Do something when finished
//    }

}

