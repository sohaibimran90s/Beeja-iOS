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
    var level_id: Int = 0
    var timerImage: String = ""
    
    
    override init() {
    }
    
    init(json: [String: Any]) {
        
        print("json... \(json)")
        self.duration = json["duration"] as? Int ?? 0
        self.id = json["id"] as? Int ?? 0
        self.image = json["image"] as? String ?? ""
        self.like = json["like"] as? Int ?? 0
        self.title = json["title"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.level_id = json["level_id"] as? Int ?? 0
        
        if self.type == "timer"{
            switch WWMHelperClass.timerCount {
                case 0:
                    self.timerImage = "timer1"
                case 1:
                    self.timerImage = "timer2"
                case 2:
                    self.timerImage = "timer3"
                case 3:
                    self.timerImage = "timer4"
                case 4:
                    self.timerImage = "timer5"
                    WWMHelperClass.timerCount = -1
                default:
                  break
            }
            print("timerCount++++ \(WWMHelperClass.timerCount)")
            
            WWMHelperClass.timerCount = WWMHelperClass.timerCount + 1
        }else{
            self.timerImage = "timer1"
        }
        
        
        if let time = json["time"] as? [String: Any]{
            self.date = time["date"] as? String ?? ""
            if let timezone = time["timezone"] as? [String: Any]{
                self.timezone = timezone["timezone"] as? String ?? ""
                self.timezone_type = timezone["timezone_type"] as? Int ?? 0
            }
        }
    }
}
