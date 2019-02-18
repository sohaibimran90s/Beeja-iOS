//
//  DBJournalList+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 29/01/19.
//
//

import Foundation
import CoreData


extension DBJournalList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBJournalList> {
        return NSFetchRequest<DBJournalList>(entityName: "DBJournalList")
    }

    @NSManaged public var data: String?

}
