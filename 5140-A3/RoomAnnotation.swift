//
//  RoomAnnotation.swift
//  5140-A3
//
//  Created by 一川 黄 on 1/11/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//

import UIKit
import MapKit

class RoomAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String!
    var room: Room!
    
    init(room:Room) {
        self.room = room
        self.title = "Room \(room.roomName)"
        self.coordinate = CLLocationCoordinate2D(latitude: Double(room.latitude!), longitude: Double(room.longitude!))
    }
}
