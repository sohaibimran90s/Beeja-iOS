//
//  HighLightedChartrenderer.swift
//  MoodChart
//
//  Created by Ankur Sharma on 26/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import UIKit

class HighLightedChartRenderer: LineChartRenderer{
  
  let linechart: LineChartView
   init(chart: LineChartView, dataProvider: LineChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler) {
    self.linechart = chart
    super.init(dataProvider: dataProvider, animator: animator, viewPortHandler: viewPortHandler)
  }
}
