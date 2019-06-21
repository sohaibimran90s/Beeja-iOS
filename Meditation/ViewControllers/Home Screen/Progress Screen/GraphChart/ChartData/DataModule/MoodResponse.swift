//
//  MoodResponse.swift
//  Charts
//
//  Created by Ankur Sharma on 12/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import Foundation


struct Response<T: Decodable>: Decodable {
  let isSuccess: Bool
  let code: Int
  let message: String?
  let result: T?
  
  static func getMoodData()-> [MoodData]{
    guard let path = Bundle.main.path(forResource: "moodData", ofType: "json")else {return []}
    
    guard let jsonData = NSData.init(contentsOfFile: path) else {return []}
    let response = try! JSONDecoder().decode(Response<MoodResponse>.self, from: jsonData as Data)
    return response.result!.graph_score
  }
  
  enum CodingKeys: String, CodingKey {
    case isSuccess = "success"
    case code, message, result
  }
}

struct MoodResponse: Decodable {
  let graph_score: [MoodData]
}


struct MoodData: Decodable{
  var date:String
  var pre, post: Mood
}

struct Mood: Decodable {
  let id: MoodStruct
  let color: String //hex code
  let text: String
  
  enum CodingKeys: String, CodingKey{
    case id = "mood_id"
    case color = "mood_color"
    case text = "mood_text"
  }
}
