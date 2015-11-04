//
//  RoomListTableViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 25/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class RoomListTableViewController: UITableViewController {
    
    var rooms:Array<Room>!
    var managedObjectContext:NSManagedObjectContext!
    var controller: RoomDetailTableViewController!
    var server:CentralServer!
    
    var coapClient: SCClient!
    let separatorLine = "\n-----------------\n"
    let port = "5683"
    var host = "127.0.0.1"

    @IBOutlet var noRoomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.hidden = false
        
        
        
        /*
        let fetchRequest = NSFetchRequest(entityName: "Room")
        do
        {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if results.count == 0
            {
                self.noRoomLabel.text = "There is no room stored in the database"
                self.rooms = Array<Room>()
            }
            else
            {
                self.rooms = results as! Array<Room>
                self.noRoomLabel.text = ""
            }
        }
        catch
        {
            print("Could not fetch data of entity room")
        }
        */
        
        let fetchRequest1 = NSFetchRequest(entityName: "CentralServer")
        do
        {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest1)
            if results.count == 0
            {
                self.noRoomLabel.text = "Not Setting Central Server Yet. Go to Setting View to setup first."
            }
            else
            {
                self.server = results.first as! CentralServer
                if self.server.ip == "Not Setting Yet"
                {
                    self.noRoomLabel.text = "Not Setting Central Server Yet. Go to Setting View to setup first"
                }
                else
                {
                    print("\(self.server.ip!)")
                    self.host = self.server.ip!
                }
            }
        }
        catch
        {
            print("Could not fetch data of entity room")
        }
        
        self.sendMessage("device")
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rooms.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("roomCell", forIndexPath: indexPath) as! RoomCell
        cell.roomNameLabel.text = self.rooms[indexPath.row].roomName
        cell.plantLabel.text = self.rooms[indexPath.row].plant
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.controller.currentRoom = self.rooms[indexPath.row]
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            self.managedObjectContext.deleteObject(self.rooms[indexPath.row])
            self.rooms.removeAtIndex(indexPath.row)
            do
            {
                try self.managedObjectContext.save()
            }
            catch
            {
                print("Could not delete room")
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            self.viewWillAppear(true)
        } else if editingStyle == .Insert {

        }    
    }


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


    // send message to COAP server
    func sendMessage(urlPath: String)
    {
        let message = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        
        if let stringData = urlPath.dataUsingEncoding(NSUTF8StringEncoding) {
            message.addOption(SCOption.UriPath.rawValue, data: stringData)
        }
        
        coapClient.sendCoAPMessage(message, hostName: self.host, port: UInt16(self.port)!)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addRoomSegue"
        {
            let controller = segue.destinationViewController as! AddRoomTableViewController
            controller.managedObjectContext = self.managedObjectContext
        }
        if segue.identifier == "roomDetailSegue"
        {
            let controller = segue.destinationViewController as! RoomDetailTableViewController
            controller.managedObjectContext = self.managedObjectContext
            self.controller = controller
        }
    }

    
    
}

extension RoomListTableViewController: SCClientDelegate {
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
                
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(pay, options: NSJSONReadingOptions.AllowFragments)
                    let resultJSONArray = json as! NSArray
                    for var i = 0; i < resultJSONArray.count; i++
                    {
                        let result = resultJSONArray[i] as! NSDictionary
                        let roomName = result.valueForKey("room") as! String
                        let ip = result.valueForKey("ip") as! String
                        let longtitude = result.valueForKey("longtitude") as! Double
                        let latitude = result.valueForKey("latitude") as! Double
                        
                        
                        let newRoom = Room()
                        newRoom.roomName = roomName
                        newRoom.ip = ip
                        
                        self.rooms.append(newRoom)
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
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        let errorString = "Failed with Error \(error.localizedDescription)"
        self.noRoomLabel.text = errorString
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        let errorString = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n"
        print(errorString)
    }
    
    
}

