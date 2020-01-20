//
//  WWMMyProgressMoodVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import GaugeKit
import WebKit
import EFCountingLabel

class WWMMyProgressMoodVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{


    @IBOutlet weak var lblGraphFromToDate: UILabel!
    @IBOutlet weak var btnChangeDuration: UIButton!
    @IBOutlet weak var baseViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var graphBaseView: UIView!
    
    var moodProgressDurationView = WWMMoodProgressDurationView()
    var moodProgressData = WWMMoodProgressData()
    
    //weekly
    var type: String = "weekly"
    
    var days1 = [Int]()
    var daysStringArray: [String] = []
    var months1 = [Int]()
    
    var dateFormatter = DateFormatter()
    let cal = Calendar.current

    var currentDate: String = ""
    var previousDate: String = ""
    
    //Graph outlets
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var chartView: CustomChart!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var preLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var month: UILabel!
    
    @IBOutlet weak var overviewLeading: NSLayoutConstraint!
    @IBOutlet weak var leadingMonth: NSLayoutConstraint!
    
    @IBOutlet weak var tblMoodProgress: UITableView!
    
    var data: [MoodData] = []
    var currentChartStatus: ChartStatus = .both
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //1152
        self.baseViewHeightConstraint.constant = 550
        self.graphBaseView.isHidden = true
        self.setDateFromTooTo()
        
        var date = cal.startOfDay(for: Date())
        var days = [Int]()
        var months = [Int]()
        
        
        for _ in 1 ... 7 {
            let day = cal.component(.day, from: date)
            let month = cal.component(.month, from: date)
            days.append(day)
            months.append(month)
            date = cal.date(byAdding: .day, value: -1, to: date)!
        }

        for i in stride(from: days.count-1, through: 0, by: -1){
            days1.append(days[i])
            months1.append(months[i])
        }
        daysStringArray = days1.map { String($0) }

