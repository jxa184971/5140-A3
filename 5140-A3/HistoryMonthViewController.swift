//
//  HistoryMonthViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 1/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import Charts

class HistoryMonthViewController: UIViewController, ChartViewDelegate {

    var currentRoom: Room!
    var month: String!
    var temperature: [Double]!
    var humidity: [Double]!
    var days: [String]!
    var waterLevel: [Double]!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var waterLevelLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // test value
        self.temperature = [20.0, 21.5, 30.0, 28.5, 20.1, 20.5, 23.8, 27.8, 19.0, 30.0];
        self.humidity = [30.0, 23.5, 23.5, 21.3, 34.0, 30.0, 29.0, 30.0, 27.5, 26.6];
        self.days = ["1/10/2015", "2/10/2015", "3/10/2015", "4/10/2015", "5/10/2015", "6/10/2015", "7/10/2015", "8/10/2015", "9/10/2015", "10/10/2015"]
        self.waterLevel = [180.0, 179.0, 175.0, 174.0, 173.0, 170.0, 168.0, 500.0, 450.0, 435.0]
        
        // initialize label
        let roomName = self.currentRoom.roomName!
        self.titleLabel.text = "\(roomName) \(self.month)"
        self.subtitleLabel.text = ""
        self.temperatureLabel.text = ""
        self.humidityLabel.text = ""
        self.waterLevelLabel.text = ""
        
        // set up line chart view
        self.barChartView.descriptionText = ""
        self.barChartView.xAxis.labelPosition = .Bottom
        
        self.barChartView.leftAxis.drawGridLinesEnabled = false
        self.barChartView.leftAxis.customAxisMin = 0
        self.barChartView.leftAxis.customAxisMax = 50
        
        self.barChartView.rightAxis.drawGridLinesEnabled = false
        self.barChartView.rightAxis.customAxisMin = 0
        self.barChartView.rightAxis.customAxisMax = 800
        
        // display values in line chart view
        self.setCharts(self.days, values1: self.temperature, values2: self.humidity, values3: self.waterLevel)
        self.barChartView.delegate = self

    }

    // called when chart value selected
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let index = entry.xIndex
        
        self.subtitleLabel.backgroundColor = UIColor.lightGrayColor()
        self.temperatureLabel.backgroundColor = UIColor(red: 248/255, green: 133/255, blue: 165/255, alpha: 1)
        self.humidityLabel.backgroundColor = UIColor(red: 148/255, green: 205/255, blue: 252/255, alpha: 1)
        self.waterLevelLabel.backgroundColor = UIColor(red: 255/255, green: 237/255, blue: 79/255, alpha: 1)
        
        self.subtitleLabel.text = "Selected Day: \(self.days[index])"
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
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries2: [BarChartDataEntry] = []
        var dataEntries3: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values1[i], xIndex: i)
            let dataEntry2 = BarChartDataEntry(value: values2[i], xIndex: i)
            let dataEntry3 = BarChartDataEntry(value: values3[i], xIndex: i)
            dataEntries.append(dataEntry)
            dataEntries2.append(dataEntry2)
            dataEntries3.append(dataEntry3)
        }
        
        // temperature
        let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "Temperature(°C)")
        barChartDataSet.axisDependency = .Left
        barChartDataSet.setColor(UIColor(red: 248/255, green: 133/255, blue: 165/255, alpha: 1))
        
        // humidity
        let barChartDataSet2 = BarChartDataSet(yVals: dataEntries2, label: "Humidity(%)")
        barChartDataSet2.axisDependency = .Left
        barChartDataSet2.setColor(UIColor(red: 148/255, green: 205/255, blue: 252/255, alpha: 1))

        
        // waterLevel
        let barChartDataSet3 = BarChartDataSet(yVals: dataEntries3, label: "WaterLevel(L)")
        barChartDataSet3.axisDependency = .Right
        barChartDataSet3.setColor(UIColor(red: 255/255, green: 237/255, blue: 79/255, alpha: 1))

        
        var dataSets = Array<BarChartDataSet>()
        dataSets.append(barChartDataSet)
        dataSets.append(barChartDataSet2)
        dataSets.append(barChartDataSet3)
        
        let barChartData = BarChartData(xVals: dataPoints, dataSets: dataSets)
        barChartView.data = barChartData
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
