//
//  SettingTableViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 3/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class SettingTableViewController: UITableViewController {

    var managedObjectContext:NSManagedObjectContext!
    var server:CentralServer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest = NSFetchRequest(entityName: "CentralServer")
        do
        {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if results.count == 0
            {
                let server = NSEntityDescription.insertNewObjectForEntityForName("CentralServer", inManagedObjectContext: self.managedObjectContext) as! CentralServer
                server.ip = "Not Setting Yet"
                
                do {
                    try self.managedObjectContext.save()
                }
                catch _
                {
                    print("Could not save new central server")
                }
            }
            else
            {
                self.server = results.first as! CentralServer
            }
        }
        catch _
        {
            print("Could not fetch data of entity room")
        }
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
        return 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if self.server == nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("serverCell", forIndexPath: indexPath) as! PropertyCell
            cell.nameLabel.text = "Central Server IP"
            cell.valueLabel.text = "Not Setting Yet"
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("serverCell", forIndexPath: indexPath) as! PropertyCell
            cell.nameLabel.text = "Central Server IP"
            cell.valueLabel.text = self.server.ip!
            return cell
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

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingSegue"
        {
            let controller = segue.destinationViewController as! PropertyViewController
            controller.server = self.server
            controller.managedObjectContext = self.managedObjectContext
        }
    }


}
