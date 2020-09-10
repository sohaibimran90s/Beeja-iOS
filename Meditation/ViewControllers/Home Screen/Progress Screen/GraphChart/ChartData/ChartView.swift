//
//  ChartView.swift
//  MoodChart
//
//  Created by Ankur Sharma on 19/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import UIKit

protocol CustomChartViewDelegate:class {
  func selected(index: Int, dataSet: Int)
    func yAxis(movedTo x: CGFloat)
}

class CustomChart: LineChartView{
  
  weak var customDelegate:CustomChartViewDelegate?
  
  override func initialize() {
    super.initialize()
    
    //enable scaling
    self.scaleYEnabled = true

    self.scaleXEnabled = false
    
    self.doubleTapToZoomEnabled = false
    self.backgroundColor = UIColor(red:0.18, green:0.14, blue:0.36, alpha:1.0)
      //UIColor(red:0.13, green:0.14, blue:0.43, alpha:1.0)
    self.drawGridBackgroundEnabled = true
    self.gridBackgroundColor = UIColor(red:0.83, green:0.73, blue:0.40, alpha:0.12)
    self.legend.textColor = UIColor.white.withAlphaComponent(0.04)
    self.highlightPerTapEnabled = true
    
    self.getAxis(.right).enabled = false
    self.clipValuesToContentEnabled = false
    
    
    //provide default formatter
    let axis  = self.getAxis(.left)
    axis.valueFormatter = LineChartFormatter()
    axis.drawBottomYLabelEntryEnabled = true
    axis.drawTopYLabelEntryEnabled = true
        axis.axisLineColor = UIColor.blue
        axis.drawAxisLineEnabled = true
    axis.labelTextColor = UIColor.white
    axis.drawGridLinesEnabled = false
    axis.axisMaxLabels = 72
    axis.axisMaximum = 72
    axis.axisMinimum = 1
    axis.labelCount = 72
    axis.granularity = 1
    
    let limitline = ChartLimitLine(limit: 36)
    limitline.lineColor = UIColor.white.withAlphaComponent(0.2)
    axis.addLimitLine(limitline)
    
    xAxis.axisMinimum = 1
    xAxis.axisMaxLabels = 7
    xAxis.labelCount = 7
    xAxis.granularity = 1
    xAxis.labelTextColor = UIColor.white
    self.legend.enabled = false

    self.leftAxis.labelXOffset = 20.0
    //set no data text
    self.noDataText = "No data to plot"
    self.noDataTextColor = UIColor.white
    
    //animate at starting
    animate(yAxisDuration: 2.0)
    
    self.delegate = self
  }
  
    
  func update(pre: LineChartDataSet? = nil, post: LineChartDataSet? = nil){
    
    var dataSets = [LineChartDataSet]()
    
    
    if let post = post {
      dataSets.append(post)
    }
    
    if let pre = pre {
      dataSets.append(pre)
    }
    
    
    guard !dataSets.isEmpty else {return}
    
    self.data = LineChartData(dataSets: dataSets)
    
    
        self.setVisibleXRangeMaximum(6)
        self.setVisibleXRangeMinimum(6)
  }
  
  func getPreMood(dataPoints: [Int], value: [Int])-> LineChartDataSet{
    
    let dataSet = getDataSet(value, dataPoints)
    
    dataSet.circleHoleRadius = 3
    
    //add color
    
    let gradientColors = [UIColor(red:0.16, green:0.33, blue:0.74, alpha:0.0).cgColor,
                          UIColor(red:0.16, green:0.33, blue:0.74, alpha:0.93).cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
    
    dataSet.fill = Fill(linearGradient: gradient, angle: 90)
    return dataSet
  }
  
  
  func getPostMood(dataPoints: [Int], value: [Int])-> LineChartDataSet{
    
    let dataSet = getDataSet(value, dataPoints)
    dataSet.lineDashLengths = [10, 5]
    dataSet.circleHoleRadius = 0
    
    //add color
    let gradientColors = [UIColor(red:0.11, green:0.77, blue:0.50, alpha:0.0).cgColor, UIColor(red:0.11, green:0.77, blue:0.50, alpha:0.87).cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

    dataSet.fill = Fill(linearGradient: gradient, angle: 90)
  return dataSet
  }
  
  
  
  fileprivate func getDataSet(_ value: [Int], _ dataPoints: [Int])-> LineChartDataSet{
    var dataEntries: [ChartDataEntry] = []
    for (i, val) in value.enumerated(){
      let entry = ChartDataEntry(x: Double(val), y: Double(dataPoints[i]))
      
      dataEntries.append(entry)
    }
    
    print("dataentries... \(dataEntries)")
    
    let set = LineChartDataSet(entries: dataEntries)
    set.mode = .horizontalBezier
    set.drawValuesEnabled = false
    set.lineWidth = 1
    set.circleRadius = 4
    set.colors = [UIColor.white]
    set.circleColors = [UIColor.white]
    set.circleHoleColor = UIColor.black
    set.drawFilledEnabled = true
    set.highlightEnabled = true
    set.fillAlpha = 0.8
    set.drawVerticalHighlightIndicatorEnabled = false
    set.drawHorizontalHighlightIndicatorEnabled = false
    
    return set
  }
  
  func clearData(){
    self.data?.clearValues()
  }
  
  func refresh(){

    UIView.animate(withDuration: 2.0) {
       self.notifyDataSetChanged()
        self.animate(yAxisDuration: 2.0)
    }
  }
  
  func resetView(){
    self.leftAxis.selected = nil
    self.zoomAndCenterViewAnimated(scaleX: 1, scaleY: 1 / self.scaleY, xValue: 0, yValue: 0, axis: .left, duration: 1.0)
    self.notifyDataSetChanged()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        self.refreshAxisLineObserver()
    })
    
  }
    
    override func layoutSubviews() {
        UIView.animate(withDuration: 0, animations: {
            super.layoutSubviews()
        }) { (_) in
                self.customDelegate?.yAxis(movedTo: self.viewPortHandler.contentLeft)
        }
    }
}


extension CustomChart: ChartViewDelegate{
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    self.leftAxis.selected = entry
    self.zoomAndCenterViewAnimated(scaleX: 1, scaleY: 4, xValue: entry.x, yValue: entry.y, axis: .left, duration: 1.0, easingOption: ChartEasingOption.linear)
    self.customDelegate?.selected(index: highlight.dataIndex, dataSet: highlight.dataSetIndex)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        self.refreshAxisLineObserver()
    })
    
  }
  
  func chartValueNothingSelected(_ chartView: ChartViewBase) {
    self.leftAxis.selected = nil
    refreshAxisLineObserver()
  }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        refreshAxisLineObserver()
    }
    
    func refreshAxisLineObserver(){
        self.customDelegate?.yAxis(movedTo: self.viewPortHandler.contentLeft)
    }
}
