//
//  WWMMyProgressMoodVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import GaugeKit
import Charts


class WWMMyProgressMoodVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{


    var moodProgressDurationView = WWMMoodProgressDurationView()
    var moodProgressData = WWMMoodProgressData()
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    @IBOutlet weak var tblMoodProgress: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getMoodProgress()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK:- UIButton Action
    
    @IBAction func btnCloseAction(_ sender: Any) {
        moodProgressDurationView.removeFromSuperview()
    }
    
    @IBAction func btnChangeDurationAction(_ sender: Any) {
        moodProgressDurationView = UINib(nibName: "WWMMoodProgressDurationView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMMoodProgressDurationView
        let window = UIApplication.shared.keyWindow!
        
        moodProgressDurationView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        moodProgressDurationView.btnYear.layer.borderWidth = 2.0
        moodProgressDurationView.btnYear.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        moodProgressDurationView.btnMonth.layer.borderWidth = 2.0
        moodProgressDurationView.btnMonth.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        moodProgressDurationView.btnDays.addTarget(self, action: #selector(btnWeeKAction(_:)), for: .touchUpInside)
        moodProgressDurationView.btnMonth.addTarget(self, action: #selector(btnMonthAction(_:)), for: .touchUpInside)
        moodProgressDurationView.btnYear.addTarget(self, action: #selector(btnYearAction(_:)), for: .touchUpInside)
        
        moodProgressDurationView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        
        window.rootViewController?.view.addSubview(moodProgressDurationView)
    }
    
    @IBAction func btnWeeKAction(_ sender: Any) {
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }
    
    @IBAction func btnMonthAction(_ sender: Any) {
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }
    
    @IBAction func btnYearAction(_ sender: Any) {
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }

    // MARK:- UITable View Delegates Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPieChart") as! WWMProgressMoodPieTVC
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellGraphChart") as! WWMProgressMoodPieTVC
            
            let chartView = cell.viewWithTag(201) as! LineChartView
            
            //chartView.delegate = self as! ChartViewDelegate
            
            chartView.chartDescription?.enabled = false
            chartView.dragEnabled = true
            chartView.setScaleEnabled(false)
            chartView.pinchZoomEnabled = true
            
            chartView.drawGridBackgroundEnabled = false
            chartView.gridBackgroundColor = UIColor.clear
            
            // x-axis limit line
            let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
            llXAxis.lineWidth = 4
            llXAxis.lineDashLengths = [10, 10, 0]
            llXAxis.labelPosition = .rightBottom
            llXAxis.valueFont = .systemFont(ofSize: 10)
            llXAxis.valueTextColor = UIColor.white
            
            
            // Done by prachi
            chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            chartView.xAxis.drawGridLinesEnabled = false
            //chartView.xAxis.drawLabelsEnabled = false
            chartView.leftAxis.drawGridLinesEnabled = false

            chartView.highlightValue(nil)
            
           // chartView.data?.highlightEnabled = false
            
            
            chartView.scaleXEnabled = true
            chartView.scaleYEnabled = true
            
            chartView.viewPortHandler.setMaximumScaleX(4)
            chartView.viewPortHandler.setMaximumScaleY(4)
            
            //chartView.dragDecelerationEnabled = false
            
            
            
            
           
            
            
            
            
            
            
            
            
            
            
          //  chartView.xAxis.gridLineDashLengths = [10, 10]
          //  chartView.xAxis.gridLineDashPhase = 0
            
//            let ll1 = ChartLimitLine(limit: 150, label: "Upper Limit")
//            ll1.lineWidth = 4
//            ll1.lineDashLengths = [5, 5]
//            ll1.labelPosition = .rightTop
//            ll1.valueFont = .systemFont(ofSize: 10)
//            ll1.valueTextColor = UIColor.white
            
            
//            let ll2 = ChartLimitLine(limit: -30, label: "Lower Limit")
//            ll2.lineWidth = 4
//            ll2.lineDashLengths = [5,5]
//            ll2.labelPosition = .rightBottom
//            ll2.valueFont = .systemFont(ofSize: 10)
//            ll2.valueTextColor = UIColor.white
            
            
            let leftAxis = chartView.leftAxis
            leftAxis.removeAllLimitLines()
           // leftAxis.addLimitLine(ll1)
           // leftAxis.addLimitLine(ll2)
            leftAxis.axisMaximum = 30.0
            leftAxis.axisMinimum = 0.0
            
            //leftAxis.gridLineDashLengths = [5, 5]
            //leftAxis.drawLimitLinesBehindDataEnabled = true
            leftAxis.labelTextColor = UIColor.white
            
            
            chartView.rightAxis.enabled = false
            
            let xAxix = chartView.xAxis
            xAxix.removeAllLimitLines()
            
            
            
//            let arr = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
//            for index in 0..<arr.count {
//                let limit = ChartLimitLine.init(limit: Double(index), label: arr[index])
//
//                xAxix.addLimitLine(limit)
//
//            }
            
//
//            let chartFormmater=BarChartFormatter()
//
//            for i in 0..<11{
//                chartFormmater.stringForValue(Double(i), axis: xAxis)
//            }
//
//            xAxix.valueFormatter=chartFormmater
//            chartView.xAxis.valueFormatter=xAxis.valueFormatter
            
            
            //xAxix.valueFormatter = self
            
             xAxix.axisMaximum = 30
             xAxix.axisMinimum = 1
            
            xAxix.labelTextColor = UIColor.white
            
            
            
//            let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
//                                       font: .systemFont(ofSize: 12),
//                                       textColor: .white,
//                                       insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
//            marker.chartView = chartView
//            marker.minimumSize = CGSize(width: 80, height: 40)
            let marke = MarkerView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 40))
            marke.chartView = chartView
            marke.backgroundColor = UIColor.clear
            
            chartView.marker = marke
            
            chartView.legend.form = .none
            
            chartView.animate(xAxisDuration: 2.5)
            
            
            
            let preData = self.moodProgressData.graph_score.pre
            var values1 = [ChartDataEntry]()
            for data in preData {
                //12/03/2019
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let monthDate = dateFormatter.date(from:data.date)!
                dateFormatter.dateFormat = "d"
                let xData = dateFormatter.string(from: monthDate)
                let value = ChartDataEntry.init(x: Double(xData) ?? 0.0, y: Double(data.mood) ?? 0.0 )
                
                values1.append(value)
            }
            
            let postData = self.moodProgressData.graph_score.post
            var values2 = [ChartDataEntry]()
            for data in postData {
                //12/03/2019
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let monthDate = dateFormatter.date(from:data.date)!
                dateFormatter.dateFormat = "d"
                let xData = dateFormatter.string(from: monthDate)
                let value = ChartDataEntry.init(x: Double(xData) ?? 0.0, y: Double(data.mood) ?? 0.0 )
                values2.append(value)
            }
            
           
            
            //print(moodChart1)
            
            
//            let arrData = [0,9,15,21,26,33,38,40]
//            let values = (0..<moodChart1.count).map { (i) -> ChartDataEntry in
//                let val = Double(arc4random_uniform(100) + 3)
//                return ChartDataEntry.init(x:Double(moodChart1[i]) , y: val)
//                //return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "icon"))
//            }
//
//            let values1 = (0..<arrData.count).map { (i) -> ChartDataEntry in
//                let val = Double(arc4random_uniform(150) + 3)
//                return ChartDataEntry.init(x:Double(arrData[i]) , y: val)
//                //return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "icon"))
//            }
            
            let set1 = LineChartDataSet(values: values1, label: "")
            set1.drawIconsEnabled = false
            set1.drawValuesEnabled = false
            
            //set1.lineDashLengths = [5, 2.5]
           // set1.highlightLineDashLengths = [5, 2.5]
            set1.setColor(.white)
            set1.mode = .cubicBezier
            set1.setCircleColor(.white)
           // set1.lineWidth = 1
            set1.circleRadius = 5
            set1.drawCircleHoleEnabled = false
            set1.valueFont = .systemFont(ofSize: 9)
            //set1.formLineDashLengths = [5, 2.5]
           // set1.formLineWidth = 1
           // set1.formSize = 15
            
            //
            //111962
            //64FFD4
            
            //001252
            //284DD0
            let gradientColors = [ChartColorTemplates.colorFromString("#11196200").cgColor,
                                  ChartColorTemplates.colorFromString("#64FFD400").cgColor]
            //let gradientColors = [UIColor.init(hexString: "#111962")!.cgColor,
                                 // UIColor.init(hexString: "#64FFD4")!.cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            
            let gradientColors1 = [ChartColorTemplates.colorFromString("#00125200").cgColor,
                                  ChartColorTemplates.colorFromString("#284DD000").cgColor]
//            let gradientColors1 = [UIColor.init(hexString: "#001252")!.cgColor,
//                                  UIColor.init(hexString: "#284DD0")!.cgColor]
            let gradient1 = CGGradient(colorsSpace: nil, colors: gradientColors1 as CFArray, locations: nil)!
            
            
            set1.fillAlpha = 1
            
            set1.fill = Fill(linearGradient: gradient1, angle: 90) //.linearGradient(gradient, angle: 90)
            set1.drawFilledEnabled = true
            
            
            let set2 = LineChartDataSet(values: values2, label: "")
            set2.drawIconsEnabled = false
            set2.drawValuesEnabled = false
            
            set2.lineDashLengths = [5, 2.5]
             set2.highlightLineDashLengths = [5, 2.5]
            set2.setColor(.white)
            set2.mode = .cubicBezier
            set2.setCircleColor(.white)
            // set1.lineWidth = 1
            set2.circleRadius = 5
            set2.drawCircleHoleEnabled = false
            set2.valueFont = .systemFont(ofSize: 9)
            set2.formLineDashLengths = [5, 2.5]
             set2.formLineWidth = 1
             set2.formSize = 15
            
            set2.fillAlpha = 1
            set2.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
            set2.drawFilledEnabled = true
            
            let data = LineChartData.init(dataSets: [set1,set2])
            
            chartView.data = data
            
            
            
            
//            let formato:BarChartFormatter = BarChartFormatter()
//            var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//
//
//            let xaxis:XAxis = XAxis()
//            for i in 0..<months.count{
//                formato.stringForValue(Double(i), axis: xaxis)
//                xaxis.valueFormatter = formato
//                chartView.xAxis.valueFormatter = xaxis.valueFormatter
            
            

            
            
            return cell
        }
        
    }
    

    
    
