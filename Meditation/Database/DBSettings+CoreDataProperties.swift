//
//  DBSettings+CoreDataProperties.swift
//  Meditation
//
//  Created by Roshan Kumawat on 28/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
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
    @NSManaged public var isMilestoneAndRewards: Bool
    @NSManaged public var isMorningReminder: Bool
    @NSManaged public var meditationTime: String?
    @NSManaged public var moodMeterEnable: Bool
    @NSManaged public var morningReminderTime: String?
    @NSManaged public var prepTime: String?
    @NSManaged public var restTime: String?
    @NSManaged public var startChime: String?
    @NSManaged public var meditationData: NSOrderedSet?

}

// MARK: Generated accessors for meditationData
extension DBSettings {

    @objc(insertObject:inMeditationDataAtIndex:)
    @NSManaged public func insertIntoMeditationData(_ value: DBMeditationData, at idx: Int)

    @objc(removeObjectFromMeditationDataAtIndex:)
    @NSManaged public func removeFromMeditationData(at idx: Int)

    @objc(insertMeditationData:atIndexes:)
    @NSManaged public func insertIntoMeditationData(_ values: [DBMeditationData], at indexes: NSIndexSet)

    @objc(removeMeditationDataAtIndexes:)
    @NSManaged public func removeFromMeditationData(at indexes: NSIndexSet)

    @objc(replaceObjectInMeditationDataAtIndex:withObject:)
    @NSManaged public func replaceMeditationData(at idx: Int, with value: DBMeditationData)

    @objc(replaceMeditationDataAtIndexes:withMeditationData:)
    @NSManaged public func replaceMeditationData(at indexes: NSIndexSet, with values: [DBMeditationData])

    @objc(addMeditationDataObject:)
    @NSManaged public func addToMeditationData(_ value: DBMeditationData)

    @objc(removeMeditationDataObject:)
    @NSManaged public func removeFromMeditationData(_ value: DBMeditationData)

    @objc(addMeditationData:)
    @NSManaged public func addToMeditationData(_ values: NSOrderedSet)

    @objc(removeMeditationData:)
    @NSManaged public func removeFromMeditationData(_ values: NSOrderedSet)

}
