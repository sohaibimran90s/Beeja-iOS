//
//  DBContactUs+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 29/01/19.
//
//

import Foundation
import CoreData


extension DBContactUs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBContactUs> {
        return NSFetchRequest<DBContactUs>(entityName: "DBContactUs")
    }

    @NSManaged public var data: String?

}
