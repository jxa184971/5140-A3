//
//  MonitoringViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 29/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import Charts

class MonitoringViewController: UIViewController {

    @IBOutlet var lineChartView: LineChartView!

    var currentRoom:Room!
    
    let separatorLine = "\n-----------------\n"
    var coapClient: SCClient!
    var host: String!
    let port = "5683"
    
    var xAxis:[String]!
    var temperature: [Double]!
    var humidity: [Double]!
    var waterLevel: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.currentRoom.roomName
        
        // test value
        self.xAxis = []
        self.temperature = []
        self.humidity = []
        self.waterLevel = []
        
        // initialize line chart view
        self.lineChartView.noDataText = "Error: No Data retrived from server."
        self.lineChartView.descriptionText = ""
        self.lineChartView.xAxis.labelPosition = .Bottom
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        self.lineChartView.xAxis.setLabelsToSkip(0)
        self.lineChartView.xAxis.drawLabelsEnabled = false
        
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.customAxisMin = 0
        self.lineChartView.leftAxis.customAxisMax = 50

        self.lineChartView.rightAxis.drawGridLinesEnabled = false
        self.lineChartView.rightAxis.customAxisMin = 0
        self.lineChartView.rightAxis.customAxisMax = 800

        // display the value in line chart view
        self.setCharts(self.xAxis, values1: self.temperature, values2: self.humidity, values3: self.waterLevel)

        // setup coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
        self.host = self.currentRoom.ip
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sendMessage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coapClient.cancelObserve()
    }
    
    func sendMessage() {
        let message = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        
        let buffer: [UInt8] = [0x00, 0xff]
        message.addOption(SCOption.Observe.rawValue, data: NSData(bytes: buffer, length: 1))
        
        /*
        if let stringData = "".dataUsingEncoding(NSUTF8StringEncoding) {
            message.addOption(SCOption.UriPath.rawValue, data: stringData)
            message.addOption(SCOption.Observe.rawValue, data: NSData(bytes: [0] as! UnsafePointer, length: 1));
        }*/
        
        
        coapClient.sendCoAPMessage(message, hostName: self.host, port: UInt16(port)!)
        
    }
    
    //set up the line chart view
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
        
        //waterLevel
        let lineChartDataSet3 = LineChartDataSet(yVals: dataEntries3, label: "WaterLevel")
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
    
       
    func addNewRecord(xAxis: String, temperature: Double, humidity: Double, waterLevel:Double)
    {
        if self.xAxis.count >= 6
        {
            self.xAxis.removeFirst()
            self.xAxis.append(xAxis)
            
            self.temperature.removeFirst()
            self.temperature.append(temperature)
            
            self.humidity.removeFirst()
            self.humidity.append(humidity)
            
            self.waterLevel.removeFirst()
            self.waterLevel.append(waterLevel)
        }
        else
        {
            self.xAxis.append(xAxis)
            self.temperature.append(temperature)
            self.humidity.append(humidity)
            self.waterLevel.append(waterLevel)
        }
        self.setCharts(self.xAxis, values1: self.temperature, values2: self.humidity, values3: self.waterLevel)
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


extension MonitoringViewController: SCClientDelegate {
    
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
            }
            
            do
            {
                let json = try NSJSONSerialization.JSONObjectWithData(pay, options: NSJSONReadingOptions.AllowFragments)
                let resultJSON = json as? NSDictionary
                
                let temperatureEntry = resultJSON?.valueForKey("temperature") as! NSDictionary
                let tempString = temperatureEntry.valueForKey("value") as! Double
                let temp = Double(tempString) / 1000
                
                let humidityEntry = resultJSON?.valueForKey("humidity") as! NSDictionary
                let humidityString = humidityEntry.valueForKey("value") as! Double
                let humidity = Double(humidityString) / 1000
                
                let liquidEntry = resultJSON?.valueForKey("liquid") as! NSDictionary
                let waterLevelString = liquidEntry.valueForKey("value") as! Double
                let waterLevel = Double(waterLevelString)
                
                self.addNewRecord("", temperature: temp, humidity: humidity, waterLevel: waterLevel)
            }
            catch _
            {
                print("Error in parsing data into json")
            }
        }
        let firstPartString = "Message received with type: \(message.type.shortString())\nwith code: \(message.code.toString()) \nwith id: \(message.messageId)\nPayload: \(payloadstring)"
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
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        print("Failed with Error \(error.localizedDescription)" + separatorLine + separatorLine)
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        print("Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n" + separatorLine + separatorLine)
    }
}
