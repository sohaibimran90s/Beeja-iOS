//
//  Constant.swift
//  
//
//  Created by Ehsan on 18/12/19.
//  Copyright © 2019 Ehsan. All rights reserved.
//

import UIKit

class Constant: NSObject {
    
    static let DEFAULT_ACCEPT_HEADER = "application/json";
    static let DEFAULT_CONTENT_TYPE = "application/json; charset=UTF-8";
    
    static let Light_Green = UIColor(red: 94/255, green: 236/255, blue: 154/255, alpha: 1.0)
    static let Light_Green_Underline =  UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)

    static let underLineAttrs = [
    //NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0), // Maxx-medium set from XIB
    NSAttributedString.Key.foregroundColor : UIColor.white,
    NSAttributedString.Key.underlineColor:Light_Green_Underline,
    NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
    
    
    static let FILENAME = "myRecording.m4a"
    
    static let kNotificationInAudioJournal = "StopAudioEngineAndRecorderInAudioJournal"
    static let kNotificationInAudioToTextJournal = "StopAudioEngineAndSpeechRecognizerInAudioToTextJournal"
    static let kCancel = "Cancel"
    static let kGoToSetting = "Go To Settings"

    
    
    struct JournalType {
        static let TEXT: String = "text"
        static let IMAGE:String = "image"
        static let VOICE:String = "audio"
        static let VOICE_TO_TEXT:String = "voiceToText"
    }


}

