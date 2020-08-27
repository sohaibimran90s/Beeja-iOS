//
//  DBMantras+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 09/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBMantras {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMantras> {
        return NSFetchRequest<DBMantras>(entityName: "DBMantras")
    }

    @NSManaged public var data: String?
    @NSManaged public var last_time_stamp: String?

}
