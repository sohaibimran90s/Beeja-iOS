//
//  DBMeditationData+CoreDataProperties.swift
//  Meditation
//
//  Created by Roshan Kumawat on 31/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBMeditationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMeditationData> {
        return NSFetchRequest<DBMeditationData>(entityName: "DBMeditationData")
    }

    @NSManaged public var meditationName: String?
    @NSManaged public var meditationId: String?
    @NSManaged public var isMeditationSelected: Bool
    @NSManaged public var levels: NSOrderedSet?

}

// MARK: Generated accessors for levels
extension DBMeditationData {

    @objc(insertObject:inLevelsAtIndex:)
    @NSManaged public func insertIntoLevels(_ value: DBLevelData, at idx: Int)

    @objc(removeObjectFromLevelsAtIndex:)
    @NSManaged public func removeFromLevels(at idx: Int)

    @objc(insertLevels:atIndexes:)
    @NSManaged public func insertIntoLevels(_ values: [DBLevelData], at indexes: NSIndexSet)

    @objc(removeLevelsAtIndexes:)
    @NSManaged public func removeFromLevels(at indexes: NSIndexSet)

    @objc(replaceObjectInLevelsAtIndex:withObject:)
    @NSManaged public func replaceLevels(at idx: Int, with value: DBLevelData)

    @objc(replaceLevelsAtIndexes:withLevels:)
    @NSManaged public func replaceLevels(at indexes: NSIndexSet, with values: [DBLevelData])

    @objc(addLevelsObject:)
    @NSManaged public func addToLevels(_ value: DBLevelData)

    @objc(removeLevelsObject:)
    @NSManaged public func removeFromLevels(_ value: DBLevelData)

    @objc(addLevels:)
    @NSManaged public func addToLevels(_ values: NSOrderedSet)

    @objc(removeLevels:)
    @NSManaged public func removeFromLevels(_ values: NSOrderedSet)

}
