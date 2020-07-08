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
    @NSManaged public var id: String?
    @NSManaged public var is_milestone: Bool
    @NSManaged public var max_limit: String?
    @NSManaged public var med_max: String?
    @NSManaged public var med_min: String?
    @NSManaged public var meditation_time: String?
    @NSManaged public var min_limit: String?
    @NSManaged public var prep_max: String?
    @NSManaged public var prep_min: String?
    @NSManaged public var prep_time: String?
    @NSManaged public var rest_max: String?
    @NSManaged public var rest_min: String?
    @NSManaged public var rest_time: String?
    @NSManaged public var two_step_complete: Bool

}
