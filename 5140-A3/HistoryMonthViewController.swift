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
    
    var coapClient: SCClient!
    let separatorLine = "\n-----------------\n"
    let port = "5683"
    var host = "127.0.0.1"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var waterLevelLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.host = self.currentRoom.ip!
        
        // set up coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
        
        // send message for getting monthly data
        let dateArray = self.month.componentsSeparatedByString("-")
        let monthString = dateArray[1]
        let monthInt = Int(monthString)
        let nextMonthString = "2015-\(monthInt!+1)"
        self.sendMessage("temperature/dailyaverage?start=\(self.month)-01&end=\(nextMonthString)-01")
        self.sendMessage("humidity/dailyaverage?start=\(self.month)-01&end=\(nextMonthString)-01")
        self.sendMessage("liquid/dailyaverage?start=\(self.month)-01&end=\(nextMonthString)-01")
        
        self.temperature = []
        self.humidity = []
        self.days = []
        self.waterLevel = []
        
        // initialize label
        let roomName = self.currentRoom.roomName!
        self.titleLabel.text = "Room \(roomName): \(self.month)"
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
    
    
    // send message to COAP server
    func sendMessage(urlPath: String)
    {
        let message = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        
        if let stringData = urlPath.dataUsingEncoding(NSUTF8StringEncoding) {
            message.addOption(SCOption.UriPath.rawValue, data: stringData)
        }
        
        coapClient.sendCoAPMessage(message, hostName: self.host, port: UInt16(self.port)!)
        
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

extension HistoryMonthViewController: SCClientDelegate {
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
                var dayArray = Array<String>()
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(pay, options: NSJSONReadingOptions.AllowFragments)
                    let resultJSON = json as! NSDictionary
                    let dateType = resultJSON.valueForKey("datatype") as! String
                    if (dateType == "temperature")
                    {
                        var tempArray = Array<Double>()
                        let resultArray = resultJSON.valueForKey("result") as! NSArray
                        for var i = 0; i < resultArray.count; i++
                        {
                            let result = resultArray[i] as! NSDictionary
                            let month = result.valueForKey("month") as! Int
                            let day = result.valueForKey("day") as! Int
                            
                            let dayString = "2015-\(month)-\(day)"
                            dayArray.append(dayString)
                            
                            let value = result.valueForKey("value") as! Double
                            tempArray.append(value)
                        }
                        self.days = dayArray
                        self.temperature = tempArray
                    }
                    if (dateType == "humidity")
                    {
                        var array = Array<Double>()
                        let resultArray = resultJSON.valueForKey("result") as! NSArray
                        for var i = 0; i < resultArray.count; i++
                        {
                            let result = resultArray[i] as! NSDictionary
                            let value = result.valueForKey("value") as! Double
                            array.append(value)
                        }
                        self.humidity = array
                    }
                    if (dateType == "liquid")
                    {
                        var array = Array<Double>()
                        let resultArray = resultJSON.valueForKey("result") as! NSArray
                        for var i = 0; i < resultArray.count; i++
                        {
                            let result = resultArray[i] as! NSDictionary
                            let value = result.valueForKey("value") as! Double
                            array.append(value)
                        }
                        self.waterLevel = array
                    }
                }
                catch _
                {
                    print("Error in parsing data into json")
                }
            }
        }
        
        
        
        let firstPartString = "Message received with type: \(message.type.shortString())\nwith code: \(message.code.toString()) \nwith id: \(message.messageId)\nPayload: \(payloadstring)\n"
        var optString = "Options:\n"
        for (key, _) in message.options {
            var optName = "Unknown"
            
            if let knownOpt = SCOption(rawValue: key) {
                optName = knownOpt.toString()
            }
            
            optString += "\(optName) (\(key))"
            
            //Add this lines to display the respective option values in the message log
            /*
            for value in valueArray {
            optString += "\(value)\n"
            }
            optString += separatorLine
            */
        }
        print(separatorLine + firstPartString + optString + separatorLine)
        
        self.setCharts(self.days, values1: self.temperature, values2: self.humidity, values3: self.waterLevel)
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        print("Failed with Error \(error.localizedDescription)")
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        let errorString = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n"
        print(errorString)
    }
}

