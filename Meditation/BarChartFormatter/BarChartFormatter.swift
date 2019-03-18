//
//  BarChartFormatter.swift
//  Meditation
//
//  Created by Prema Negi on 14/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit
import Charts

@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter{
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return months[Int(value)]
    }
}
