//
//  ViewController.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 13/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import UIKit
import SwiftChart
import Charts


class ViewController: UIViewController {
    
    @IBOutlet weak var chart: LineChartView!
    
    @IBOutlet weak var awayButton: UIButton!
    
    @IBOutlet weak var atWorkButton: UIButton!
    
    var climateReadings: [Climate]!

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return UIStatusBarStyle.lightContent
//    }

    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func selectAway(_ sender: UIButton) {
        
        self.atWorkButton.layer.borderWidth = 0
        
        self.awayButton.layer.cornerRadius = 8.0
        
        self.awayButton.layer.borderColor = UIColor.white.cgColor
        
        self.awayButton.layer.borderWidth = 2.0
        self.awayButton.clipsToBounds = true
        
    }
    
    
    @IBAction func selectAtWork(_ sender: UIButton) {
        
        
        self.awayButton.layer.borderWidth = 0
        
        
        
        self.atWorkButton.layer.cornerRadius = 8.0
        
        self.atWorkButton.layer.borderColor = UIColor.white.cgColor
        
        self.atWorkButton.layer.borderWidth = 2.0
        self.atWorkButton.clipsToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //chart.delegate = self
        
        
        let blueColor = UIColor(colorLiteralRed: 0x02/255.0, green: 0x68/255.0, blue: 0xA2/255.0, alpha: 0xFF/255.0)
        
        
        self.awayButton.layer.cornerRadius = 8.0
        
        self.awayButton.layer.borderColor = UIColor.white.cgColor
        
        self.awayButton.layer.borderWidth = 2.0
        self.awayButton.clipsToBounds = true
        
        
        
//        UINavigationBar.appearance().backgroundColor = blueColor
//        UINavigationBar.appearance().tintColor = blueColor
        
        
        self.navigationController?.navigationBar.barTintColor = blueColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        

        chart.noDataText = "No climate data available."
        
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
        
        var temperatureDataEntries: [ChartDataEntry] = []
        for i in 0..<climateReadings.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: climateReadings[(climateReadings.count-1)-i].temperature)
            temperatureDataEntries.append(dataEntry)
        }
        let temperatureDataSet = LineChartDataSet(values: temperatureDataEntries, label: "Temperature (°C)")
        
        
        let redColor = UIColor(colorLiteralRed: 0xFC/255.0, green: 0x3E/255.0, blue: 0x30/255.0, alpha: 0xFF/255.0)

      
        
        
        temperatureDataSet.circleColors = [redColor]
        temperatureDataSet.setColor(redColor)
        temperatureDataSet.circleRadius = 2.0
        temperatureDataSet.valueFont = UIFont(name: "Helvetica", size: 14)!
        temperatureDataSet.valueColors = [redColor]
    
        
        var humidityDataEntries: [ChartDataEntry] = []
        for i in 0..<climateReadings.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: climateReadings[(climateReadings.count-1)-i].humidity)
            humidityDataEntries.append(dataEntry)
        }
        let humidityDataSet = LineChartDataSet(values: humidityDataEntries, label: "Humidity (%)")
        
       
        let blueColor = UIColor(colorLiteralRed: 0x0F/255.0, green: 0x7D/255.0, blue: 0xB5/255.0, alpha: 0xFF/255.0)
        
    
        humidityDataSet.circleColors = [blueColor]
        humidityDataSet.circleColors = [blueColor]
        humidityDataSet.setColor(blueColor)
        humidityDataSet.circleRadius = 2.0
        humidityDataSet.valueFont = UIFont(name: "Helvetica", size: 14)!
        humidityDataSet.valueColors = [blueColor]
    
        
        // Set the x Axis labels
        
        let times = climateReadings.map { (climate) -> String in
            timeFormatter.string(from: climate.dateMeasured)
        }
        
        let chartFormatter = ChartFormatter(labels: times.reversed())
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        chart.xAxis.valueFormatter = xAxis.valueFormatter
        
        xAxis.granularityEnabled = true
        
       
        // Change the minimum value of the left axis
        
        //chart.leftAxis.axisMinimum = 0
        
        
        // Right Axis Configuration
        
        chart.rightAxis.axisMinimum = 0
        chart.rightAxis.enabled = false
        chart.rightAxis.drawLabelsEnabled = false
       
        chart.doubleTapToZoomEnabled = false
        //chart.dragEnabled = false
        
        
        chart.leftAxis.drawGridLinesEnabled = true
        chart.rightAxis.drawGridLinesEnabled = false
        
        // Set the x axis grid lines to be light gray and wafer thin
        
        chart.leftAxis.gridLineWidth = 0.1
        chart.leftAxis.gridColor = UIColor.lightGray
        
        chart.xAxis.drawGridLinesEnabled = false
        
    
        //chart.leftAxis.drawLabelsEnabled = false
        
        
        chart.rightAxis.drawAxisLineEnabled = false
        //chart.grid
        
        
        chart.chartDescription?.text = ""
        chart.drawGridBackgroundEnabled = false
        chart.drawBordersEnabled = false
        
        // the line next to the left axis labels
        
        chart.leftAxis.drawAxisLineEnabled = false
        
        // the line next to the x axis labels
        
        chart.xAxis.drawAxisLineEnabled = false
        
        var climateDataSet: [LineChartDataSet] = []
        
        climateDataSet.append(temperatureDataSet)
        climateDataSet.append(humidityDataSet)
        
        let lineChartData = LineChartData(dataSets: climateDataSet)

        chart.xAxis.granularityEnabled = true
        chart.xAxis.granularity = 1.0
        
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom

        chart.xAxis.labelTextColor = UIColor.lightGray
        chart.leftAxis.labelTextColor = UIColor.lightGray
        
        chart.xAxis.labelFont = UIFont(name: "Helvetica", size: 14)!
        chart.leftAxis.labelFont = UIFont(name: "Helvetica", size: 14)!
        
        
        chart.backgroundColor = UIColor.white
        
        chart.xAxis.spaceMin = 0.3
        chart.xAxis.spaceMax = 0.3
        
        //chart.xAxis.avoidFirstLastClippingEnabled = true
        
        chart.legend.font = UIFont(name: "Helvetica", size: 14)!
        
        chart.data = lineChartData

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


}

