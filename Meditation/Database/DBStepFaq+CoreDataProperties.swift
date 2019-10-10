//
//  DBStepFaq+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 10/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBStepFaq {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBStepFaq> {
        return NSFetchRequest<DBStepFaq>(entityName: "DBStepFaq")
    }

    @NSManaged public var answers: String?
    @NSManaged public var last_time_stamp: String?
    @NSManaged public var question: String?
    @NSManaged public var step_id: String?

}
