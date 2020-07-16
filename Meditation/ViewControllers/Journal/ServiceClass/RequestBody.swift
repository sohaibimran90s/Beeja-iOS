//
//  RequestBody.swift
//  Info_Swipe
//
//  Created by Ehsan on 18/12/19.
//  Copyright © 2019 Ehsan. All rights reserved.
//

import UIKit

class RequestBody: NSObject {

//    "user_id": "74093",
//    "tell_us_why": "This is the Dummy Test 01",
//    "title":"this is the dummy title",
//    "date_time": 1590134444807,
//    "mood_color": "",
//    "mood_text": "",
//    "mood_id": "",
//    "med_type": "guided",
//    "journal_type":"text from audio"
//
    
    static func addJournalBody(appPreference: WWMAppPreference, title: String, textDescrip: String, type: String) -> Any
    {
        let jsonBody = ["user_id":appPreference.getUserID(),
                        "tell_us_why":textDescrip,
                        "title":title,
                        "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                        "mood_color":"",
                        "mood_text":"",
                        "mood_id":"",
                        "med_type": appPreference.getType(),
                        "journal_type": type,
                        ] as [String : Any];
        
        return jsonBody;
    }


    static func journalAssetsBody(journalId: Int, type: String) -> [String : AnyObject]
    {
        let jsonBody = ["journal_id":journalId,
                        "journal_type":type,
                        ] as [String : AnyObject];
        
        return jsonBody;
    }
    
    static func meditationCompleteBody(appPreference: WWMAppPreference, title: String,
                                       textDescrip: String, medCompObj: MeditationComplete, type: String) -> Any
    {
        let jsonBody = [
                        "type": appPreference.getType(),
                        "category_id": medCompObj.category_Id,
                        "emotion_id": medCompObj.emotion_Id,
                        "audio_id": medCompObj.audio_Id,
                        "guided_type": appPreference.getGuideType(),
                        "watched_duration": medCompObj.watched_duration,
                        "rating": medCompObj.rating,
                        "meditation_type": medCompObj.type,
                        "date_time": "\(Int(Date().timeIntervalSince1970*1000))",
                            "mood_color": "",
                            "mood_text": "",
                        "title":title,
                        "tell_us_why": textDescrip,
                        "prep_time": medCompObj.prepTime,
                        "meditation_time": medCompObj.meditationTime,
                        "rest_time": medCompObj.restTime,
                        "meditation_id": medCompObj.meditationID,
                        "level_id": medCompObj.levelID,
                        "user_id": appPreference.getUserID(),
                        "mood_id": appPreference.getMoodId(),
                            "step_id": 0,
                            "complete_percentage": "0",
                            "is_complete": 0,
                            "mantra_id": "1",
                            "duration": 0,
                        "journal_type": type
                        ] as [String : Any];
        
        return jsonBody;
    }
}
