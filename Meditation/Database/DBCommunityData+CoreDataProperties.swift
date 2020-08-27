//
//  DBCommunityData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 07/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBCommunityData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCommunityData> {
        return NSFetchRequest<DBCommunityData>(entityName: "DBCommunityData")
    }

    @NSManaged public var data: String?
    @NSManaged public var last_time_stamp: String?

}
