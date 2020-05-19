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

    @NSManaged public var name: String?
    @NSManaged public var guided_id: String?
    @NSManaged public var guided_name: String?
    @NSManaged public var last_time_stamp: String?
    @NSManaged public var meditation_type: String?
    @NSManaged public var guided_mode: String?
    @NSManaged public var min_limit: String?
    @NSManaged public var max_limit: String?
    @NSManaged public var meditation_key: String?
    @NSManaged public var cat_name: String?
    @NSManaged public var complete_count: String?
    @NSManaged public var intro_url: String?
}
