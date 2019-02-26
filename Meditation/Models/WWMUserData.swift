//
//  WWMUserData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 25/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMUserData: NSObject {

    var userId = String()
    var token = String()
    var name = String()
    var email   = String()
    var profileImage   = String()
    var isActive   = Bool()
    var isSubscription   = Bool()
    var isAfternoonReminder   = Bool()
    var isMorningReminder   = Bool()
    var moodMeterEnable   = Bool()
    
    var startChime   = String()
    var endChime   = String()
    var finishChime   = String()
    var intervalChime   = String()
    var ambientChime   = String()
    var morningReminderTime   = String()
    var afternoonReminderTime   = String()
    
    var meditationType = [WWMMeditationData()]
    
    override init() {
        
    }
    init(json:[String:Any]) {
        userId = json["userId"] as? String ?? ""
        token = json["token"] as? String ?? ""
        name = json["name"] as? String ?? ""
        email = json["email"] as? String ?? ""
        profileImage = json["profileImage"] as? String ?? ""
        isActive = json["isActive"] as? Bool ?? false
        isSubscription = json["isSubscription"] as? Bool ?? false
        startChime = json["startChime"] as? String ?? ""
        endChime = json["endChime"] as? String ?? ""
        finishChime = json["finishChime"] as? String ?? ""
        intervalChime = json["intervalChime"] as? String ?? ""
        ambientChime = json["ambientChime"] as? String ?? ""
        morningReminderTime = json["morningReminderTime"] as? String ?? ""
        afternoonReminderTime = json["afternoonReminderTime"] as? String ?? ""
        moodMeterEnable = json["moodMeterEnable"] as? Bool ?? false
        isAfternoonReminder = json["isAfternoonReminder"] as? Bool ?? false
        isMorningReminder = json["isMorningReminder"] as? Bool ?? false
        
        if let arrMeditationType = json["meditationType"] as? [[String:Any]]{
            for dict in arrMeditationType {
                let data = WWMMeditationData.init(json: dict)
                meditationType.append(data)
            }
        }
        
    }
}
