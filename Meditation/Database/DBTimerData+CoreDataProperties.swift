//
//  DBTimerData+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 29/01/19.
//
//

import Foundation
import CoreData


extension DBTimerData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTimerData> {
        return NSFetchRequest<DBTimerData>(entityName: "DBTimerData")
    }

    @NSManaged public var levelId: String?
    @NSManaged public var levelName: String?
    @NSManaged public var meditationTime: String?
    @NSManaged public var prepTime: String?
    @NSManaged public var restTime: String?

}
