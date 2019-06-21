//
//  DateUtil.swift
//  MoodChart
//
//  Created by Ankur Sharma on 19/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import UIKit

extension String{
  var day: Int?{
    let dateString = self
    let formater = DateFormatter()
    formater.dateFormat = "dd/MM/yyyy"
    guard let date = formater.date(from: dateString) else{
      return nil
    }
    
    let component = Calendar.current.component(.day, from: date)
    return component;
  }
  
  var monthName: String?{
    let dateString = self
    let formater = DateFormatter()
    formater.dateFormat = "dd/MM/yyyy"
    guard let date = formater.date(from: dateString) else{
      return nil
    }
    formater.dateFormat = "MMM"
    
    return formater.string(from: date)
  }
}


extension UIColor{
  static func colorWithHexString(hexString: String, alpha:CGFloat = 1.0) -> UIColor {
    
    // Convert hex string to an integer
    let hexint = Int(self.intFromHexString(hexStr: hexString))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
    
    // Create color object, specifying alpha as well
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
  }
  
  static func intFromHexString(hexStr: String) -> UInt32 {
    var hexInt: UInt32 = 0
    // Create scanner
    let scanner: Scanner = Scanner(string: hexStr)
    // Tell scanner to skip the # character
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    // Scan hex value
    scanner.scanHexInt32(&hexInt)
    return hexInt
  }
}
