//
//  WWMMoodMeterData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodMeterData: NSObject {

    var color = String()
    var mood = String()
    var show_burn = Bool()
    
    override init() {
        color = ""
        mood = ""
        show_burn = false
    }
    init(json:[String:Any]) {
        color = json["color"] as? String ?? ""
        mood = json["mood"] as? String ?? ""
        show_burn = json["show_burn"] as? Bool ?? false
    }
    
    func getMoodMeterData() -> [WWMMoodMeterData] {
        var moodArray = [WWMMoodMeterData]()
        if let path = Bundle.main.url(forResource: "MoodMeterData", withExtension: "geojson")
            {
            do {
                let data = try Data.init(contentsOf: path )
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let result = jsonResult["result"] as? [String:Any] {
                    if let moodMeter = result["moodMeter"] as? [[String:Any]]{
                        for dict in moodMeter {
                            let data = WWMMoodMeterData.init(json: dict)
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
