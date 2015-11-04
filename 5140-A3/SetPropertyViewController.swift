//
//  SetPropertyViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 26/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit

class SetPropertyViewController: UIViewController {
    
    var roomProperties:NSMutableDictionary!
    var propertyKey:String!
    
    @IBOutlet var propertValueInput: UITextField!
    
    @IBAction func saveProperty(sender: AnyObject) {
        let value = self.propertValueInput.text! as String
        self.roomProperties.setValue(value, forKey: propertyKey)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true
        
        propertValueInput.layer.borderColor = UIColor(colorLiteralRed: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1).CGColor
        propertValueInput.layer.borderWidth = 0.6
        
        var title = ""
        if propertyKey == "roomName"
        {
            title = "Room Name"
        }
        if propertyKey == "ip"
        {
            title = "Server IP"
        }
        if propertyKey == "plant"
        {
            title = "Plant"
        }
        self.navigationItem.title = title
        self.propertValueInput.text = self.roomProperties.valueForKey(self.propertyKey) as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
