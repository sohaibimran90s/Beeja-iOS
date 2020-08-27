//
//  DBGetVibesImages+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 11/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBGetVibesImages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGetVibesImages> {
        return NSFetchRequest<DBGetVibesImages>(entityName: "DBGetVibesImages")
    }

    @NSManaged public var images: String?
    @NSManaged public var last_time_stamp: String?
    @NSManaged public var mood_id: String?

}
