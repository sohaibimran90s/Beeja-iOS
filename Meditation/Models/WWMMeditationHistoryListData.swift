//
//  WWMMeditationHistoryListData.swift
//  Meditation
//
//  Created by Prema Negi on 18/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMMeditationHistoryListData: NSObject{
    
    var duration: Int = 0
    var id: Int = 0
    var image: String = ""
    var like: Int = 0
    var date: String = ""
    var timezone: String = ""
    var timezone_type: Int = 0
    var title: String = ""
    var type: String = ""
    
    override init() {
    }
    
    init(json: [String: Any]) {
        self.duration = json["duration"] as? Int ?? 0
        self.id = json["id"] as? Int ?? 0
        self.image = json["image"] as? String ?? ""
        self.like = json["like"] as? Int ?? 0
        self.title = json["title"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        
        if let time = json["time"] as? [String: Any]{
            self.date = time["date"] as? String ?? ""
            if let timezone = time["timezone"] as? [String: Any]{
                self.timezone = timezone["timezone"] as? String ?? ""
                self.timezone_type = timezone["timezone_type"] as? Int ?? 0
            }
        }
    }
}
