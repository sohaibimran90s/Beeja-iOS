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
    var step_id = 0
    var min_limit = String()
    var max_limit = String()
    var meditation_key = String()
    var completedStatus = false
    var complete_count = String()
    var intro_url = String()
    
    override init() {
    }
    
    init(json:[String:Any]) {
        cat_Id = json["id"] as? Int ?? 1
        cat_Name = json["name"] as? String ?? ""
        cat_mode = json["mode"] as? String ?? ""
        cat_meditation_type = json["meditation_type"] as? String ?? ""
        min_limit = json["min_limit"] as? String ?? "95"
        max_limit = json["max_limit"] as? String ?? "98"
        meditation_key = json["meditation_key"] as? String ?? "practical"
        complete_count = "\(json["complete_count"] as? Int ?? 0)"
        intro_url = json["intro_url"] as? String ?? ""
        
        if let arrLevels = json["emotion_list"] as? [[String:Any]]{
            for dict in arrLevels {
                
                if cat_Name.contains("21"){
                    self.step_id = self.step_id + 1
                    
                    //print("dictkdjsfkdsjfl...... \(dict) step_id++ \(self.step_id)")
                }
                
                if cat_Name.contains("7"){
                    self.step_id = self.step_id + 1
                    
                    //print("dictkdjsfkdsjfl...... \(dict) step_id++ \(self.step_id) completed+++ \(dict["completed"] as? Bool ?? false)")
                }
                
                let video = WWMGuidedEmotionData.init(json: dict, stepId: self.step_id)
                cat_EmotionList.append(video)
                                
                if cat_Name.contains("7"){
                    
                    //to check if the 7 challenge completed or not
                    let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.cat_Name, dbName: "DBGuidedData", name: "guided_name")
                    
                    //print("step_no+++ \(self.step_id) cat_meditation_type \(cat_meditation_type) cat_Name \(cat_Name) guidedDataDB.count*** \(guidedDataDB.count)")
                    
                    for dict in guidedDataDB{
                        if (dict as AnyObject).meditation_type == cat_meditation_type{
                            let guidedEmotionsDataDB = WWMHelperClass.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).guided_id ?? "0", dbName: "DBGuidedEmotionsData", name: "guided_id")
                            //print("guidedEmotionsDataDB count... \(guidedEmotionsDataDB.count)")
                            for dict1 in guidedEmotionsDataDB{
                                //print("(dict1 as AnyObject).completed... \((dict1 as AnyObject).completed)")
                                if !(dict1 as AnyObject).completed{
                                    completedStatus = true
                                }
                            }
                        }
                    }
                    
                    //if completedStatus is true its mean 7 challengs is not completed yet otherwise it is completed
                    if completedStatus{
                        let com = dict["completed"] as? Bool ?? false
                        
                        if self.step_id == 7 && com == false{
                            return
                        }else if self.step_id == 7 && com == true{
                            cat_EmotionList.removeAll()
                        }else if self.step_id == 14 && com == false{
                            return
                        }else if self.step_id == 14 && com == true{
                            cat_EmotionList.removeAll()
                        }
                    }else{
                        //print("challenge completed")
                    }
                }
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
    var completed = Bool()
    var completed_date = String()
    var audio_list = [WWMGuidedAudioData]()
    var step_id = String()
    var intro_url = String()
    var emotion_type = String()
    
    override init() {
    }

    init(json:[String:Any], stepId: Int) {
        emotion_Id = json["emotion_id"] as? Int ?? 1
        emotion_Name = json["emotion_name"] as? String ?? ""
        emotion_Image = json["emotion_image"] as? String ?? ""
        tile_type = json["tile_type"] as? String ?? ""
        author_name = json["author_name"] as? String ?? ""
        emotion_body = json["emotion_body"] as? String ?? ""
        emotion_key = json["emotion_key"] as? String ?? ""
        intro_completed = json["intro_completed"] as? Bool ?? false
        completed = json["completed"] as? Bool ?? false
        completed_date = json["completed_date"] as? String ?? ""
        step_id = "\(stepId)"
        intro_url = json["intro_url"] as? String ?? ""
        emotion_type = json["emotion_type"] as? String ?? ""
        
        var isSaveAudioData = 0
        if let arrLevels = json["audio_list"] as? [[String:Any]]{
            for dict in arrLevels {
                
                if self.audio_list.count > 0{
                    for i in 0..<self.audio_list.count{
                        let id = self.audio_list[i].audio_Id
                        if dict["id"] as? Int == id{
                            isSaveAudioData = 1
                        }
                    }
                }
                
                if isSaveAudioData == 0{
                    let video = WWMGuidedAudioData.init(json: dict)
                    audio_list.append(video)
                }
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
