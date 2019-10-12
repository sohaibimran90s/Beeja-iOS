//
//  DBGuidedAudioData+CoreDataProperties.swift
//  Meditation
//
//  Created by Prema Negi on 13/10/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//
//

import Foundation
import CoreData


extension DBGuidedAudioData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGuidedAudioData> {
        return NSFetchRequest<DBGuidedAudioData>(entityName: "DBGuidedAudioData")
    }

    @NSManaged public var emotion_id: String?
    @NSManaged public var audio_id: String?
    @NSManaged public var audio_image: String?
    @NSManaged public var audio_name: String?
    @NSManaged public var audio_url: String?
    @NSManaged public var author_name: String?
    @NSManaged public var duration: String?
    @NSManaged public var paid: Bool
    @NSManaged public var vote: Bool

}
