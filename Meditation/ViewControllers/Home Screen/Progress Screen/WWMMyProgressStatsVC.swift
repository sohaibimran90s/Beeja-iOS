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
    
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnAddSession: UIButton!
    @IBOutlet weak var viewAddSession: UIView!
    
    @IBOutlet weak var btnAddSessionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnAddSessionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewCal: UICollectionView!
    @IBOutlet weak var viewHourMeditate: UIView!
    @IBOutlet weak var lblMeditate: UILabel!
    @IBOutlet weak var lblNameMeditate: UILabel!
    
    @IBOutlet weak var viewBottom: UIStackView!
    @IBOutlet weak var lblAvMinutes: UILabel!
    @IBOutlet weak var lblDailyfrequency: UILabel!
    @IBOutlet weak var lblAvSession: UILabel!
    @IBOutlet weak var lblValueSession: UILabel!
    @IBOutlet weak var lblValueDays: UILabel!
    @IBOutlet weak var lblLongestSession: UILabel!
    @IBOutlet weak var viewAvMinutes: UIView!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var viewSomeGoals: UIView!
    
    let appPreffrence = WWMAppPreference()
    var statsData = WWMSatsProgressData()
    var dayAdded = 0
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
    var isLeft = false
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.appPreffrence.getType() == "timer"{
            self.btnAddSession.setTitle("Add a Session", for: .normal)
            self.btnAddSessionTopConstraint.constant = 20
            self.btnAddSessionHeightConstraint.constant = 30
            self.viewAddSession.isHidden = false
        }else if self.appPreffrence.getType() == "guided"{
            self.btnAddSession.setTitle("", for: .normal)
            self.btnAddSessionTopConstraint.constant = 0
            self.btnAddSessionHeightConstraint.constant = 0
            self.viewAddSession.isHidden = true
        }else {
           self.btnAddSession.setTitle("Add a Session", for: .normal)
            self.btnAddSessionTopConstraint.constant = 20
            self.btnAddSessionHeightConstraint.constant = 30
            self.viewAddSession.isHidden = false
        }
        
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
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateFormatter.dateFormat = "MMM yyyy"
        self.lblMonthYear.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM yyyy hh:mm:ss"
        
        let str = "01 \(dateFormatter.string(from: date))"
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss"
        let firstDate1 = dateFormatter.date(from: str)
        
        dateFormatter.dateFormat = "ee"
        let week = Int(dateFormatter.string(from: firstDate1!))!
        dayAdded = week-2
        if dayAdded < 0 {
            dayAdded = 6
        }
        
        self.getStatsData()
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
            
            self.viewHighlighted()
        case 1:
            if pickerView.tag == 1 {
                minutes1 = row
                addSessionView.lblMin.text = "\(minutes1) min"
            }else {
                minutes2 = row
                addSessionView.lblMin.text = "\(minutes2) min"
            }
            
            self.viewHighlighted()
        case 2:
            if pickerView.tag == 1 {
                seconds1 = row
                addSessionView.lblSec.text = "\(seconds1) sec"
            }else {
                seconds2 = row
                addSessionView.lblSec.text = "\(seconds2) sec"
            }
            
            self.viewHighlighted()
        default:
            break;
        }
    }


    func viewHighlighted(){
        
        if (addSessionView.lblSec.text == "0 sec" && addSessionView.lblMin.text == "0 min" && addSessionView.lblHrs.text == "0 hrs"){
            addSessionView.backViewTimer.layer.borderColor = UIColor.clear.cgColor
            addSessionView.backViewTimer.layer.borderWidth = 0.0
        }
        
        if (hour1 == 0 && minutes1 == 0 && seconds1 == 0 && hour2 == 0 && minutes2 == 0 && seconds2 == 0){
            addSessionView.btnDone.setTitleColor(UIColor(red: 64.0/255.0, green: 69.0/255.0, blue: 119.0/255.0, alpha: 1.0), for: .normal)
            addSessionView.btnDone.layer.borderWidth = 2.0
            addSessionView.btnDone.layer.borderColor = UIColor(red: 23.0/255.0, green: 66.0/255.0, blue: 92.0/255.0, alpha: 1.0).cgColor
        }else{
            addSessionView.btnDone.setTitleColor(UIColor.white, for: .normal)
            addSessionView.btnDone.layer.borderWidth = 2.0
            addSessionView.btnDone.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        }
        
        
        
        if addSessionView.lblSec.text != "0 sec"{
            addSessionView.backViewTimer.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            addSessionView.backViewTimer.layer.borderWidth = 2.0
        }
        
        if addSessionView.lblMin.text != "0 min"{
            addSessionView.backViewTimer.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            addSessionView.backViewTimer.layer.borderWidth = 2.0
        }
        
        if addSessionView.lblHrs.text != "0 hrs"{
            addSessionView.backViewTimer.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            addSessionView.backViewTimer.layer.borderWidth = 2.0
        }
    }
    

    // MARK:- Button Action
    
    @IBAction func btnAddSessionAction(_ sender: Any) {
        addSessionView = UINib(nibName: "WWMAddSessionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAddSessionView
        let window = UIApplication.shared.keyWindow!
        
        addSessionView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        addSessionView.btnDone.layer.borderWidth = 2.0
        addSessionView.btnDone.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
       // addSessionView.btnTime1.layer.borderWidth = 2.0
       // addSessionView.btnTime1.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        addSessionView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        addSessionView.btnDate.addTarget(self, action: #selector(btnDateAction(_:)), for: .touchUpInside)
        
        addSessionView.btnTimer.addTarget(self, action: #selector(btnTimerAction(_:)), for: .touchUpInside)
        addSessionView.btnTime1.addTarget(self, action: #selector(btnTime1Action(_:)), for: .touchUpInside)
        addSessionView.btnTime2.addTarget(self, action: #selector(btnTime2Action(_:)), for: .touchUpInside)
        
         addSessionView.btnDone.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        
        
        
        addSessionView.viewTime.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        addSessionView.viewTime.layer.borderWidth = 2.0
        
        self.roundCorners(view: addSessionView.btnTime1, corners: [.bottomLeft, .topLeft], radius: 20.0)
        self.roundCorners(view: addSessionView.btnTime2, corners: [.bottomRight, .topRight], radius: 20.0)
        
        // 0 235 169
      //  addSessionView.btnTime1.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
       // addSessionView.btnTime1.layer.borderWidth = 1.0
        
      //  addSessionView.btnTime2.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
     //   addSessionView.btnTime2.layer.borderWidth = 1.0
        
        
        
        //addSessionView.btnTime2.layer.borderWidth = 2.0
        //addSessionView.btnTime2.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        addSessionView.btnTime2.setTitleColor(UIColor.white, for: .normal)
        addSessionView.btnTime2.backgroundColor = UIColor.clear
        addSessionView.btnTime1.backgroundColor = UIColor.init(hexString: "#00eba9")!
        addSessionView.btnTime1.setTitleColor(UIColor.black, for: .normal)
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
        
        self.viewHighlighted()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = NSLocale.current
        addSessionView.txtViewDate.text = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let strDate = dateFormatter.string(from: Date())
        let date = dateFormatter.date(from: strDate)
        strDateTime = "\(Int(date!.timeIntervalSince1970)*1000)"
        window.rootViewController?.view.addSubview(addSessionView)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        //addSessionView.txtViewDate.isUserInteractionEnabled = false
        let dateFormatter = DateFormatter()
        
        print("pickerView.date.convertedDate..... \(sender.date.convertedDate)")
        print("sender.date.... \(sender.date)")
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = NSLocale.current
        addSessionView.txtViewDate.text = dateFormatter.string(from: sender.date.convertedDate)
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let strDate = dateFormatter.string(from: sender.date.convertedDate)
        let date = dateFormatter.date(from: strDate)
        self.strDateTime = "\(Int(date!.timeIntervalSince1970)*1000)"
    }
    
    @IBAction func btnDateAction(_ sender: Any) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.locale = NSLocale.current
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
        addSessionView.btnTime2.setTitleColor(UIColor.white, for: .normal)
        addSessionView.btnTime2.backgroundColor = UIColor.clear
        addSessionView.btnTime1.backgroundColor = UIColor.init(hexString: "#00eba9")!
        addSessionView.btnTime1.setTitleColor(UIColor.black, for: .normal)
        self.pickerView.tag = 1
        addSessionView.lblSec.text = "\(seconds1) sec"
        addSessionView.lblMin.text = "\(minutes1) min"
        addSessionView.lblHrs.text = "\(hour1) hrs"
        
        self.viewHighlighted()
    }
    
    @IBAction func btnTime2Action(_ sender: Any) {
        addSessionView.btnTime1.setTitleColor(UIColor.white, for: .normal)
        addSessionView.btnTime1.backgroundColor = UIColor.clear
        addSessionView.btnTime2.backgroundColor = UIColor.init(hexString: "#00eba9")!
        addSessionView.btnTime2.setTitleColor(UIColor.black, for: .normal)
        self.pickerView.tag = 2
        addSessionView.lblSec.text = "\(seconds2) sec"
        addSessionView.lblMin.text = "\(minutes2) min"
        addSessionView.lblHrs.text = "\(hour2) hrs"
        
        self.viewHighlighted()
    }
    
    
    func roundCorners(view :UIButton, corners: UIRectCorner, radius: CGFloat){
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let meditationTime1 = hour1*3600 + minutes1*60 + seconds1
        let meditationTime2 = hour2*3600 + minutes2*60 + seconds2
        
        let param = ["user_id":self.appPreference.getUserID(),
                     "meditation_id":self.selectedMeditationId,
                     "level_id":self.selectedLevelId,
                     "dateTime":strDateTime,
                     "prepTime1":"0",
                     "meditationTime1":meditationTime1,
                     "restTime1":"0",
                     "prepTime2":"0",
                     "meditationTime2":meditationTime2,
                     "restTime2":"0"
            ] as [String : Any]
        
        self.addSessionAPI(param: param)
    }
    
    
    @IBAction func btnLeftAction(_ sender: Any) {
        self.isLeft = false
        self.setData()
    }
    @IBAction func btnRightAction(_ sender: Any) {
        self.isLeft = true
        self.setData()
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
                if let success = result["success"] as? Bool {
                    if success {
                        self.addSessionView.removeFromSuperview()
                        self.getStatsData()
                    }else {
                        WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                    }
                }
            }else {
                self.saveSessionDatatoDB(param: param)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    func saveSessionDatatoDB(param:[String:Any]) {
        let dbJournal = WWMHelperClass.fetchEntity(dbName: "DBAddSession") as! DBAddSession
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbJournal.addSession = myString
        WWMHelperClass.saveDb()
        self.addSessionView.removeFromSuperview()
        WWMHelperClass.showPopupAlertController(sender: self, message: Validatation_JournalOfflineMsg, title: kAlertTitle)
    }
    
    
    
    
    func setData() {
        if isLeft {
            self.btnLeft.isHidden = false
            self.btnRight.isHidden = true
            self.lblMeditate.text = "\(self.statsData.weekly_session ?? "")"
            self.lblValueSession.text = "\(self.statsData.avg_session ?? "")"
            self.lblValueDays.text = "\(self.statsData.longest_session ?? "")"
            self.lblNameMeditate.text = "Weekly Session"
            self.lblAvSession.text = "Av. Session"
            self.lblLongestSession.text = "Longest Session"
            self.viewBottom.isHidden = false
            if let meditationData = self.settingData.meditationData?.array as?  [DBMeditationData] {
                for data in meditationData {
                    if data.isMeditationSelected {
                        if data.meditationName == "Beeja" || data.meditationName == "Vedic/Transcendental" {
                            self.viewBottom.isHidden = true
                        }
                    }
                }
            }
        }else {
            self.btnLeft.isHidden = true
            self.btnRight.isHidden = false
            self.viewBottom.isHidden = false
            self.lblNameMeditate.text = "Hours Meditated"
            self.lblAvSession.text = "Total Sessions"
            self.lblLongestSession.text = "Consecutive Days"
            self.lblMeditate.text = "\(self.statsData.hours_of_meditate ?? "")"
            self.lblValueSession.text = "\(self.statsData.total_Session ?? "")"
            self.lblValueDays.text = "\(self.statsData.cons_days ?? "")"
        }
    }
    
    func getStatsData() {
        WWMHelperClass.showSVHud()
        let param = ["user_id":self.appPreference.getUserID(),
                     "med_type" : self.appPreference.getType(),
                     "month":self.strMonthYear]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STATSMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["Response"] as? [String:Any] {
                    self.statsData = WWMSatsProgressData.init(json: data, dayAdded: self.dayAdded)
                   
                }
                self.isLeft = false
                self.setData()
                self.collectionViewCal.reloadData()
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
}


extension Date {
    
    var convertedDate: Date {
        
        let dateFormatter = DateFormatter();
        
        let dateFormat = "dd MMM yyyy";
        dateFormatter.dateFormat = dateFormat;
        let formattedDate = dateFormatter.string(from: self);
        
        dateFormatter.locale = NSLocale.current;
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00");
        
        dateFormatter.dateFormat = dateFormat as String;
        let sourceDate = dateFormatter.date(from: formattedDate as String);
        
        return sourceDate!
    }
}
