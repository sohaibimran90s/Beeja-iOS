//
//  WWMCommunityData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 16/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMCommunityData: NSObject {

    var events = [WWMCommunityEventsData]()
    var hashtags   = [WWMCommunityHashtagsData]()
    var titleAnyWhere: String = ""
    
    override init() {
        
    }
    
    init(json:[String:Any]) {
        
        if let title = json["title"] as? String{
            self.titleAnyWhere = title
        }
        if let arrLevels = json["hashtags"] as? [[String:Any]]{
            for dict in arrLevels {
                let hashtagData = WWMCommunityHashtagsData.init(json: dict)
                hashtags.append(hashtagData)
            }
        }
        if let arrLevels = json["events"] as? [[String:Any]]{
            for dict in arrLevels {
                let eventData = WWMCommunityEventsData.init(json: dict)
                events.append(eventData)
            }
        }
    }

}

class WWMCommunityEventsData: NSObject {
    
    var eventTitle = String()
    var url = String()
    var imageUrl = String()
    
    
    init(json:[String:Any]) {
        eventTitle = json["event_title"] as? String ?? ""
        url = json["url"] as? String ?? ""
        imageUrl = json["image_url"] as? String ?? ""
    }
    
}

class WWMCommunityHashtagsData: NSObject {
    
    var type = String()
    var url = String()
    var thumbnail = String()
    
    init(json:[String:Any]) {
        type = json["type"] as? String ?? ""
        url = json["url"] as? String ?? ""
        thumbnail = json["thumbnail"] as? String ?? ""
    }
}
