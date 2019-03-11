//
//  WWMMeditationData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 31/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMeditationData: NSObject {

    var meditationId = Int()
    var meditationName = String()
    var isSelected = Bool()
    var levels   = [WWMLevelData]()
    var setmyown = Int()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        meditationId = json["meditation_id"] as? Int ?? -1
        setmyown = json["setmyown"] as? Int ?? 0
        meditationName = json["meditation_name"] as? String ?? ""
        isSelected = json["isSelected"] as? Bool ?? false
        if let arrLevels = json["levels"] as? [[String:Any]]{
            for dict in arrLevels {
                let levelData = WWMLevelData.init(json: dict)
                levels.append(levelData)
            }
        }
    }
    
    func getMeditationData() -> [WWMMeditationData] {
        var moodArray = [WWMMeditationData]()
        if let path = Bundle.main.url(forResource: "MeditationData", withExtension: "geojson")
        {
            do {
                let data = try Data.init(contentsOf: path )
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let result = jsonResult["result"] as? [String:Any] {
                    if let moodMeter = result["meditaionType"] as? [[String:Any]]{
                        for dict in moodMeter {
                            let data = WWMMeditationData.init(json: dict)
                            moodArray.append(data)
                        }
                    }
                    // do stuff
                }
            } catch {
                // handle error
            }
        }
        
        return moodArray
    }
    
}

class WWMLevelData: NSObject {
    
    var levelId = Int()
    var levelName = String()
    var prepTime = String()
    var meditationTime = String()
    var restTime = String()
    var minPrep = String()
    var maxPrep = String()
    var minMeditation = String()
    var maxMeditation = String()
    var minRest = String()
    var maxRest = String()
    var isSelected = Bool()
    
    init(json:[String:Any]) {
        levelId = json["level_id"] as? Int ?? -1
        levelName = json["name"] as? String ?? ""
        prepTime = json["prep_time"] as? String ?? ""
        meditationTime = json["meditation_time"] as? String ?? ""
        restTime = json["rest_time"] as? String ?? ""
        minPrep = json["prep_min"] as? String ?? ""
        maxPrep = json["prep_max"] as? String ?? ""
        minMeditation = json["med_min"] as? String ?? ""
        maxMeditation = json["med_max"] as? String ?? ""
        minRest = json["rest_min"] as? String ?? ""
        maxRest = json["rest_max"] as? String ?? ""
        isSelected = json["isSelected"] as? Bool ?? false
    
    }
    
}
