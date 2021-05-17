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
                                       textDescrip: String, mediCompleteObj: MeditationComplete, type: String) -> Any
    {
       let jsonBody = [
            "type": appPreference.getType(),
            "step_id": WWMHelperClass.step_id,
            "mantra_id": appPreference.getMyntraId(),
            "category_id" : mediCompleteObj.category_Id,
            "emotion_id" : mediCompleteObj.emotion_Id,
            "audio_id" : mediCompleteObj.audio_Id,
            "guided_type" : appPreference.getGuideType(),
            "duration" : mediCompleteObj.watched_duration,
            "watched_duration" : mediCompleteObj.watched_duration,
            "rating" : mediCompleteObj.rating,
            "user_id": appPreference.getUserID(),
            "meditation_type":mediCompleteObj.type,
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why":textDescrip,
            "prep_time":mediCompleteObj.prepTime,
            "meditation_time":mediCompleteObj.meditationTime,
            "rest_time":mediCompleteObj.restTime,
            "meditation_id": mediCompleteObj.meditationID,
            "level_id":mediCompleteObj.levelID,
            "mood_id": Int(appPreference.getMoodId()) ?? 0,
            "complete_percentage": WWMHelperClass.complete_percentage,
            "is_complete": "1",
            "title": title,
            "journal_type": "",
            "challenge_day_id":WWMHelperClass.day_30_name,
            "challenge_type":WWMHelperClass.day_type

            ] as [String : Any]
        
        return jsonBody
    }
    
    static func logsBody(appPreference: WWMAppPreference, dateFrom: String, dateTo: String) -> [String : AnyObject]
    {
        let jsonBody = ["user_id": appPreference.getUserID(),
                        "device_id": UIDevice.current.identifierForVendor!.uuidString,
                        "platform": "iOS",
                        "app_version": WWMHelperClass.getVersion(),
                        "date_from": dateFrom,
                        "date_to": dateTo]  as [String : AnyObject]
        
        return jsonBody;
    }
}
