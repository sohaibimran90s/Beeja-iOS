//
//  WWMMantraData.swift
//  Meditation
//
//  Created by Prema Negi on 21/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMMantraData: NSObject{
    var Description: String = ""
    var id: Int = 1
    var mantra_audio: String = ""
    var title: String = ""
    
    override init() {
    }
    
    init(json: [String: Any]) {
        self.Description = json["description"] as? String ?? ""
        self.id = json["id"] as? Int ?? 1
        self.mantra_audio = json["mantra_audio"] as? String ?? ""
        self.title = json["title"] as? String ?? ""
    }
}
