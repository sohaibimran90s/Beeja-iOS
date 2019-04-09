//
//  DBAddSession+CoreDataProperties.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBAddSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBAddSession> {
        return NSFetchRequest<DBAddSession>(entityName: "DBAddSession")
    }

    @NSManaged public var addSession: String?

}
