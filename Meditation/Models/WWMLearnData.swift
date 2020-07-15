//
//  WWMLearnData.swift
//  Meditation
//
//  Created by Prema Negi on 10/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMLearnData: NSObject {
    
    var name = String()
    var intro_url = String()
    var intro_completed = Bool()
    var min_limit = String()
    var max_limit = String()
    var is_expired = false
    var step_list = [LearnStepsListData]()
    var thirty_day_list = [ThirtyDaysListData]()
    var eightWeekList = [EightWeekModel]()
    
    override init() {
    }
    
    init(json:[String:Any]) {
        name = json["name"] as? String ?? ""
        intro_url = json["intro_url"] as? String ?? ""
        intro_completed = json["intro_completed"] as? Bool ?? false
        min_limit = json["min_limit"] as? String ?? "95"
        max_limit = json["max_limit"] as? String ?? "98"
        is_expired = json["is_expired"] as? Bool ?? false
        
        //learn steps
        if let step_list = json["step_list"] as? [[String:Any]]{
            for dict in step_list {
                let stepsData = LearnStepsListData.init(json: dict)
                self.step_list.append(stepsData)
            }
        }
        
        //30 days data
        if let day_list = json["day_list"] as? [[String:Any]]{
            for dict in day_list {
                let thirtyDaysData = ThirtyDaysListData.init(json: dict)
                self.thirty_day_list.append(thirtyDaysData)
            }
        }
        
        //8 week
        if let day_list = json["daywise_list"] as? [[String:Any]]{
            for dict in day_list {
                let eightWeekData = EightWeekModel.init(json: dict)
                self.eightWeekList.append(eightWeekData)
            }
        }
    }
}

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

class ThirtyDaysListData: NSObject{
    var id: Int = 0
    var day_name: String = ""
    var auther_name: String = ""
    var Description: String = ""
    var is_milestone: Bool = false
    var min_limit = "94"
    var max_limit = "97"
    var prep_time = "60"
    var meditation_time = "1200"
    var rest_time = "120"
    var prep_min = "0"
    var prep_max = "300"
    var rest_min = "0"
    var rest_max = "600"
    var med_min = "0"
    var med_max = "2400"
    var completed: Bool = false
    var date_completed = ""
    
    override init() {
    }
    
    init(json: [String: Any]) {
        self.id = Int("\(json["id"] ?? "0")") ?? 0
        self.day_name = json["day_name"] as? String ?? ""
        self.auther_name = json["auther_name"] as? String ?? ""
        self.Description = json["description"] as? String ?? ""
        self.is_milestone = json["is_milestone"] as? Bool ?? false
        self.min_limit = json["min_limit"] as? String ?? "94"
        self.max_limit = json["max_limit"] as? String ?? "97"
        self.prep_time = json["prep_time"] as? String ?? "60"
        self.meditation_time = json["meditation_time"] as? String ?? "1200"
        self.rest_time = json["rest_time"] as? String ?? "120"
        self.prep_min = json["prep_min"] as? String ?? "0"
        self.prep_max = json["prep_max"] as? String ?? "300"
        self.rest_min = json["rest_min"] as? String ?? "0"
        self.rest_max = json["rest_max"] as? String ?? "600"
        self.med_min = json["med_min"] as? String ?? "0"
        self.med_max = json["med_max"] as? String ?? "2400"
        self.completed = json["completed"] as? Bool ?? false
        self.date_completed = json["date_completed"] as? String ?? ""
    }
}

class EightWeekModel: NSObject{
    var id: Int = 0
    var day_name: String = ""
    var auther_name: String = ""
    var Description: String = ""
    var secondDescription: String = ""
    var backImage: String = ""
    var min_limit = "94"
    var max_limit = "97"
    var completed: Bool = false
    var date_completed = ""
    var is_pre_opened: Bool = false
    var second_session_required: Bool = false
    var second_session_completed: Bool = false
    
    override init() {
    }
    
    init(json: [String: Any]) {
        self.id = Int("\(json["id"] ?? "0")") ?? 0
        self.day_name = json["day_name"] as? String ?? ""
        self.auther_name = json["auther_name"] as? String ?? ""
        self.Description = json["description"] as? String ?? ""
        self.secondDescription = json["second_description"] as? String ?? ""
        self.backImage = json["image"] as? String ?? ""
        self.min_limit = json["min_limit"] as? String ?? ""
        self.max_limit = json["max_limit"] as? String ?? ""
        self.completed = json["completed"] as? Bool ?? false
        self.date_completed = json["date_completed"] as? String ?? ""
        self.is_pre_opened = json["is_pre_opened"] as? Bool ?? false
        self.second_session_required = json["second_session_required"] as? Bool ?? false
        self.second_session_completed = json["second_session_completed"] as? Bool ?? false
    }
}
