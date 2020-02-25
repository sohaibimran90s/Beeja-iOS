//
//  DBGuidedData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 13/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBGuidedData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGuidedData> {
        return NSFetchRequest<DBGuidedData>(entityName: "DBGuidedData")
    }

    @NSManaged public var guided_id: String?
    @NSManaged public var guided_name: String?
    @NSManaged public var last_time_stamp: String?
    @NSManaged public var meditation_type: String?
    @NSManaged public var guided_mode: String?
}
