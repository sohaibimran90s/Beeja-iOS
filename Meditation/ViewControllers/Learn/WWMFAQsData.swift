//
//  WWMFAQsData.swift
//  Meditation
//
//  Created by Prema Negi on 21/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMFAQsData: NSObject{
    var answers: String = ""
    var question: String = ""
    
    override init() {
    }
    
    init(json: [String: Any]){
        self.answers = json["answers"] as? String  ?? ""
        self.question = json["question"] as? String ?? ""
    }
}
