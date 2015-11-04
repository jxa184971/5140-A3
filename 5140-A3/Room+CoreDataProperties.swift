//
//  Room+CoreDataProperties.swift
//  5140-A3
//
//  Created by 一川 黄 on 26/10/2015.
//  Copyright © 2015 Yichuan Huang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Room {

    @NSManaged var roomName: String?
    @NSManaged var ip: String?
    @NSManaged var plant: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

}
