//
//  RoomDetailTableViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 27/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class RoomDetailTableViewController: UITableViewController {
    
    var currentRoom: Room!
    var managedObjectContext:NSManagedObjectContext!
    
    let separatorLine = "\n-----------------\n"
    var coapClient: SCClient!
    var host: String!
    let port = "5683"
    
    var temperature: Double!
    var humidity:Double!
    var waterLevel: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = "Room \(self.currentRoom.roomName)"

        // setup coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
        self.host = self.currentRoom.ip
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sendMessage()
        self.tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage() {
        let message = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        
        if let stringData = "latest".dataUsingEncoding(NSUTF8StringEncoding) {
            message.addOption(SCOption.UriPath.rawValue, data: stringData)
        }
    
        coapClient.sendCoAPMessage(message, hostName: self.host, port: UInt16(port)!)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("roomDetailCell", forIndexPath: indexPath) as! RoomDetailCell
            let roomName = self.currentRoom.roomName! as String
            let plant = self.currentRoom.plant! as String
            cell.roomNameLabel.text = "Room Name: \(roomName)"
            cell.plantLabel.text = "Plant: \(plant)"
            cell.aveTempLabel.text = "Current Temperature: \(self.temperature)°C"
            cell.aveHumidityLabel.text = "Current Humidity: \(self.humidity)%"
            cell.waterLevelLabel.text = "Current Water Level: \(self.waterLevel)L"
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("realTimeButtonCell", forIndexPath: indexPath) as! ButtonTableViewCell
            cell.buttonLabel.text = "Real-Time Monitoring"
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("historyButtonCell", forIndexPath: indexPath) as! ButtonTableViewCell
            cell.buttonLabel.text = "History Records"
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0
        {
            return 35.0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0
        {
            return 35.0
        }
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0
        {
            return 120
        }
        return 44
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "realTimeSegue"
        {
            let controller = segue.destinationViewController as! MonitoringViewController
            controller.currentRoom = self.currentRoom
        }
        if segue.identifier == "historySegue"
        {
            let controller = segue.destinationViewController as! HistoryDayViewController
            controller.currentRoom = self.currentRoom
        }
    }

}

extension RoomDetailTableViewController: SCClientDelegate {
    
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
                self.temperature = Double(tempString) / 1000
                
                let humidityEntry = resultJSON?.valueForKey("humidity") as! NSDictionary
                let humidityString = humidityEntry.valueForKey("value") as! Double
                self.humidity = Double(humidityString) / 1000
                
                let liquidEntry = resultJSON?.valueForKey("liquid") as! NSDictionary
                let waterLevelString = liquidEntry.valueForKey("value") as! Double
                self.waterLevel = Double(waterLevelString)
                
                self.tableView.reloadData()
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