    // MARK:- UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return 2
        }else {
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellCiruclarGraph", for: indexPath) as! WWMMoodProgressCVC
        let color_score = self.moodProgressData.color_score
       
        
        cell.pageController.currentPage = indexPath.row
        var meditationData = [WWMColorScorePrePostData]()
        if indexPath.row == 0 {
            meditationData = color_score.pre
            cell.btnMeditationType.setTitle("Pre Medtiation", for: .normal)
        }else {
            meditationData = color_score.post
            cell.btnMeditationType.setTitle("Post Medtiation", for: .normal)
        }
        
        cell.viewCircle1.rate = 0
        cell.viewCircle2.rate = 0
        cell.viewCircle3.rate = 0
        cell.viewCircle4.rate = 0
        
        cell.lblPercentage1.text = "0%"
        cell.lblPercentage2.text = "0%"
        cell.lblPercentage3.text = "0%"
        cell.lblPercentage4.text = "0%"
        for dic in meditationData {
            if dic.quad_number == 1 {
//                cell.viewCircle1.animateRate(1.0, newValue:(dic["mood"] as! CGFloat)/10) { (Bool) in
//                    
//                }
                cell.viewCircle1.rate = CGFloat((Double(dic.mood))/10)//(dic.mood as! CGFloat)/10
                cell.lblPercentage1.text = "\(dic.mood)%"
            }else if dic.quad_number == 2 {
                cell.viewCircle2.rate = CGFloat((Double(dic.mood))/10)
                cell.lblPercentage2.text = "\(dic.mood)%"
            }else if dic.quad_number == 3 {
                cell.viewCircle3.rate = CGFloat((Double(dic.mood))/10)
                cell.lblPercentage3.text = "\(dic.mood)%"
            }else if dic.quad_number == 4 {
                cell.viewCircle4.rate = CGFloat((Double(dic.mood))/10)
                cell.lblPercentage4.text = "\(dic.mood)%"
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView.tag == 0 {
            return CGSize.init(width: self.view.frame.size.width, height: 447)
        }
        return CGSize.init(width: 300, height: 300)
    }

    
    
    
    func getMoodProgress() {
        WWMHelperClass.showSVHud()
        let param = ["user_id":self.appPreference.getUserID(),
                     ]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MOODPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let statsData = result["result"] as? [String:Any] {
                    
                    
                    print(statsData)
                    
                    self.moodProgressData = WWMMoodProgressData.init(json: statsData)
                    self.tblMoodProgress.reloadData()
                    
                }
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }


}

//extension WWMMyProgressMoodVC: IAxisValueFormatter {
//
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return months[Int(value)]
//    }
//}
