//
//  DBWisdomData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 09/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBWisdomData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBWisdomData> {
        return NSFetchRequest<DBWisdomData>(entityName: "DBWisdomData")
    }

    @NSManaged public var id: String?
    @NSManaged public var last_time_stamp: String?
    @NSManaged public var name: String?

}