        self.getMoodProgress()
    }
    
    // MARK:- UIButton Action
    
    @IBAction func btnCloseAction(_ sender: Any) {
        moodProgressDurationView.removeFromSuperview()
    }
    
    @IBAction func btnChangeDurationAction(_ sender: Any) {
        moodProgressDurationView = UINib(nibName: "WWMMoodProgressDurationView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMMoodProgressDurationView
        let window = UIApplication.shared.keyWindow!
        
        moodProgressDurationView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        moodProgressDurationView.btnDays.addTarget(self, action: #selector(btnWeeKAction(_:)), for: .touchUpInside)
        moodProgressDurationView.btnMonth.addTarget(self, action: #selector(btnMonthAction(_:)), for: .touchUpInside)
        moodProgressDurationView.btnYear.addTarget(self, action: #selector(btnYearAction(_:)), for: .touchUpInside)
        
        moodProgressDurationView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        self.setMooProgressDurationUI(type: self.type)
        
        window.rootViewController?.view.addSubview(moodProgressDurationView)
    }
    
    
    func setMooProgressDurationUI(type:String) {
        
        moodProgressDurationView.btnYear.layer.borderWidth = 2.0
        moodProgressDurationView.btnYear.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        moodProgressDurationView.btnMonth.layer.borderWidth = 2.0
        moodProgressDurationView.btnMonth.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        moodProgressDurationView.btnDays.layer.borderWidth = 2.0
        moodProgressDurationView.btnDays.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        moodProgressDurationView.btnDays.backgroundColor = UIColor.clear
            moodProgressDurationView.btnYear.backgroundColor = UIColor.clear
        moodProgressDurationView.btnMonth.backgroundColor = UIColor.clear
        
        moodProgressDurationView.btnMonth.setTitleColor(UIColor.white, for: .normal)
        moodProgressDurationView.btnDays.setTitleColor(UIColor.white, for: .normal)
        moodProgressDurationView.btnYear.setTitleColor(UIColor.white, for: .normal)
        
        
        switch type {
        case "weekly":
            moodProgressDurationView.btnDays.backgroundColor = UIColor.init(hexString: "#00eba9")
            moodProgressDurationView.btnDays.setTitleColor(UIColor.black, for: .normal)
            break
            
        case "monthly":
            moodProgressDurationView.btnMonth.backgroundColor = UIColor.init(hexString: "#00eba9")
            moodProgressDurationView.btnMonth.setTitleColor(UIColor.black, for: .normal)
            break
            
        case "yearly":
            moodProgressDurationView.btnYear.backgroundColor = UIColor.init(hexString: "#00eba9")
            moodProgressDurationView.btnYear.setTitleColor(UIColor.black, for: .normal)
            
            break
            
        default:
            moodProgressDurationView.btnDays.backgroundColor = UIColor.init(hexString: "#00eba9")
            moodProgressDurationView.btnDays.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @IBAction func btnWeeKAction(_ sender: Any) {
        self.type = "weekly"
        
        self.setDateFromTooTo()
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }
    
    @IBAction func btnMonthAction(_ sender: Any) {
        
        self.type = "monthly"
        
        self.setDateFromTooTo()
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }
    
    @IBAction func btnYearAction(_ sender: Any) {
        
        self.type = "yearly"
        
        self.setDateFromTooTo()
        moodProgressDurationView.removeFromSuperview()
        self.getMoodProgress()
    }
    
    func setDateFromTooTo(){
        if self.type == "weekly"{
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM"
            
            var date1 = Date()
            self.currentDate = dateFormatter.string(from: date1)
            date1 = cal.date(byAdding: .day, value: -6, to: date1)!
            self.previousDate = dateFormatter.string(from: date1)
        }else if self.type == "monthly"{
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM"
            
            var date1 = Date()
            self.currentDate = dateFormatter.string(from: date1)
            let date2 = cal.date(byAdding: .month, value: -1, to: date1)!
            date1  = cal.date(byAdding: .day, value: 1, to: date2)!
            self.previousDate = dateFormatter.string(from: date1)
        }else{
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MMM yyyy"
            
            var date1 = Date()
            self.currentDate = dateFormatter.string(from: date1)
            date1 = cal.date(byAdding: .year, value: -1, to: date1)!
            date1 = cal.date(byAdding: .month, value: 1, to: date1)!
            
            self.previousDate = dateFormatter.string(from: date1)
        }
        
        print("\(self.currentDate).... \(self.previousDate)")
    }
    
    // MARK:- UITable View Delegates Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPieChart") as! WWMProgressMoodPieTVC
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
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
            meditationData = color_score.post
            cell.btnMeditationType.setTitle("Post Medtiation", for: .normal)
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS_MOOD_GRAPH_POST", itemId: "VIEWED", itemName: "")
            
        }else {
            meditationData = color_score.pre
            cell.btnMeditationType.setTitle("Pre Medtiation", for: .normal)
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS_MOOD_GRAPH_PRE", itemId: "VIEWED", itemName: "")
        }
        
        cell.viewCircle1.rate = 0
        cell.viewCircle2.rate = 0
        cell.viewCircle3.rate = 0
        cell.viewCircle4.rate = 0
        
        cell.lblPercentage1.text = "0"
        cell.lblPercentage2.text = "0"
        cell.lblPercentage3.text = "0"
        cell.lblPercentage4.text = "0"
        for dic in meditationData {
            if dic.quad_number == 1 {
                
                //cell.viewCircle4.rate = CGFloat((Double(dic.mood))/10)//(dic.mood as! CGFloat)/10
                //cell.lblPercentage1.text = "\(dic.mood)%"
                cell.lblPercentage1.format = "%.1f"
                cell.lblPercentage1.countFrom(0.0, to: CGFloat(dic.mood), withDuration: 1.0)
                
                
                cell.viewCircle4.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
            }else if dic.quad_number == 2 {
                //cell.viewCircle3.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle3.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
                //cell.lblPercentage2.text = "\(dic.mood)%"
                cell.lblPercentage2.format = "%.1f"
                cell.lblPercentage2.countFrom(0.0, to: CGFloat(dic.mood), withDuration: 1.0)
            }else if dic.quad_number == 4 {
                //cell.viewCircle2.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle2.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
                //cell.lblPercentage3.text = "\(dic.mood)%"
                cell.lblPercentage3.format = "%.1f"
                cell.lblPercentage3.countFrom(0.0, to: CGFloat(dic.mood), withDuration: 1.0)
            }else if dic.quad_number == 3 {
               // cell.viewCircle1.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle1.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in
                    
                }
                //cell.lblPercentage4.text = "\(dic.mood)%"
                cell.lblPercentage4.format = "%.1f"
                cell.lblPercentage4.countFrom(0.0, to: CGFloat(dic.mood), withDuration: 1.0)
            }
        }
        return cell
        
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
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        let xData = dateFormatter.string(from: currentDate)
        print(xData)
        
        let param = ["user_id":self.appPreference.getUserID(),"med_type" : self.appPreference.getType(), "date": xData, "type": self.type]
        
        print("mood para... \(param)")
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MOODPROGRESS, context: "WWMMyProgressMoodVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                if let statsData = result["result"] as? [String:Any] {
                    
                    print("statsData.... \(statsData)")
                    
                    if self.type == "weekly"{
                        self.btnChangeDuration.setTitle("Last 7 Days", for: .normal)
                    }else if self.type == "monthly"{
                        self.btnChangeDuration.setTitle("Last month", for: .normal)
                    }else{
                        self.btnChangeDuration.setTitle("Year", for: .normal)
                    }
                    self.moodProgressData = WWMMoodProgressData.init(json: statsData)
                    
                    
                    print("self.moodProgressData.color_score.pre... \(self.moodProgressData.color_score.pre)")
                    print("self.moodProgressData.color_score.post... \(self.moodProgressData.color_score.post)")
                    
                    self.graphChartApiCall()
                    self.tblMoodProgress.reloadData()
                }
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
           // self.graphChartApiCall()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    //MARK: Graph Chart
    
    func graphChartApiCall(){
        
        self.chartView.customDelegate = self
        
        ChartApi.type = self.type
        ChartApi.getChartData {[weak self] (data, error) in
            if error != nil{
                self?.showError()
            }else if let data = data{
                DispatchQueue.main.async {
                    
                    print("data....+++++ \(data)")
                    if data.count > 0{
                        self?.baseViewHeightConstraint.constant = 1152
                        self?.graphBaseView.isHidden = false
                        self?.data = data
                        self?.addBoth()
                        self?.month.text = self?.data.first?.date.monthName
                        
                        let format = DateFormatter()
                        format.dateFormat = "dd/MM/yyyy"

                        let month1: String = format.monthSymbols[Calendar.current.component(.month, from: format.date(from: "\(data[0].date)")!) - 1]
                        let monthString: String = String(month1.prefix(3))
                        
                        if data.count > 1{
                            let firstDay: String = "\(Calendar.current.component(.day, from: format.date(from: "\(data[0].date)")!))"
                            let lastDay: String = "\(Calendar.current.component(.day, from: format.date(from: "\(data[data.count - 1].date)")!))"
                            if firstDay.count == 1{
                                if lastDay.count == 1{
                                    self?.lblGraphFromToDate.text = "0\(firstDay)-0\(lastDay)\(monthString)"
                                }else{
                                    self?.lblGraphFromToDate.text = "0\(firstDay)-\(lastDay)\(monthString)"
                                }
                            }else{
                                if lastDay.count == 1{
                                    self?.lblGraphFromToDate.text = "\(firstDay)-0\(lastDay)\(monthString)"
                                }else{
                                    self?.lblGraphFromToDate.text = "\(firstDay)-\(lastDay)\(monthString)"
                                }
                            }
                        }else{
                            let firstDay: String = "\(Calendar.current.component(.day, from: format.date(from: "\(data[0].date)")!))"
                            if firstDay.count == 1{
                                self?.lblGraphFromToDate.text = "0\(firstDay)\(monthString)"
                            }else{
                                self?.lblGraphFromToDate.text = "\(firstDay)\(monthString)"
                            }
                        }

                        print("data[0].date... \(data[0].date) calendar.component(.month, from: date).. \(Calendar.current.component(.month, from: format.date(from: "\(data[0].date)")!))  calendar.component(.day, from: date).. \(Calendar.current.component(.day, from: format.date(from: "\(data[0].date)")!))")

                        print(format.monthSymbols[Calendar.current.component(.month, from: format.date(from: "\(data[0].date)")!) - 1])
                        
                    }else{
                        self?.baseViewHeightConstraint.constant = 1152
                        self?.graphBaseView.isHidden = false
                    }
                }
            }
        }
    }
    
    func showError(){
        let alert  = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func shuffleClicked(sender: UIButton){
        RippleEffect().addRippleEffect(to: sender, completion: {})
        
        self.chartView.clearData()
        
        if self.data.count > 0{
            switch self.currentChartStatus {
            case .both:
                self.currentChartStatus  = .pre
                addPreMood()
                
                self.updateLabels(pre: true, post: false)
                
            case .pre:
                self.currentChartStatus = .post
                addPostMood()
                
                self.updateLabels(pre: false, post: true)
            case .post:
                self.currentChartStatus = .both
                self.addBoth()
                
                self.updateLabels(pre: true, post: true)
                
            default:
                break
            }
            
            self.chartView.refresh()
            pageControl.currentPage = self.currentChartStatus.rawValue

        }else{
            print("no graph data....")
        }
    }
    
    func addPreMood(){
        //add pre data
        let preData = self.data.map({$0.pre})
        let data = chartView.getPreMood(dataPoints: preData.compactMap({$0.id.moodType.getChartId()}), value: self.data.compactMap({$0.date.day}))
        data.drawCircleHoleEnabled = true
        let colors = preData.compactMap({$0.id.moodType.getChartId()}).compactMap({LineChartFormatter().getStrip(for: Double($0))})
        print("precolor... \(colors)")
        
        data.circleColors = colors
        data.circleHoleRadius = data.circleRadius - 1
        data.circleHoleColor = UIColor.white
        data.invertColors = true
        self.chartView.update(pre: data)
        
    }
    
    func addPostMood(){
        //add post data
        let postData = self.data.map({$0.post})
        let posdata = chartView.getPostMood(dataPoints: postData.compactMap({$0.id.moodType.getChartId()}), value: self.data.compactMap({$0.date.day}))
        
        posdata.drawCircleHoleEnabled = true
        let colors = postData.compactMap({$0.id.moodType.getChartId()}).compactMap({LineChartFormatter().getStrip(for: Double($0))})
        posdata.circleColors = colors
        posdata.circleHoleRadius = posdata.circleRadius - 1
        posdata.circleHoleColor = UIColor.white
        posdata.invertColors = false
        self.chartView.update(post: posdata)
    }
    
    func updateLabels(pre: Bool, post: Bool){
        
        switch (pre,post) {
        case (true, true):
            UIView.animate(withDuration: 1.0) {
                self.preLabel.superview?.isHidden = false
            }
        case (true, false):
            
            UIView.animate(withDuration: 1.0) {
                self.postLabel.superview?.isHidden = true
            }
            
        case (false, true):
            UIView.animate(withDuration: 0.5) {
                self.postLabel.superview?.isHidden = false
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.allowAnimatedContent], animations: {
                self.preLabel.superview?.isHidden = true
            }, completion: nil)
        default:
            break
        }
    }
    
    func addBoth(){
        
        let postData = self.data.map({$0.post})
        let posdata = chartView.getPostMood(dataPoints: postData.compactMap({$0.id.moodType.getChartId()}), value: self.data.compactMap({$0.date.day}))
        
        
        let preData = self.data.map({$0.pre})
        let prdata = chartView.getPreMood(dataPoints: preData.compactMap({$0.id.moodType.getChartId()}), value: self.data.compactMap({$0.date.day}))
        
        self.chartView.update(pre: prdata, post: posdata)
    }
    
    @IBAction func overviewClicked(_ sender: UIButton) {
        
        if self.overView.isHidden {
            //no ripple effect required.
            return
        }
        
        RippleEffect().addRippleEffect(to: sender, completion: {
            self.overView.isHidden = true
        })
        self.chartView.resetView()
    }
    
    
    enum ChartStatus: Int{
        case both, pre, post
    }
}


extension WWMMyProgressMoodVC: CustomChartViewDelegate{
    func yAxis(movedTo x: CGFloat) {
        self.leadingMonth.constant = x
        self.overviewLeading.constant = x - 10
    }
    
    func selected(index: Int, dataSet: Int) {
        //show overview
        self.overView.isHidden = false
    }
}

