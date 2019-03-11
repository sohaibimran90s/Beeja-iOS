//
//  WWMMyProgressStatsVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressStatsVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    
    
    @IBOutlet weak var lblMonthYear: UILabel!
    @IBOutlet weak var btnPreviousMonth: UIButton!
    @IBOutlet weak var btnNextMonth: UIButton!
    
    @IBOutlet weak var collectionViewCal: UICollectionView!
    @IBOutlet weak var viewHourMeditate: UIView!
    @IBOutlet weak var lblMeditate: UILabel!
    @IBOutlet weak var lblNameMeditate: UILabel!
    
    @IBOutlet weak var lblAvMinutes: UILabel!
    @IBOutlet weak var lblDailyfrequency: UILabel!
    @IBOutlet weak var lblAvSession: UILabel!
    @IBOutlet weak var lblValueSession: UILabel!
    @IBOutlet weak var lblValueDays: UILabel!
    @IBOutlet weak var lblLongestSession: UILabel!
    @IBOutlet weak var viewAvMinutes: UIView!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var viewSomeGoals: UIView!
    var statsData = WWMSatsProgressData()
    var dayAdded = -1
    var monthValue = 0
    var strMonthYear = ""
    
    var hour1:Int = 0
    var minutes1:Int = 0
    var seconds1:Int = 0
    
    var hour2:Int = 0
    var minutes2:Int = 0
    var seconds2:Int = 0
    
    var strDateTime = ""
    var addSessionView = WWMAddSessionView()
    
    var pickerView = UIPickerView()
    var settingData = DBSettings()
    
    var selectedMeditationId = -1
    var selectedLevelId = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            let meditationData = settingData.meditationData!.array as? [DBMeditationData]
            for dic in meditationData!{
                if dic.isMeditationSelected {
                    self.selectedMeditationId = Int(dic.meditationId)
                    let levels = dic.levels?.array as? [DBLevelData]
                    for level in levels! {
                        if level.isLevelSelected {
                            self.selectedLevelId = Int(level.levelId)
                        }
                    }
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpUI()
    }
    
    func setUpUI() {
        self.updateDate(date: Date())
        DispatchQueue.main.async {
            self.viewDays.layer.borderWidth = 2.0
            self.viewDays.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            self.viewAvMinutes.layer.borderWidth = 2.0
            self.viewAvMinutes.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            self.viewSomeGoals.layer.borderWidth = 2.0
            self.viewSomeGoals.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            self.viewHourMeditate.layer.borderWidth = 2.0
            self.viewHourMeditate.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        }
        
    }
    
    func updateDate(date : Date) {
        if self.monthValue == 0 {
            self.btnNextMonth.isHidden = true
        }else {
            self.btnNextMonth.isHidden = false
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMM, yyyy"
        self.lblMonthYear.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: date)
        let firstDate = self.makeDate(year: Int(year)!, month: Int(month)!, day: 1, hr: 8, min: 30, sec: 30)
        let weekDay = Calendar.current.ordinality(of: .day, in: .weekOfMonth, for: firstDate)
        dayAdded = weekDay!-2
        
        self.getStatsData()
    }
    
    func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }
    
    
    // MARK:- UIPicker View Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1,2:
            return 60
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) hours"
        case 1:
            return "\(row) min"
        case 2:
            return "\(row) sec"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if pickerView.tag == 1 {
               hour1 = row
               addSessionView.lblHrs.text = "\(hour1) hrs"
            }else {
                hour2 = row
                addSessionView.lblHrs.text = "\(hour2) hrs"
            }
            
        case 1:
            if pickerView.tag == 1 {
                minutes1 = row
                addSessionView.lblMin.text = "\(minutes1) min"
            }else {
                minutes2 = row
                addSessionView.lblMin.text = "\(minutes2) min"
            }
            
        case 2:
            if pickerView.tag == 1 {
                seconds1 = row
                addSessionView.lblSec.text = "\(seconds1) sec"
            }else {
                seconds2 = row
                addSessionView.lblSec.text = "\(seconds2) sec"
            }
        default:
            break;
        }
    }


    
    
    
    
    // MARK:- Button Action
    
    @IBAction func btnAddSessionAction(_ sender: Any) {
        addSessionView = UINib(nibName: "WWMAddSessionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAddSessionView
        let window = UIApplication.shared.keyWindow!
        
        addSessionView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        addSessionView.btnDone.layer.borderWidth = 2.0
        addSessionView.btnDone.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        addSessionView.btnTime1.layer.borderWidth = 2.0
        addSessionView.btnTime1.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        addSessionView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        addSessionView.btnDate.addTarget(self, action: #selector(btnDateAction(_:)), for: .touchUpInside)
        
        addSessionView.btnTimer.addTarget(self, action: #selector(btnTimerAction(_:)), for: .touchUpInside)
        addSessionView.btnTime1.addTarget(self, action: #selector(btnTime1Action(_:)), for: .touchUpInside)
        addSessionView.btnTime2.addTarget(self, action: #selector(btnTime2Action(_:)), for: .touchUpInside)
        
         addSessionView.btnDone.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        
        self.pickerView.tag = 1
        addSessionView.txtViewDate.isUserInteractionEnabled = false
        seconds1 = 0
        minutes1 = 0
        hour1 = 0
        seconds2 = 0
        minutes2 = 0
        hour2 = 0
        strDateTime = ""
        addSessionView.lblSec.text = "\(seconds1) sec"
        addSessionView.lblMin.text = "\(minutes1) min"
        addSessionView.lblHrs.text = "\(hour1) hrs"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale.init(identifier: "")
        addSessionView.txtViewDate.text = dateFormatter.string(from: Date())
        strDateTime = "\(Int(Date().timeIntervalSince1970*1000))"
        window.rootViewController?.view.addSubview(addSessionView)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        addSessionView.txtViewDate.isUserInteractionEnabled = false
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        sender.timeZone = TimeZone(abbreviation: "GMT")
        sender.datePickerMode = .dateAndTime
        dateFormatter.dateFormat = "dd MMM yyyy"
        if sender.tag == 1 {
            addSessionView.txtViewDate.text = dateFormatter.string(from: sender.date)
            self.strDateTime = "\(Int(sender.date.timeIntervalSince1970))"
        }
        
    }
    
    @IBAction func btnDateAction(_ sender: Any) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        addSessionView.txtViewDate.isUserInteractionEnabled = true
        addSessionView.txtViewDate.inputView = datePickerView
        addSessionView.txtViewDate.becomeFirstResponder()
        datePickerView.tag = 1
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @IBAction func btnTimerAction(_ sender: Any) {
        
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        addSessionView.txtViewTime.inputView = pickerView
        addSessionView.txtViewTime.becomeFirstResponder()
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        addSessionView.removeFromSuperview()
    }
    
    @IBAction func btnTime1Action(_ sender: Any) {
        addSessionView.btnTime2.layer.borderWidth = 2.0
        addSessionView.btnTime2.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        addSessionView.btnTime2.setTitleColor(UIColor.white, for: .normal)
        addSessionView.btnTime2.backgroundColor = UIColor.clear
        addSessionView.btnTime1.backgroundColor = UIColor.init(hexString: "#00eba9")!
        addSessionView.btnTime1.setTitleColor(UIColor.black, for: .normal)
        self.pickerView.tag = 1
        addSessionView.lblSec.text = "\(seconds1) sec"
        addSessionView.lblMin.text = "\(minutes1) min"
        addSessionView.lblHrs.text = "\(hour1) hrs"
    }
    
    @IBAction func btnTime2Action(_ sender: Any) {
        addSessionView.btnTime1.layer.borderWidth = 2.0
        addSessionView.btnTime1.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        addSessionView.btnTime1.setTitleColor(UIColor.white, for: .normal)
        addSessionView.btnTime1.backgroundColor = UIColor.clear
        addSessionView.btnTime2.backgroundColor = UIColor.init(hexString: "#00eba9")!
        addSessionView.btnTime2.setTitleColor(UIColor.black, for: .normal)
        self.pickerView.tag = 2
        addSessionView.lblSec.text = "\(seconds2) sec"
        addSessionView.lblMin.text = "\(minutes2) min"
        addSessionView.lblHrs.text = "\(hour2) hrs"
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let meditationTime1 = hour1*3600 + minutes1*60 + seconds1
        let meditationTime2 = hour2*3600 + minutes2*60 + seconds2
        
        let param = ["user_id":self.appPreference.getUserID(),
                     "meditation_id":self.selectedMeditationId,
                     "level_id":self.selectedLevelId,
                     "dateTime":strDateTime,
                     "prepTime1":"0",
                     "meditationTime1":"\(meditationTime1)",
                     "restTime1":"0",
                     "prepTime2":"0",
                     "meditationTime2":"\(meditationTime2)",
                     "restTime2":"0"
            ] as [String : Any]
        
        self.addSessionAPI(param: param)
    }
    
    
    @IBAction func btnLeftAction(_ sender: Any) {
        
    }
    @IBAction func btnRightAction(_ sender: Any) {
        
    }
    @IBAction func btnNextMonthAction(_ sender: Any) {
        monthValue = monthValue+1
         let nextMonth = Calendar.current.date(byAdding: .month, value: monthValue, to: Date())
        self.updateDate(date: nextMonth!)
    }
    
    @IBAction func btnPreviousMonthAction(_ sender: Any) {
        monthValue = monthValue-1
        let previousMonth = Calendar.current.date(byAdding: .month, value: monthValue, to: Date())
        self.updateDate(date: previousMonth!)
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statsData.consecutive_days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = statsData.consecutive_days[indexPath.row]
        if data.date == ""{
            let blankCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlankCell", for: indexPath)
            return blankCell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMStatsCalCollectionViewCell
        //cell.viewDateCircle.layer.cornerRadius = cell.viewDateCircle.frame.size.width/2
        cell.imgViewLeft.isHidden = true
        cell.imgViewRight.isHidden = true
        cell.viewDateCircle.backgroundColor = UIColor.clear
        cell.viewDateCircle.layer.borderColor = UIColor.clear.cgColor
        cell.lblDate.textColor = UIColor.white
        if (data.meditation_status == 1 && data.meditation_status2 == 1) || (data.meditation_status == 1 && data.meditation_status2 == -1){
            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
            cell.lblDate.textColor = UIColor.black
        }else if (data.meditation_status == 0 && data.meditation_status2 == 0) {
            cell.viewDateCircle.backgroundColor = UIColor.clear
            cell.viewDateCircle.layer.borderColor = UIColor.clear.cgColor
        }else {
            cell.viewDateCircle.layer.borderWidth = 2.0
            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        }
        
        
        if indexPath.row == dayAdded {
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row+1].meditation_status == 0 && statsData.consecutive_days[indexPath.row+1].meditation_status2 == 0) {
                cell.imgViewRight.isHidden = false
            }
        }else if indexPath.row == self.statsData.consecutive_days.count-1 {
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row-1].meditation_status == 0 && statsData.consecutive_days[indexPath.row-1].meditation_status2 == 0) {
                cell.imgViewLeft.isHidden = false
            }
        }else {
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row-1].meditation_status == 0 && statsData.consecutive_days[indexPath.row-1].meditation_status2 == 0) {
                cell.imgViewLeft.isHidden = false
            }
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row+1].meditation_status == 0 && statsData.consecutive_days[indexPath.row+1].meditation_status2 == 0) {
                cell.imgViewRight.isHidden = false
            }
        }
        
