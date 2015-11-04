//
//  HistoryDayViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 31/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import Charts

class HistoryDayViewController: UIViewController, ChartViewDelegate {
    
    var currentRoom: Room!
    var temperature: [Double]!
    var humidity: [Double]!
    var time: [String]!
    var waterLevel: [Double]!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var waterLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // test value
        self.temperature = [20.0, 21.5, 30.0, 28.5, 20.1];
        self.humidity = [30.0, 23.5, 23.5, 21.3, 34];
        self.time = ["6:00", "8:00", "10:00", "12:00", "14:00"]
        self.waterLevel = [180.0, 179.0, 175.0, 174.0, 173.0, 170.0]
        
        // initialize label
        let roomName = self.currentRoom.roomName!
        self.titleLabel.text = "\(roomName) 01/11/2015"
        self.subtitleLabel.text = ""
        self.temperatureLabel.text = ""
        self.humidityLabel.text = ""
        self.waterLevelLabel.text = ""
    
        // set up line chart view
        self.lineChartView.descriptionText = ""
        self.lineChartView.xAxis.labelPosition = .Bottom
        self.lineChartView.xAxis.setLabelsToSkip(0)
        self.lineChartView.xAxis.drawLabelsEnabled = true
        
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.customAxisMin = 0
        self.lineChartView.leftAxis.customAxisMax = 50
        
        self.lineChartView.rightAxis.drawGridLinesEnabled = false
        self.lineChartView.rightAxis.customAxisMin = 0
        self.lineChartView.rightAxis.customAxisMax = 800
        
        // display values in line chart view
        self.setCharts(self.time, values1: self.temperature, values2: self.humidity, values3: self.waterLevel)
        self.lineChartView.delegate = self
    }

    // called when chart value selected
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let index = entry.xIndex
        
        self.subtitleLabel.backgroundColor = UIColor.lightGrayColor()
        self.temperatureLabel.backgroundColor = UIColor(red: 248/255, green: 133/255, blue: 165/255, alpha: 1)
        self.humidityLabel.backgroundColor = UIColor(red: 148/255, green: 205/255, blue: 252/255, alpha: 1)
        self.waterLevelLabel.backgroundColor = UIColor(red: 255/255, green: 237/255, blue: 79/255, alpha: 1)
        
        self.subtitleLabel.text = "Selected Time: \(self.time[index])"
        self.temperatureLabel.text = "Temperature: \(self.temperature[index])°C"
        self.humidityLabel.text = "Humidity: \(self.humidity[index])%"
        self.waterLevelLabel.text = "WaterLevel: \(self.waterLevel[index])L"
    }
    
    // called when chart value not selected
    func chartValueNothingSelected(chartView: ChartViewBase) {
        self.subtitleLabel.text = ""
        self.temperatureLabel.text = ""
        self.humidityLabel.text = ""
        self.waterLevelLabel.text = ""
        
        self.subtitleLabel.backgroundColor = UIColor.whiteColor()
        self.temperatureLabel.backgroundColor = UIColor.whiteColor()
        self.humidityLabel.backgroundColor = UIColor.whiteColor()
        self.waterLevelLabel.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // display the data in line chart view
    func setCharts(dataPoints:[String], values1: [Double], values2:[Double], values3:[Double])
    {
        var dataEntries: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        var dataEntries3: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values1[i], xIndex: i)
            let dataEntry2 = ChartDataEntry(value: values2[i], xIndex: i)
            let dataEntry3 = ChartDataEntry(value: values3[i], xIndex: i)
            dataEntries.append(dataEntry)
            dataEntries2.append(dataEntry2)
            dataEntries3.append(dataEntry3)
        }
        
        // temperature
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Temperature(°C)")
        lineChartDataSet.axisDependency = .Left
        lineChartDataSet.setColor(UIColor(red: 248/255, green: 133/255, blue: 165/255, alpha: 1))
        lineChartDataSet.setCircleColor(UIColor(red: 248/255, green: 133/255, blue: 165/255, alpha: 1))
        lineChartDataSet.lineWidth = 2.5
        lineChartDataSet.circleRadius = 4
        lineChartDataSet.drawCubicEnabled = true
        lineChartDataSet.cubicIntensity = 0.15
        
        // humidity
        let lineChartDataSet2 = LineChartDataSet(yVals: dataEntries2, label: "Humidity(%)")
        lineChartDataSet2.axisDependency = .Left
        lineChartDataSet2.setColor(UIColor(red: 148/255, green: 205/255, blue: 252/255, alpha: 1))
        lineChartDataSet2.setCircleColor(UIColor(red: 148/255, green: 205/255, blue: 252/255, alpha: 1))
        lineChartDataSet2.lineWidth = 2.5
        lineChartDataSet2.circleRadius = 4
        lineChartDataSet2.drawCubicEnabled = true
        lineChartDataSet2.cubicIntensity = 0.15
        
        // waterLevel
        let lineChartDataSet3 = LineChartDataSet(yVals: dataEntries3, label: "WaterLevel(L)")
        lineChartDataSet3.axisDependency = .Right
        lineChartDataSet3.setColor(UIColor(red: 255/255, green: 237/255, blue: 79/255, alpha: 1))
        lineChartDataSet3.setCircleColor(UIColor(red: 255/255, green: 237/255, blue: 79/255, alpha: 1))
        lineChartDataSet3.lineWidth = 2.5
        lineChartDataSet3.circleRadius = 4
        lineChartDataSet3.drawCubicEnabled = true
        lineChartDataSet3.cubicIntensity = 0.15
        
        var dataSets = Array<LineChartDataSet>()
        dataSets.append(lineChartDataSet)
        dataSets.append(lineChartDataSet2)
        dataSets.append(lineChartDataSet3)
        
        let lineChartData = LineChartData(xVals: dataPoints, dataSets: dataSets)
        lineChartView.data = lineChartData
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "otherDaySegue"
        {
            let controller =  segue.destinationViewController as! DayTableViewController
            controller.currentRoom = self.currentRoom
        }
        
        if segue.identifier == "monthSegue"
        {
            let controller = segue.destinationViewController as! MonthTableViewController
            controller.currentRoom = self.currentRoom
        }
    }


}
