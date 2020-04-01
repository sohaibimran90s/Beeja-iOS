//
//  WWMLearnStepsListData.swift
//  Meditation
//
//  Created by Prema Negi on 20/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class LearnStepsListData: NSObject{
    var step_name: String = ""
    var id: Int = 0
    var date_completed: String = ""
    var title: String = ""
    var timer_audio: String = ""
    var outro_audio: String = ""
    var Description: String = ""
    var step_audio: String = ""
    var completed: Bool = false
    var min_limit = "94"
    var max_limit = "97"
    
    override init() {
    }
    
    init(json: [String: Any]) {
        self.step_name = json["step_name"] as? String ?? ""
        self.id = Int("\(json["id"] ?? "0")") ?? 0
        self.date_completed = json["date_completed"] as? String ?? ""
        self.title = json["title"] as? String ?? ""
        self.timer_audio = json["timer_audio"] as? String ?? ""
        self.Description = json["description"] as? String ?? ""
        self.step_audio = json["step_audio"] as? String ?? ""
        self.outro_audio = json["outro_audio"] as? String ?? ""
        self.completed = json["completed"] as? Bool ?? false
        self.min_limit = json["min_limit"] as? String ?? "94"
        self.max_limit = json["max_limit"] as? String ?? "97"
    }
}
