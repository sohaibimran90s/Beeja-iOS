//
//  DBGuidedEmotionsData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 13/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBGuidedEmotionsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGuidedEmotionsData> {
        return NSFetchRequest<DBGuidedEmotionsData>(entityName: "DBGuidedEmotionsData")
    }

    @NSManaged public var emotion_id: String?
    @NSManaged public var emotion_image: String?
    @NSManaged public var emotion_name: String?
    @NSManaged public var guided_id: String?
    @NSManaged public var tile_type: String?
    @NSManaged public var author_name: String?
    @NSManaged public var emotion_key: String?
    @NSManaged public var emotion_body: String?
    @NSManaged public var intro_completed: Bool
}
