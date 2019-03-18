//
//  WWMMoodProgressData.swift
//  Meditation
//
//  Created by Prema Negi on 15/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMMoodProgressData: NSObject{
    var graph_score = WWMGraphScoreData()
    var color_score   = WWMColorScoreData()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        if let dict = json["color_score"] as? [String:Any]{
            color_score = WWMColorScoreData.init(json: dict)
            
        }
        if let dict = json["graph_score"] as? [String:Any]{
            graph_score = WWMGraphScoreData.init(json: dict)
            
        }
    }
}

class WWMGraphScoreData: NSObject {
    
    var pre = [WWMGraphScorePrePostData]()
    var post = [WWMGraphScorePrePostData]()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        if let arrLevels = json["pre"] as? [[String:Any]]{
            for dict in arrLevels {
                let hashtagData = WWMGraphScorePrePostData.init(json: dict)
                pre.append(hashtagData)
            }
        }
        if let arrLevels = json["post"] as? [[String:Any]]{
            for dict in arrLevels {
                let eventData = WWMGraphScorePrePostData.init(json: dict)
                post.append(eventData)
            }
        }
    }
    
}

class WWMGraphScorePrePostData: NSObject {
    
    var date = String()
    var mood = String()
    init(json:[String:Any]) {
        date = json["date"] as? String ?? ""
        mood = json["mood"] as? String ?? "0.0"
    }
    
}

class WWMColorScoreData: NSObject {
    
    var pre = [WWMColorScorePrePostData]()
    var post = [WWMColorScorePrePostData]()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        if let arrLevels = json["pre"] as? [[String:Any]]{
            for dict in arrLevels {
                let hashtagData = WWMColorScorePrePostData.init(json: dict)
                pre.append(hashtagData)
            }
        }
        if let arrLevels = json["post"] as? [[String:Any]]{
            for dict in arrLevels {
                let eventData = WWMColorScorePrePostData.init(json: dict)
                post.append(eventData)
            }
        }
    }
    
}

class WWMColorScorePrePostData: NSObject {
    
    var quad_number = Int()
    var mood = Double()
    init(json:[String:Any]) {
        quad_number = json["quad_number"] as? Int ?? -1
        mood = json["mood"] as? Double ?? 0.0
    }
    
}


