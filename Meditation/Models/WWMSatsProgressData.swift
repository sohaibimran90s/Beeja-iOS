//
//  WWMSatsProgressData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSatsProgressData: NSObject {
    var dailyFreq = Int()
    var hoursOfMeditate = String()
    var avgMintDaily = String()
    var avgSession = String()
    var longestSession   = String()
    var consecutiveDays = [WWMConsecutiveDaysData]()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        dailyFreq = json["dailyFreq"] as? Int ?? -1
        hoursOfMeditate = json["hoursOfMeditate"] as? String ?? ""
        avgMintDaily = json["avgMintDaily"] as? String ?? ""
        avgSession = json["avgSession"] as? String ?? ""
        longestSession = json["longestSession"] as? String ?? ""
        if let arrLevels = json["consecutiveDays"] as? [[String:Any]]{
            for dict in arrLevels {
                let levelData = WWMConsecutiveDaysData.init(json: dict)
                consecutiveDays.append(levelData)
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
                    
                        
                             statsData = WWMSatsProgressData.init(json: result)
                            
                        
                    }
                
                
            } catch {
                // handle error
            }
        }
        
        return statsData
    }
}

class WWMConsecutiveDaysData: NSObject {
    
    
    var date = Int()
    var meditationStatus = Int()
    
    init(json:[String:Any]) {
        date = json["date"] as? Int ?? -1
        meditationStatus = json["meditationStatus"] as? Int ?? -1
        
    }
    
}
