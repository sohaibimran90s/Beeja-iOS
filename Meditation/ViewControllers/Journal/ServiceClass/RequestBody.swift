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
    
    static func addJournalBody(appPreference: WWMAppPreference, title: String, textDescrip: String) -> Any
    {
        let jsonBody = ["user_id":appPreference.getUserID(),
                        "tell_us_why":textDescrip,
                        "title":title,
                        "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                        "mood_color":"",
                        "mood_text":"",
                        "mood_id":"",
                        "med_type":"guided",
                        "journal_type":appPreference.getType(),
                        ] as [String : Any];
        
        return jsonBody;
    }


    static func journalAssetsBody(journalId: Int, type: String) -> Any//[String : AnyObject]
    {
        let jsonBody = ["journal_id":journalId,
                        "journal_type":type,
                        ] as [String : AnyObject];
        
        return jsonBody;
    }
    
    static func meditationCompleteBody(appPreference: WWMAppPreference, title: String, textDescrip: String) -> Any
    {
        let jsonBody = [
                        "type": "guided",
                        "category_id": 0,
                        "emotion_id": 0,
                        "audio_id": 0,
                        "guided_type": "Guided",
                        "watched_duration": 0,
                        "rating": 0,
                        "meditation_type": "pre",
                        "date_time": "\(Int(Date().timeIntervalSince1970*1000))",
                        "mood_color": "#17EFB3",
                        "mood_text": "Content",
                        "title":title,
                        "tell_us_why": textDescrip,
                        "prep_time": 0,
                        "meditation_time": 0,
                        "rest_time": 0,
                        "meditation_id": 0,
                        "level_id": 0,
                        "user_id": appPreference.getUserID(),
                        "mood_id": appPreference.getMoodId(),
                        "step_id": 0,
                        "complete_percentage": "0",
                        "is_complete": 0,
                        "mantra_id": "1",
                        "duration": 0,
                        "journal_type": appPreference.getType()
                        ] as [String : Any];
        
        return jsonBody;
    }
}
