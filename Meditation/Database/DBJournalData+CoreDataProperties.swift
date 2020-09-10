//
//  DBJournalData+CoreDataProperties.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBJournalData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBJournalData> {
        return NSFetchRequest<DBJournalData>(entityName: "DBJournalData")
    }

    @NSManaged public var journalData: String?

}
