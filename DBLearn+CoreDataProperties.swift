//
//  DBLearn+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 09/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBLearn {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLearn> {
        return NSFetchRequest<DBLearn>(entityName: "DBLearn")
    }

    @NSManaged public var last_time_stamp: String?
    @NSManaged public var name: String?
    @NSManaged public var intro_url: String?
    @NSManaged public var intro_completed: Bool
    @NSManaged public var min_limit: String?
    @NSManaged public var max_limit: String?
    @NSManaged public var is_expired: Bool

}
