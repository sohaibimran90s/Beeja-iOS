//
//  DBMeditationComplete+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 28/01/19.
//
//

import Foundation
import CoreData


extension DBMeditationComplete {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMeditationComplete> {
        return NSFetchRequest<DBMeditationComplete>(entityName: "DBMeditationComplete")
    }

    @NSManaged public var meditationData: String?

}
