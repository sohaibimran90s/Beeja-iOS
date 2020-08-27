//
//  DBMeditationHistory+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 05/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBMeditationHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMeditationHistory> {
        return NSFetchRequest<DBMeditationHistory>(entityName: "DBMeditationHistory")
    }

    @NSManaged public var data: String?

}
