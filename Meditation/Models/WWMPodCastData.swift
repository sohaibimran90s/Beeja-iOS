//
//  WWMPodCastData.swift
//  Meditation
//
//  Created by Prema Negi on 18/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit

class WWMPodCastData: NSObject{

    var id: Int = 0
    var title: String = ""
    var duration: Int = 0
    var url_link: String = ""
    var isPlay = false
    var analyticsName:String = ""
    var currentTimePlay: Int = 0
    
    override init() {
    }
    

    init(id: Int, title: String, duration: Int, url_link: String, isPlay: Bool, analyticsName:String, currentTimePlay: Int) {
        self.id = id
        self.title = title
        self.duration = duration
        self.url_link = url_link
        self.isPlay = isPlay
        self.analyticsName = analyticsName
        self.currentTimePlay = currentTimePlay
    }
}
