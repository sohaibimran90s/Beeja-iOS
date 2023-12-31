//
//  WWMUserData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 25/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
//"id": 11,
//"name": "Abhi Agrawal",
//"email": "abhi@mailinator.com",
//"remember_token": "HlmLMbzMzalzoYcKfkrOUwu0HLVdKUKu",
//"profile_image": null,
//"social_id": "",
//"meditation_id": 1,
//"level_id": 1,
//"is_active": 1,
//"is_subscribed": 1,
//"latitude": "26.989824",
//"longitude": "75.8735234",
//"city": "Gurgaon",
//"country": "India",
//"created_at": "2019-02-26 07:39:53",
//"updated_at": "2019-02-28 06:07:21",
//"deleted_at": null
class WWMUserData: NSObject {
    
    private static var singleTonVar:WWMUserData?
    var userId = String()
    var name = String()
    var email   = String()
    var remember_token   = String()
    var profileImage   = String()
    var is_active   = Bool()
    var is_subscribed   = Bool()
    var social_id = String()
    var latitude = String()
    var longitude = String()
    var city = String()
    var country = String()
    var created_at = String()
    var updated_at = String()
    var deleted_at = String()
    var loginType = String()
    var type = String()
    var guided_type = String()
    
    var preMood: Int = 0
    var postMood: Int = 0
    var preJournal: Int = 0
    var postJournal: Int = 0
    var expiry_date: String = ""
    var subscription_plan: String = ""
    var subscription_id: Int = 0
    
    var meditation_id = Int()
    var level_id = Int()
    
    class var sharedInstance: WWMUserData {
        guard let unshared = singleTonVar else {
            singleTonVar = WWMUserData()
            return singleTonVar!
        }
        return unshared
    }
    
    override init() {
    }
    
    init(json:[String:Any]) {
        userId = "\(json["id"] ?? "")"
        remember_token = json["remember_token"] as? String ?? ""
        name = json["name"] as? String ?? ""
        email = json["email"] as? String ?? ""
        profileImage = json["profile_image"] as? String ?? ""
        social_id = json["social_id"] as? String ?? ""
        loginType = json["login_type"] as? String ?? ""
        
        latitude = json["latitude"] as? String ?? ""
        longitude = json["longitude"] as? String ?? ""
        city = json["city"] as? String ?? ""
        country = json["country"] as? String ?? ""
        created_at = json["created_at"] as? String ?? ""
        updated_at = json["updated_at"] as? String ?? ""
        deleted_at = json["deleted_at"] as? String ?? ""
        type = json["type"] as? String ?? "timer" //timer/guided/learn
        guided_type = json["guided_type"] as? String ?? "practical" //practical/spiritual
        
        meditation_id = json["meditation_id"] as? Int ?? 1
        level_id = json["level_id"] as? Int ?? 1
        
        is_active = json["is_active"] as? Bool ?? true
        is_subscribed = json["is_subscribed"] as? Bool ?? true
    }
    
    init(subscriptionJson:[String:Any]){
        if let expiry_date = subscriptionJson["expiry_date"] as? String{
            self.expiry_date = expiry_date
        }
        
        if let mood = subscriptionJson["mood"] as? [String: Any]{
            if let preMood = mood["pre"] as? Int{
                self.preMood = preMood
            }
            if let postMood = mood["post"] as? Int{
                self.postMood = postMood
            }
        }
        
        if let journal = subscriptionJson["journal"] as? [String: Any]{
            if let preJournal = journal["pre"] as? Int{
                self.preJournal = preJournal
            }
            if let postJournal = journal["post"] as? Int{
                self.postJournal = postJournal
            }
        }
        
        if let subscription_id = subscriptionJson["subscription_id"] as? Int{
            self.subscription_id = subscription_id
        }
        
        if let subscription_plan = subscriptionJson["subscription_plan"] as? String{
            self.subscription_plan = subscription_plan
        }
    }
}
