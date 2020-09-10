//
//  DBNinetyFivePercent+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 27/03/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBNinetyFivePercent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNinetyFivePercent> {
        return NSFetchRequest<DBNinetyFivePercent>(entityName: "DBNinetyFivePercent")
    }

    @NSManaged public var meditation_name: String?
    @NSManaged public var meditation_value: String?

}
