//
//  DBSteps+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 11/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBSteps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBSteps> {
        return NSFetchRequest<DBSteps>(entityName: "DBSteps")
    }

    @NSManaged public var date_completed: String?
    @NSManaged public var description1: String?
    @NSManaged public var id: String?
    @NSManaged public var outro_audio: String?
    @NSManaged public var step_audio: String?
    @NSManaged public var step_name: String?
    @NSManaged public var timer_audio: String?
    @NSManaged public var title: String?
    @NSManaged public var completed: Bool
    @NSManaged public var min_limit: String?
    @NSManaged public var max_limit: String?
}
