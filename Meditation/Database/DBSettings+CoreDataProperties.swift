//
//  DBSettings+CoreDataProperties.swift
//  
//
//  Created by Roshan Kumawat on 29/01/19.
//
//

import Foundation
import CoreData


extension DBSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBSettings> {
        return NSFetchRequest<DBSettings>(entityName: "DBSettings")
    }

    @NSManaged public var afterNoonReminderTime: String?
    @NSManaged public var ambientChime: String?
    @NSManaged public var endChime: String?
    @NSManaged public var finishChime: String?
    @NSManaged public var intervalChime: String?
    @NSManaged public var isAfterNoonReminder: Bool
    @NSManaged public var isMorningReminder: Bool
    @NSManaged public var moodMeterEnable: Bool
    @NSManaged public var morningReminderTime: String?
    @NSManaged public var startChime: String?
    @NSManaged public var prepTime: String?
    @NSManaged public var meditationTime: String?
    @NSManaged public var restTime: String?

}
