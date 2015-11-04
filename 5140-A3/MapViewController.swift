//
//  MapViewController.swift
//  5140-A3
//
//  Created by 一川 黄 on 1/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var locationManager: CLLocationManager!
    var rooms: Array<Room>!
    var managedObjectContext:NSManagedObjectContext!
    var currentRoom: Room!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var roomNameLabel: UILabel!
    @IBOutlet var plantLabel: UILabel!
    @IBOutlet var detailButton: UIButton!
    
    var coapClient: SCClient!
    let separatorLine = "\n-----------------\n"
    let port = "5683"
    var host = "127.0.0.1"
    var server: CentralServer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.errorLabel.text = ""
        self.roomNameLabel.text = ""
        self.plantLabel.text = ""
        self.detailButton.hidden = true
        self.locationManager = CLLocationManager()   //initialise the location manager
        
        // set up CL location manager
        if !CLLocationManager.locationServicesEnabled()
        {
            self.errorLabel.text = "The location service is not open. Please go to the setting to open it!"
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined
        {
            self.locationManager.requestWhenInUseAuthorization()
            self.errorLabel.text = "Reload map to start using location services"
        }
        else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            self.locationManager.delegate=self;
            self.locationManager.desiredAccuracy = 1
            self.locationManager.distanceFilter = 10
            
            self.locationManager.startUpdatingLocation()
        }
        
        // set up map view
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        self.mapView.mapType = MKMapType.Standard
        
        self.rooms = Array<Room>()
        
        // set up coap client
        coapClient = SCClient(delegate: self)
        coapClient.sendToken = true
        coapClient.autoBlock1SZX = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.errorLabel.text = ""
        self.tabBarController?.tabBar.hidden = false
        
        /*
        // fetch Room
        let fetchRequest = NSFetchRequest(entityName: "Room")
        do
        {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if results.count == 0
            {
                print("There is no room stored in the database")
                self.rooms = Array<Room>()
            }
            else
            {
                self.rooms = results as! Array<Room>
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
                print("No Server Result")
            }
            else
            {
                self.server = results.first as! CentralServer
                if self.server.ip == "Not Setting Yet"
                {
                    print("Not Setting Central Server Yet. Go to Setting View to setup first")
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
            print("Could not fetch data of entity CentralServer")
        }
        
        self.sendMessage("device")
        
        // add annotation
        self.addAnnotation()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print("User location updated")
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake((userLocation.location?.coordinate)!, span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let roomAnnotation = view.annotation as! RoomAnnotation
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(roomAnnotation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
        self.currentRoom = roomAnnotation.room
        let roomName = roomAnnotation.room.roomName!
        let plant = roomAnnotation.room.plant!
        self.roomNameLabel.text = "Room Name: \(roomName)"
        self.plantLabel.text = "Plant: \(plant)"
        self.detailButton.hidden = false
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.plantLabel.text = ""
        self.roomNameLabel.text = ""
        self.detailButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotation()
    {
        for room in self.rooms
        {
            let annotation = RoomAnnotation(room: room)
            self.mapView.addAnnotation(annotation)
        }
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "roomDetailSegue"
        {
            let controller = segue.destinationViewController as! RoomDetailTableViewController
            controller.currentRoom = self.currentRoom
        }
    }


}


extension MapViewController: SCClientDelegate {
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay, encoding:NSUTF8StringEncoding) {
                payloadstring = String(string)
                var newRoomArray = Array<Room>()
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(pay, options: NSJSONReadingOptions.AllowFragments)
                    let resultJSONArray = json as! NSArray
                    for var i = 0; i < resultJSONArray.count; i++
                    {
                        let result = resultJSONArray[i] as! NSDictionary
                        let roomId = result.valueForKey("room") as! NSNumber
                        let roomName = String(roomId)
                        let ip = result.valueForKey("ip") as! String
                        let longitude = result.valueForKey("longtitude") as! Double
                        let latitude = result.valueForKey("latitude") as! Double
                        let plant = result.valueForKey("plant") as! String
                        
                        let newRoom = Room()
                        newRoom.roomName = roomName
                        newRoom.ip = ip
                        newRoom.latitude = latitude
                        newRoom.longitude = longitude
                        newRoom.plant = plant
                        
                        newRoomArray.append(newRoom)
                    }
                    print(newRoomArray.count)
                    self.rooms = newRoomArray
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
        
        self.addAnnotation()
    }
    
    func swiftCoapClient(client: SCClient, didFailWithError error: NSError) {
        print("Failed with Error \(error.localizedDescription)")
    }
    
    func swiftCoapClient(client: SCClient, didSendMessage message: SCMessage, number: Int) {
        let errorString = "Message sent (\(number)) with type: \(message.type.shortString()) with id: \(message.messageId)\n"
        print(errorString)
    }
    
    
}


