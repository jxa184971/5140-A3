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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.errorLabel.text = ""
        self.tabBarController?.tabBar.hidden = false
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
    
    
        
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "roomDetailSegue"
        {
            let controller = segue.destinationViewController as! RoomDetailTableViewController
            controller.currentRoom = self.currentRoom
        }
    }


}
