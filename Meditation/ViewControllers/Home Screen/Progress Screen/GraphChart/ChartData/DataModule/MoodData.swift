//
//  MoodData.swift
//  Charts
//
//  Created by Ankur Sharma on 12/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import Foundation

protocol MoodProtocol: Decodable {
  func getChartId()-> Int
//  func getDesc()-> String
  var chartOrder : Int{get}
}

struct MoodStruct: Decodable{
  var moodType: MoodProtocol!
  
  enum VeryHappy: Int, CaseIterable, MoodProtocol{
    
    case Sleepy = 1,Mellow,AtEase,Calm,Chilled,Dreamy,Thoughtful,Curious,Content,Grateful,Peaceful,Tranquil,Balanced,Carefree,Loving,Fulfiled,Serene,Blissful
    
    func getChartId() -> Int {
      return (18 * chartOrder ) - self.rawValue + 1
    }
    
    
    var chartOrder: Int{
      return 4
    }
  }
  
  enum Happy:Int, CaseIterable, MoodProtocol{
    case Ecstatic = 1,Euphoric,Elated,Inspired,Excited,Optimistic,Enthusiastic,Upbeat,Motivated,Playful,Cheerful,Energised,Radiant,Joyful,Proud,Focused,Hopeful,Pleasant
    
    func getChartId() -> Int {
      return (18 * chartOrder ) - self.rawValue + 1
    }
    
    var chartOrder: Int{
      return 3
    }
  }
  
  enum VerySad: Int, CaseIterable, MoodProtocol{
    case Confused = 1,uneasy,restless,tense,upset,annoyed,nervous,worried,frustrated,stressed,jittery,vulnerable,anxious,panicked,Angry,Livid,Furious,Enraged
    
    func getChartId() -> Int {
        return (18 * chartOrder) - self.rawValue + 1
    }
    
    var chartOrder: Int{
      return 1
    }
  }
  
  enum Sad: Int, CaseIterable, MoodProtocol{
    case Bored = 1,Apathetic,Tired,Drained,Disheartened,Sad,Down,Disapponted,Exhausted,Disconnected,Lonely,Despondent,Miserable,Pessimistic,Hopeless,Worthless,Despairig,Depressed
    
    func getChartId() -> Int {
      return (18 * chartOrder) - self.rawValue + 1
    }
    
    var chartOrder: Int{
      return 2
    }
  }
  
 static func getAllStringValues()-> [String]{
    var arr = [String]()
  
  let sad = Sad.allCases.sorted { (a, b) -> Bool in
    return a.getChartId() < b.getChartId()
  }.map ({String(describing: $0)})
  let verySad = VerySad.allCases.sorted { (a, b) -> Bool in
    return a.getChartId() < b.getChartId()
  }.map ({String(describing: $0)})
  let happy = Happy.allCases.sorted { (a, b) -> Bool in
    return a.getChartId() > b.getChartId()
  }.map ({String(describing: $0)})
  let veryHappy = VeryHappy.allCases.sorted { (a, b) -> Bool in
    return a.getChartId() > b.getChartId()
  }.map ({String(describing: $0)})
  
    arr.append(contentsOf: verySad)
    arr.append(contentsOf: sad)
    arr.append(contentsOf: happy)
    arr.append(contentsOf: veryHappy)
    
    return arr
  }
  
  func sort(a: MoodProtocol, b: MoodProtocol)-> Bool{
     return a.getChartId() < b.getChartId()
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    let code = try container.decode(Int.self)
    let internalCode = (code - 1) % 18 + 1
    switch code {
    case 1...18:
      self.moodType = VeryHappy(rawValue: internalCode)
    case 19...36:
      self.moodType = Happy(rawValue: internalCode)
    case 37...54:
      self.moodType = VerySad(rawValue: internalCode)
    case 55...72:
      self.moodType = Sad(rawValue: internalCode)
    default:
      break
    }
  }
  
}







