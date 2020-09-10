//
//  DBEightWeek+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 07/07/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBEightWeek {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBEightWeek> {
        return NSFetchRequest<DBEightWeek>(entityName: "DBEightWeek")
    }

    @NSManaged public var auther_name: String?
    @NSManaged public var completed: Bool
    @NSManaged public var date_completed: String?
    @NSManaged public var day_name: String?
    @NSManaged public var description1: String?
    @NSManaged public var secondDescription: String?
    @NSManaged public var id: String?
    @NSManaged public var max_limit: String?
    @NSManaged public var min_limit: String?
    @NSManaged public var image: String?
    @NSManaged public var is_pre_opened: Bool
    @NSManaged public var second_session_required: Bool
    @NSManaged public var second_session_completed: Bool
}
