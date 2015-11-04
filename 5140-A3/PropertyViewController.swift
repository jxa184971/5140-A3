//
//  PropertyViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 3/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class PropertyViewController: UIViewController {

    var server:CentralServer!
    var managedObjectContext:NSManagedObjectContext!
    @IBOutlet var inputText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputText.text = self.server.ip!
        self.navigationItem.title = "Central Server IP"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveProperty(sender: AnyObject) {
        self.server.ip = self.inputText.text
        do {
            try self.managedObjectContext.save()
        }
        catch _
        {
            print("Can't save central server IP")
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
