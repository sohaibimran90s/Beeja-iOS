//
//  DBNintyFiveCompletionData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 06/12/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBNintyFiveCompletionData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNintyFiveCompletionData> {
        return NSFetchRequest<DBNintyFiveCompletionData>(entityName: "DBNintyFiveCompletionData")
    }

    @NSManaged public var data: String?
    @NSManaged public var id: String?

}
