//
//  DBLevelData+CoreDataProperties.swift
//  Meditation
//
//  Created by Roshan Kumawat on 31/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBLevelData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLevelData> {
        return NSFetchRequest<DBLevelData>(entityName: "DBLevelData")
    }

    @NSManaged public var levelName: String?
    @NSManaged public var levelId: Int32
    @NSManaged public var prepTime: Int32
    @NSManaged public var meditationTime: Int32
    @NSManaged public var restTime: Int32
    @NSManaged public var minPrep: Int32
    @NSManaged public var maxPrep: Int32
    @NSManaged public var minMeditation: Int32
    @NSManaged public var maxMeditation: Int32
    @NSManaged public var minRest: Int32
    @NSManaged public var maxRest: Int32
    @NSManaged public var isLevelSelected: Bool

}
