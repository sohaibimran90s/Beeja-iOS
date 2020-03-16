//
//  WWMSatsProgressData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSatsProgressData: NSObject {
    var hours_of_meditate:Int?
    var avg_min_daily:Any?
    var avg_session:Int?
    var cons_days:Int?
    var total_Session :Int?
    var weekly_session:Int?
    var longest_session :Int?
    var consecutive_days = [WWMConsecutiveDaysData]()
    var days_21_Challenge = [WWMSatsProgress21DaysChallengeData]()
    
    override init() {
        cons_days = 0
        total_Session = 0
        weekly_session = 0
        hours_of_meditate = 0
        avg_min_daily = 0
        avg_session = 0
        longest_session = 0
    }
    init(json:[String:Any], dayAdded:Int) {
        
        
        cons_days = json["cons_days"] as? Int ?? 0
        total_Session = json["total_Session"] as? Int ?? 0
        weekly_session = json["weekly_session"] as? Int ?? 0
        hours_of_meditate = json["hours_of_meditate"] as? Int ?? 0
        avg_min_daily = json["avg_min_daily"]
        //avg_session = json["avg_session"] as? Double ?? 0
        avg_session = json["avg_session"] as? Int ?? 0
        longest_session = json["longest_session"] as? Int ?? 0
        for index in 0..<dayAdded {
            print(index)
            let levelData = WWMConsecutiveDaysData.init()
            consecutive_days.append(levelData)
        }
        if let arrLevels = json["consecutive_days"] as? [[String:Any]]{
            for dict in arrLevels {
                let levelData = WWMConsecutiveDaysData.init(json: dict)
                consecutive_days.append(levelData)
            }
        }
        
        if let days_21 = json["21days_challenge"] as? [[String:Any]]{
            for dict in days_21 {
                let days21Data = WWMSatsProgress21DaysChallengeData.init(json: dict)
                days_21_Challenge.append(days21Data)
            }
        }
    }
    
//    func getStatsProgressData() -> WWMSatsProgressData {
//        let statsData = WWMSatsProgressData()
//        if let path = Bundle.main.url(forResource: "CalendarData", withExtension: "geojson")
//        {
//            do {
//                let data = try Data.init(contentsOf: path )
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//                print(jsonResult)
//                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let result = jsonResult["Result"] as? [String:Any] {
//
//
//                             //statsData = WWMSatsProgressData.init(json: result)
//
//
//                    }
//
//
//            } catch {
//                // handle error
//            }
//        }
//
//        return statsData
//    }
}

class WWMConsecutiveDaysData: NSObject {
    
    
    var date = String()
    var meditation_status = Int()
    var meditation_status2 = Int()
    var meditation_id = Int()
    
    override init() {
        date = ""
        meditation_status = -2
        meditation_id = -2
        meditation_status2 =  -2
    }
    
    init(json:[String:Any]) {
        date = json["date"] as? String ?? ""
        meditation_status = json["meditation_status"] as? Int ?? -2
        meditation_id = json["meditation_id"] as? Int ?? -2
        meditation_status2 = json["meditation_status2"] as? Int ?? -2
        
    }
    
}

class WWMSatsProgress21DaysChallengeData: NSObject {
    
    var completed_date = ""
    var day_id = 1
    var emotion_id = ""
    var status = false
    
    override init() {
    }
    
    init(json:[String:Any]) {
        completed_date = json["completed_date"] as? String ?? ""
        day_id = json["day_id"] as? Int ?? 1
        emotion_id = json["emotion_id"] as? String ?? ""
        status = json["status"] as? Bool ?? false
    }
}




