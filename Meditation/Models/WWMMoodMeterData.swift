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
    var id = Int()
    var name = String()
    var type = String()
    var mood_number = Int()
    var quad_number = Int()
    var created_at = String()
    var updated_at = String()
    var show_burn = Bool()
    override init() {
        color = ""
        name = ""
        type = ""
        mood_number = -1
        quad_number = -1
        created_at = ""
        updated_at = ""
        id = -1
        
        show_burn = false
    }
    init(json:[String:Any]) {
        color = json["color"] as? String ?? ""
        type = json["type"] as? String ?? ""
        name = json["name"] as? String ?? ""
        created_at = json["created_at"] as? String ?? ""
        updated_at = json["updated_at"] as? String ?? ""
        id = json["id"] as? Int ?? -1
        mood_number = json["mood_number"] as? Int ?? -1
        quad_number = json["quad_number"] as? Int ?? -1
        if  type == "happyness" {
            show_burn = false
        }else {
            show_burn = true
        }
    }
    
    func getMoodMeterData() -> [WWMMoodMeterData] {
        var moodArray = [WWMMoodMeterData]()
        
        
        let moodData = WWMHelperClass.fetchDB(dbName: "DBMoodMeter") as! [DBMoodMeter]
        if moodData.count > 0 {
            let json = moodData[0].data
            print(json!)
            if let jsonResult = self.convertToDictionary(text: json ?? "") {
                if let result = jsonResult["result"] as? [[String:Any]]{
                    for dict in result {
                        let data = WWMMoodMeterData.init(json: dict)
                        moodArray.append(data)
                    }
                }
                
            }
        }
        
        return moodArray
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
