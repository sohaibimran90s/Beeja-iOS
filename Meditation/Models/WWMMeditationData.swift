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
    var levels   = [WWMLevelData]()
    
    
    override init() {
        
    }
    init(json:[String:Any]) {
        meditationId = json["meditationId"] as? Int ?? -1
        meditationName = json["meditationName"] as? String ?? ""
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
    var prepTime = Int()
    var meditationTime = Int()
    var restTime = Int()
    var minPrep = Int()
    var maxPrep = Int()
    var minMeditation = Int()
    var maxMeditation = Int()
    var minRest = Int()
    var maxRest = Int()
    
    init(json:[String:Any]) {
        levelId = json["levelId"] as? Int ?? -1
        levelName = json["levelName"] as? String ?? ""
        prepTime = json["prepTime"] as? Int ?? -1
        meditationTime = json["meditationTime"] as? Int ?? -1
        restTime = json["restTime"] as? Int ?? -1
        minPrep = json["minPrep"] as? Int ?? -1
        maxPrep = json["maxPrep"] as? Int ?? -1
        minMeditation = json["minMeditation"] as? Int ?? -1
        maxMeditation = json["maxMeditation"] as? Int ?? -1
        minRest = json["minRest"] as? Int ?? -1
        maxRest = json["maxRest"] as? Int ?? -1
    
    }
    
}
