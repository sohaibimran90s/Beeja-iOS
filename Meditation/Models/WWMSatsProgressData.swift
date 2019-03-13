//
//  WWMSatsProgressData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSatsProgressData: NSObject {
    var hours_of_meditate:Any?
    var avg_min_daily:Any?
    var avg_session:Any?
    var cons_days:Any?
    var total_Session :Any?
    var weekly_session:Any?
    var longest_session :Any?
    var consecutive_days = [WWMConsecutiveDaysData]()
    
    override init() {
        
    }
    init(json:[String:Any], dayAdded:Int) {
        
        
        cons_days = json["cons_days"]
        total_Session = json["total_Session"]
        weekly_session = json["weekly_session"]
        hours_of_meditate = json["hours_of_meditate"]
        avg_min_daily = json["avg_min_daily"]
        //avg_session = json["avg_session"] as? Double ?? 0
        avg_session = json["avg_session"]
        longest_session = json["longest_session"]
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
    }
    
    func getStatsProgressData() -> WWMSatsProgressData {
        var statsData = WWMSatsProgressData()
        if let path = Bundle.main.url(forResource: "CalendarData", withExtension: "geojson")
        {
            do {
                let data = try Data.init(contentsOf: path )
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print(jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let result = jsonResult["Result"] as? [String:Any] {
                    
                        
                             //statsData = WWMSatsProgressData.init(json: result)
                            
                        
                    }
                
                
            } catch {
                // handle error
            }
        }
        
        return statsData
    }
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





