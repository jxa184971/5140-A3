//
//  AddRoomTableViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 25/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class AddRoomTableViewController: UITableViewController {

    var managedObjectContext:NSManagedObjectContext!
    var roomProperties: NSMutableDictionary!
    var controller: SetPropertyViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomProperties = ["roomName":"Unknown", "ip":"127.0.0.1", "plant":"Unknown"]
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
            return 3
        }
        if section == 1
        {
            return 2
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            if (indexPath.row == 0)
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! AddRoomTableViewCell
                cell.propertyName.text = "Room Name"
                cell.propertyValue.text = self.roomProperties.valueForKey("roomName") as? String
                return cell
            }
            if (indexPath.row == 1)
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! AddRoomTableViewCell
                cell.propertyName.text = "Server IP"
                cell.propertyValue.text = self.roomProperties.valueForKey("ip") as? String
                return cell
            }
            if (indexPath.row == 2)
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! AddRoomTableViewCell
                cell.propertyName.text = "Plant"
                cell.propertyValue.text = self.roomProperties.valueForKey("plant") as? String
                return cell
            }
        }
        if indexPath.section == 1
        {
            if indexPath.row == 0
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! ButtonTableViewCell
                cell.buttonLabel.text = "Submit"
                return cell
            }
            if indexPath.row == 1
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("buttonCell", forIndexPath: indexPath) as! ButtonTableViewCell
                cell.buttonLabel.text = "Cancel"
                return cell
            }
           
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1
        {
            if indexPath.row == 0 //submit
            {
                let newRoom = NSEntityDescription.insertNewObjectForEntityForName("Room", inManagedObjectContext: self.managedObjectContext) as! Room
                newRoom.roomName = self.roomProperties.valueForKey("roomName") as? String
                newRoom.ip = self.roomProperties.valueForKey("ip") as? String
                newRoom.plant = self.roomProperties.valueForKey("plant") as? String
                newRoom.latitude = -37.876348
                newRoom.longitude = 145.044406
                do
                {
                    try self.managedObjectContext.save()
                }
                catch
                {
                    print("Could not save Room entity into database")
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
            if indexPath.row == 1 //cancel
            {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        if indexPath.section == 0
        {
            if indexPath.row == 0
            {
                self.controller.propertyKey = "roomName"
            }
            if indexPath.row == 1
            {
                self.controller.propertyKey = "ip"
            }
            if indexPath.row == 2
            {
                self.controller.propertyKey = "plant"
            }
        }
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



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setPropertySegue"
        {
            let controller = segue.destinationViewController as! SetPropertyViewController
            self.controller = controller
            controller.roomProperties = self.roomProperties
        }
    }
}