//        if indexPath.row-dayAdded > 0 {
//            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row-dayAdded+1].meditation_status == 0 && statsData.consecutive_days[indexPath.row-dayAdded+1].meditation_status2 == 0) {
//                cell.imgViewRight.isHidden = false
//            }
//        }else if indexPath.row-dayAdded == self.statsData.consecutive_days.count-1 {
//            if !(data.meditation_status == 0 && data.meditation_status2 == 0) {
//                cell.imgViewRight.isHidden = false
//            }
//        }else {
//
//        }
        
        
        
        
        
        
        
//        if data.meditationStatus == 0  {
//
//        }else if data.meditationStatus == 1 {
//            cell.viewDateCircle.layer.borderWidth = 2.0
//            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//
//        }else if data.meditationStatus == 2 {
//            cell.viewDateCircle.layer.borderWidth = 2.0
//            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//
//        }else if data.meditationStatus == 3 {
//            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
//        }
//
//        if indexPath.row-dayAdded > 0 {
//            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row-1].meditationStatus == 3 {
//                cell.imgViewLeft.isHidden = false
//                cell.imgViewLeft.image = UIImage.init(named: "doubleLineLeft")
//            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row-1].meditationStatus == 0 {
//                cell.imgViewLeft.isHidden = true
//            }else {
//                cell.imgViewLeft.isHidden = false
//                cell.imgViewLeft.image = UIImage.init(named: "singleLineLeft")
//                // Single
//            }
//        }
//
//
//        if indexPath.row < statsData.consecutiveDays.count-1 {
//            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row+1].meditationStatus == 3 {
//                cell.imgViewRight.isHidden = false
//                cell.imgViewRight.image = UIImage.init(named: "doubleLineRight")
//            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row+1].meditationStatus == 0 {
//                cell.imgViewRight.isHidden = true
//            }else {
//                cell.imgViewRight.isHidden = false
//                cell.imgViewRight.image = UIImage.init(named: "singleLineRight")
//            }
//        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let monthDate = dateFormatter.date(from:data.date)!
        dateFormatter.dateFormat = "d"
        cell.lblDate.text = dateFormatter.string(from: monthDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-80)/7
        return CGSize.init(width: width, height: width)
    }
    
    
    func addSessionAPI(param:[String:Any]) {
        WWMHelperClass.showSVHud()
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDSESSION, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.addSessionView.removeFromSuperview()
                self.getStatsData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    
    func getStatsData() {
        WWMHelperClass.showSVHud()
        let param = ["user_id":self.appPreference.getUserID(),
                     "month":self.strMonthYear]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STATSMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["Response"] as? [String:Any] {
                    self.statsData = WWMSatsProgressData.init(json: data, dayAdded: self.dayAdded)
                }
                
                self.collectionViewCal.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }


}
