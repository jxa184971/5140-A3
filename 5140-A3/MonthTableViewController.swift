//
//  MonthTableViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 1/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit

class MonthTableViewController: UITableViewController {

    var availableMonths: Array<String>!
    var currentRoom:Room!
    var controller: HistoryMonthViewController!
    
    var coapClient: SCClient!
    let separatorLine = "\n-----------------\n"
    let port = "5683"
    var host = "127.0.0.1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        availableMonths = Array<String>()
        
        self.host = self.currentRoom.ip!
        
        // set up coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.availableMonths = Array<String>()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.stringFromDate(NSDate())
        self.sendMessage("temperature/dailyaverage?start=2015-09-01&end=\(today)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.availableMonths.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("monthCell", forIndexPath: indexPath) as! DayCell
        cell.dateLabel.text = "\(self.availableMonths[indexPath.row])"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.controller.month = self.availableMonths[indexPath.row]
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

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "monthHistorySegue"
        {
            let controller = segue.destinationViewController as! HistoryMonthViewController
            controller.currentRoom = self.currentRoom
            self.controller = controller
        }
    }
}

extension MonthTableViewController: SCClientDelegate {
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
                var monthSet = NSMutableSet()
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(pay, options: NSJSONReadingOptions.AllowFragments)
                    let resultJSON = json as! NSDictionary
                    let resultArray = resultJSON.valueForKey("result") as! NSArray
                    for var i = 0; i < resultArray.count; i++
                    {
                        let result = resultArray[i] as! NSDictionary
                        let month = result.valueForKey("month") as! Int
                        let monthString = "2015-\(month)"
                        monthSet.addObject(monthString)
                    }
                    self.availableMonths = monthSet.allObjects as! Array<String>
                }
                catch _
                {
                    print("Error in parsing data into json")
                }
                self.tableView.reloadData()
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
        
        self.tableView.reloadData()
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        print("Failed with Error \(error.localizedDescription)")
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        let errorString = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n"
        print(errorString)
    }
}
