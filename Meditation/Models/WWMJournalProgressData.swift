//
//  WWMJournalProgressData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 27/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMJournalProgressData: NSObject {
    var text = String()
    var date_time = String()
    var mood_status = String()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        text = json["text"] as? String ?? ""
        date_time = json["date_time"] as? String ?? ""
        mood_status = json["mood_status"] as? String ?? ""
    }
}


//"id": 16,
//"user_id": 11,
//"text": "I am feeling Fulfiled because jfufuf7t I think I can get it for me and I think",
//"date_time": "1550569451096",
//"file": null,
//"file_type": null,
//"created_at": "2019-02-26 06:47:26",
//"updated_at": "2019-02-26 06:47:26",
//"deleted_at": null,
//"mood_id": 16,
//"journal_id": 36,
//"mood_status": "Post",
//"name": "Fulfiled",
//"color": "#1E9C9D",
//"type": "happyness",
//"mood_number": 16,
//"quad_number": 1
