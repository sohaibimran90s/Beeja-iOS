//
//  WWMWisdomData.swift
//  Meditation
//
//  Created by Roshan Kumawat on 16/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWisdomData: NSObject {

    var cat_Id = Int()
    var cat_Name = String()
    var cat_VideoList   = [WWMWisdomVideoData]()
    
    override init() {
        
    }
    init(json:[String:Any]) {
        cat_Id = json["id"] as? Int ?? 1
        cat_Name = json["name"] as? String ?? ""
        print(cat_Name)
        if let arrLevels = json["video_list"] as? [[String:Any]]{
            for dict in arrLevels {
                let video = WWMWisdomVideoData.init(json: dict)
                cat_VideoList.append(video)
            }
        }
    }
}

class WWMWisdomVideoData: NSObject {
    
    var video_Id = Int()
    var video_Name = String()
    var video_Image = String()
    var video_Url = String()
    var video_Duration = String()
    var vote = Bool()
    var is_intro = String()
    
    init(json:[String:Any]) {
        video_Id = json["id"] as? Int ?? 1
        video_Name = json["name"] as? String ?? ""
        video_Image = json["poster_image"] as? String ?? ""
        video_Url = json["video_url"] as? String ?? ""
        video_Duration = json["duration"] as? String ?? ""
        vote = json["vote"] as? Bool ?? false
        is_intro = json["is_intro"] as? String ?? "0"
    }
}


//{
//    "success": true,
//    "code": 200,
//    "message": "success",
//    "result": [
//    {
//    "id": 1,
//    "name": "All",
//    "video_list": [
//    { "id": 3, "name": "Bliss, Joy \u2028and happiness", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 4, "name": "Infinite", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 5, "name": "Purity of \u2028Thought", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 6, "name": "Absolute \u2028Experience", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 7, "name": "The Waterfall", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//
//    { "id": 8, "name": "Elfin Castle", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ]
//    },
//    {
//    "id": 2,
//    "name": "Practical",
//    "video_list": [
//    { "id": 3, "name": "Bliss, Joy \u2028and happiness", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 5, "name": "Purity of \u2028Thought", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//    { "id": 6, "name": "Absolute \u2028Experience", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//
//    { "id": 7, "name": "The Waterfall", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ]
//    },
//    {
//    "id": 3,
//    "name": "Spiritual",
//    "video_list": [
//    { "id": 4, "name": "Infinite", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ,
//
//    { "id": 8, "name": "Elfin Castle", "poster_image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "video_url": "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", "duration": "60" }
//    ]
//    }
//    ]
//}
