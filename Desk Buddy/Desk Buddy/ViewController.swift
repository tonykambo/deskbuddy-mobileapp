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
    
    var climateReadings: [Climate]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chart.delegate = self
        updateWeather()
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
    
    func updateClimateGraph(climateReadings: [Climate]) {
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        print("updating climate graph")
        var temperatureData: Array<(x: Double, y: Double)> = []
        
        for index in 0...climateReadings.count-1 {
            temperatureData.append((x: Double(index), y: climateReadings[(climateReadings.count-1)-index].temperature))
            print("x=\(Double(index)) y=\(climateReadings[(climateReadings.count-1)-index].temperature)")
        }
        
        let temperatureSeries = ChartSeries(data: temperatureData)
        temperatureSeries.color = ChartColors.redColor()
        temperatureSeries.area = false
        chart.xLabelsFormatter = {(labelIndex: Int, labelValue: Float) -> String in
            return timeFormatter.string(from: climateReadings[(climateReadings.count-1)-labelIndex].dateMeasured)
        }
        chart.minY = 0
        chart.labelFont = UIFont.systemFont(ofSize: 11.0)
        chart.add(temperatureSeries)
        var humidityData: Array<(x: Double, y: Double)> = []
        for index in 0...climateReadings.count-1 {
            humidityData.append((x: Double(index), y: climateReadings[(climateReadings.count-1)-index].humidity))
            print("x=\(Double(index)) y=\(climateReadings[(climateReadings.count-1)-index].humidity)")
        }
        
        let humiditySeries = ChartSeries(data: humidityData)
        humiditySeries.color = ChartColors.blueColor()
        humiditySeries.area = false
        chart.add(humiditySeries)
        chart.setNeedsDisplay()
    }
    
    func updateWeather() {
        
        print("requesting weather data...")
        let weatherService = TemperatureService()
        
        weatherService.requestTemperature { (result) in
            print("received climate data")
            
            if let readings = result {
                
                if readings.count > 0 {
                    DispatchQueue.main.async() { [unowned self] in
                        self.updateClimateGraph(climateReadings: readings)
                    }
                } else {
                    print("no climate data found")
                }
            }
        }
        
    }
    

    @IBAction func refreshGraph(_ sender: UIBarButtonItem) {
        updateWeather()
    }
    
    @IBAction func changeStatusAway(_ sender: UIButton) {
        let statusService = StatusService()
        
        statusService.changeStatus(status: "away") { (result) in
            print("away")
        }
    }
    
    @IBAction func changeStatusAtWork(_ sender: UIButton) {
        let statusService = StatusService()
        
        statusService.changeStatus(status: "here") { (result) in
            print("away")
        }
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

