//
//  WWMMilestoneData.swift
//  Meditation
//
//  Created by Prema Negi on 08/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMMilestoneData: NSObject{
    
    var milestoneEnabledData = [WWMMilestoneEnabledData]()
    var milestoneDisabledData = [WWMMilestoneDisabledData]()
    
    override init() {
    }
    
    init(json: [String: Any]) {
        if let enabledArray = json["enabled"] as? [[String: Any]]{
            for enabled in enabledArray{
                let enabeldData =  WWMMilestoneEnabledData.init(json: enabled)
                milestoneEnabledData.append(enabeldData)
            }
        }
        
        if let disabledArray = json["disabled"] as? [[String: Any]]{
            for disabled in disabledArray{
                let enabeldData =  WWMMilestoneDisabledData.init(json: disabled)
                milestoneDisabledData.append(enabeldData)
            }
        }
    }
}

class WWMMilestoneEnabledData: NSObject{
    var id: Int = 0
    var title: String = ""
    var type: String = ""
    var status: Bool = false
    var sortOrder: Int = 0
    var complete_date = ""
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int ?? 0
        self.title = json["title"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.status = json["status"] as? Bool ?? false
        self.sortOrder = json["sortOrder"] as? Int ?? 0
        self.complete_date = json["complete_date"] as? String ?? ""
    }
}

class WWMMilestoneDisabledData: NSObject{
    var id: Int = 0
    var title: String = ""
    var type: String = ""
    var status: Bool = false
    var sortOrder: Int = 0
    var complete_date = ""
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int ?? 0
        self.title = json["title"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.status = json["status"] as? Bool ?? false
        self.sortOrder = json["sortOrder"] as? Int ?? 0
        self.complete_date = json["complete_date"] as? String ?? ""
    }
}
