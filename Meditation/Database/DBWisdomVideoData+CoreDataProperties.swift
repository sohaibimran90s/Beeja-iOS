//
//  DBWisdomVideoData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 09/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBWisdomVideoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBWisdomVideoData> {
        return NSFetchRequest<DBWisdomVideoData>(entityName: "DBWisdomVideoData")
    }

    @NSManaged public var video_duration: String?
    @NSManaged public var video_id: String?
    @NSManaged public var video_img: String?
    @NSManaged public var video_name: String?
    @NSManaged public var video_url: String?
    @NSManaged public var wisdom_id: String?
    @NSManaged public var video_vote: Bool
    @NSManaged public var is_intro: String?
}
