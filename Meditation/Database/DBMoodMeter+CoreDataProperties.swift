//
//  DBMoodMeter+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 29/01/19.
//
//

import Foundation
import CoreData


extension DBMoodMeter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMoodMeter> {
        return NSFetchRequest<DBMoodMeter>(entityName: "DBMoodMeter")
    }

    @NSManaged public var data: String?

}
