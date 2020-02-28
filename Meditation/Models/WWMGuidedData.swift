//
//  WWMGuidedData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 22/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedData: NSObject {

    var cat_Id = Int()
    var cat_Name = String()
    var cat_mode = String()
    var cat_meditation_type = String()
    var cat_EmotionList   = [WWMGuidedEmotionData]()
    
    override init() {
    }
    
    init(json:[String:Any]) {
        cat_Id = json["id"] as? Int ?? 1
        cat_Name = json["name"] as? String ?? ""
        cat_mode = json["mode"] as? String ?? ""
        cat_meditation_type = json["meditation_type"] as? String ?? ""
        
        if let arrLevels = json["emotion_list"] as? [[String:Any]]{
            for dict in arrLevels {
                print("dictkdjsfkdsjfl...... \(dict)")
                let video = WWMGuidedEmotionData.init(json: dict)
                cat_EmotionList.append(video)
            }
        }
    }
}

class WWMGuidedEmotionData: NSObject {
    
    var emotion_Id = Int()
    var emotion_Name = String()
    var emotion_Image = String()
    var tile_type = String()
    var author_name = String()
    var emotion_body = String()
    var emotion_key = String()
    var intro_completed = Bool()
    var audio_list = [WWMGuidedAudioData]()
    
    override init() {
    }

    init(json:[String:Any]) {
        emotion_Id = json["emotion_id"] as? Int ?? 1
        emotion_Name = json["emotion_name"] as? String ?? ""
        emotion_Image = json["emotion_image"] as? String ?? ""
        tile_type = json["tile_type"] as? String ?? ""
        author_name = json["author_name"] as? String ?? ""
        emotion_body = json["emotion_body"] as? String ?? ""
        emotion_key = json["emotion_key"] as? String ?? ""
        intro_completed = json["intro_completed"] as? Bool ?? false
        
        if let arrLevels = json["audio_list"] as? [[String:Any]]{
            for dict in arrLevels {
                let video = WWMGuidedAudioData.init(json: dict)
                audio_list.append(video)
            }
        }
    }
}

class WWMGuidedAudioData: NSObject {
    
    var audio_Id = Int()
    var audio_Duration = Int()
    var audio_Name = String()
    var audio_Image = String()
    var audio_Url = String()
    var author_name = String()
    var vote = Bool()
    var paid = Bool()
    
    override init() {
        
    }
    
    init(json:[String:Any]) {
        audio_Id = json["id"] as? Int ?? 1
        audio_Duration = json["duration"] as? Int ?? 0
        audio_Name = json["audio_name"] as? String ?? ""
        audio_Image = json["audio_image"] as? String ?? ""
        audio_Url = json["audio_url"] as? String ?? ""
        author_name = json["author_name"] as? String ?? ""
        vote = json["vote"] as? Bool ?? false
        paid = json["paid"] as? Bool ?? false
    }
}

//"duration" : 300,
//"id" : 1,
//"audio_name" : "Facebook",
//"audio_image" : "www.facebook.com",
//"audio_url" : "www.facebook.com"
