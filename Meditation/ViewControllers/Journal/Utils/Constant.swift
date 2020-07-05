//
//  Constant.swift
//  
//
//  Created by Ehsan on 18/12/19.
//  Copyright © 2019 Ehsan. All rights reserved.
//

import UIKit

class Constant: NSObject {
    
    static let DEFAULT_ACCEPT_HEADER = "application/json";
    static let DEFAULT_CONTENT_TYPE = "application/json; charset=UTF-8";
    
    static let Light_Green = UIColor(red: 94/255, green: 236/255, blue: 154/255, alpha: 1.0)
    
    static let underLineAttrs = [
    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0),
    NSAttributedString.Key.foregroundColor : UIColor.white,
    NSAttributedString.Key.underlineColor:Light_Green,
    NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
    
}

