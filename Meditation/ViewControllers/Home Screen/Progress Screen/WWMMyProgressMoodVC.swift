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
import WebKit

class WWMMyProgressMoodVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{


    @IBOutlet weak var btnChangeDuration: UIButton!
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
    
    @IBOutlet weak var tblMoodProgress: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        //print(days1)
        //print(months1)

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
       //return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPieChart") as! WWMProgressMoodPieTVC
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
//        }else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CellGraphChart") as! WWMProgressMoodPieTVC
//            let urlRequest = URLRequest.init(url: URL.init(string: "https://staging.beejameditation.com/web-views/graph/index.html")!)
//            cell.graphWebView.load(urlRequest)
//
//            return cell
//        }
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
                
                //cell.viewCircle4.rate = CGFloat((Double(dic.mood))/10)//(dic.mood as! CGFloat)/10
                cell.lblPercentage1.text = "\(dic.mood)%"
                cell.viewCircle4.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
            }else if dic.quad_number == 2 {
                //cell.viewCircle3.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle3.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
                cell.lblPercentage2.text = "\(dic.mood)%"
            }else if dic.quad_number == 4 {
                //cell.viewCircle2.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle2.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in}
                cell.lblPercentage3.text = "\(dic.mood)%"
            }else if dic.quad_number == 3 {
               // cell.viewCircle1.rate = CGFloat((Double(dic.mood))/10)
                cell.viewCircle1.animateRate(1, newValue: CGFloat((Double(dic.mood))/10)) { (Bool) in
                    
                }
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
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        let xData = dateFormatter.string(from: currentDate)
        print(xData)
        
        let param = ["user_id":self.appPreference.getUserID(),"med_type" : self.appPreference.getType(), "date": xData, "type": self.type]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MOODPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                
                
                if let statsData = result["result"] as? [String:Any] {
                    
                    print(statsData)
                    
                    if self.type == "weekly"{
                        self.btnChangeDuration.setTitle("Last 7 Days", for: .normal)
                    }else if self.type == "monthly"{
                        self.btnChangeDuration.setTitle("Last month", for: .normal)
                    }else{
                        self.btnChangeDuration.setTitle("Year", for: .normal)
                    }
                    self.moodProgressData = WWMMoodProgressData.init(json: statsData)
                    
                    
                    print(print(self.moodProgressData.color_score.pre))
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
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }


}

//extension WWMMyProgressMoodVC: IAxisValueFormatter {
//
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return months[Int(value)]
//    }
//}
