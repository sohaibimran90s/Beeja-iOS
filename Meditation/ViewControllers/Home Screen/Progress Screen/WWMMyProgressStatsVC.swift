//
//  WWMMyProgressStatsVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import UICircularProgressRing
import EFCountingLabel
import XLPagerTabStrip

class WWMMyProgressStatsVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPickerViewDelegate,UIPickerViewDataSource,AVAudioPlayerDelegate {
    
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
    @IBOutlet weak var collectionView21Chall: UICollectionView!
    @IBOutlet weak var viewHourMeditate: UICircularProgressRing!
    @IBOutlet weak var lblMeditate: EFCountingLabel!
    @IBOutlet weak var lblNameMeditate: UILabel!
    @IBOutlet weak var viewBottom: UIStackView!
    @IBOutlet weak var lblAvSession: UILabel!
    @IBOutlet weak var lblValueSession: EFCountingLabel!
    @IBOutlet weak var lblValueDays: EFCountingLabel!
    @IBOutlet weak var lblLongestSession: UILabel!
    @IBOutlet weak var viewAvMinutes: UICircularProgressRing!
    @IBOutlet weak var viewDays: UICircularProgressRing!
    @IBOutlet weak var viewSomeGoals: UIView!
    @IBOutlet weak var view8Week: UIView!
    @IBOutlet weak var lbl8Count: UILabel!
    @IBOutlet weak var view21Header: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calenderHegihtConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeCalHC: NSLayoutConstraint!
    
    let appPreffrence = WWMAppPreference()
    var statsData = WWMSatsProgressData()
    var WWMProgress21DaysChallengeData: [WWMSatsProgress21DaysChallengeData] = []
    var milestoneData = WWMMilestoneData()
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
    var alertNotificationView = WWMMilestonePopUp()
    
    var pickerView = UIPickerView()
    var settingData = DBSettings()
    
    var selectedMeditationId = -1
    var selectedLevelId = -1
    var isLeft = false
    var circle = true
    
    var player:  AVAudioPlayer?
    let reachable = Reachabilities()
    
    //challenge21Progress
    @IBOutlet weak var viewSuperChallenge21Days: UIView!
    @IBOutlet weak var imgBg21Days: UIImageView!
    @IBOutlet weak var constraintSuperView21Days: NSLayoutConstraint!
    @IBOutlet weak var viewChallenge21Days: UIView!
    @IBOutlet weak var viewChallenge21DaysHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnChallenge21Days: UIButton!
    @IBOutlet weak var calenderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPracLine: UILabel!
    @IBOutlet weak var lblSpiriLine: UILabel!
    @IBOutlet weak var stackViewPraSpiritual: UIStackView!
    @IBOutlet weak var constraint21DaysHeader: NSLayoutConstraint!
    @IBOutlet weak var lbl21DaysTitle: UILabel!

    var challType = "Practical"
    var itemInfo: IndicatorInfo = "View"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .background).async {
            self.syncAddJournalData()
            self.getGuidedListAPI()
            self.getLearnAPI()
        }
        
        if self.challType == "Practical"{
            self.lblPracLine.isHidden = false
            self.lblSpiriLine.isHidden = true
        }else{
            self.lblPracLine.isHidden = true
            self.lblSpiriLine.isHidden = false
        }
        
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS_MILESTONES_GRAPH", itemId: "VIEWED", itemName: "")
        self.viewHourMeditate.value = 0
        self.viewAvMinutes.value = 0
        self.viewDays.value = 0
        
        self.notificationPopUpCall()
    }
    
    func syncAddJournalData() {
        let data = WWMHelperClass.fetchDB(dbName: "DBJournalData") as! [DBJournalData]
        if data.count > 0 {
            var arrData = [[String:Any]]()
            for dict in data {
                if let jsonResult = self.convertToDictionary1(text: dict.journalData ?? "") {
                    arrData.append(jsonResult)
                }
            }
            let param = ["offline_data":arrData]
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, context: "AppDelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    WWMHelperClass.deletefromDb(dbName: "DBJournalData")
                }
            }
        }
    }
    
    func notificationPopUpCall(){
        if WWMHelperClass.milestoneType == "hours_meditate"{
            self.notificationPopUp(titles: "1 Hour Meditated", titleDescript: "You have just completed a Hours Meditated Milestone", textNextMileStone: "1 more hour needed!", imgLogo: "hour", imgLogo1: "hour1", redC: 0, greenC: 255, blueC: 215)
        }else if WWMHelperClass.milestoneType == "consecutive_days"{
            self.notificationPopUp(titles: "2 Day Streak", titleDescript: "You have just completed two days in a row", textNextMileStone: "3 Day Streak", imgLogo: "consecutive_days", imgLogo1: "consecutive_days1", redC: 255, greenC: 151, blueC: 89)
        }else if WWMHelperClass.milestoneType == "sessions"{
            self.notificationPopUp(titles: "Meditated Twice in 1 Day", titleDescript: "You have just meditated twice in one day", textNextMileStone: "Meditate Twice a Day for a Week", imgLogo: "session", imgLogo1: "session1", redC: 177, greenC: 56, blueC: 211)
        }
        
        KNOTIFICATIONCENTER.addObserver(self, selector: #selector(self.notificationProgressMoodMeter(notification:)), name: Notification.Name("notificationProgressMoodMeter"), object: nil)
    }
    
    @objc func notificationProgressMoodMeter(notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView21Chall.reloadData()
            self.collectionViewCal.reloadData()
        }
        KNOTIFICATIONCENTER.removeObserver(self, name: Notification.Name("notificationProgressMoodMeter"), object: nil)
    }
    
    func notificationPopUp(titles: String, titleDescript: String, textNextMileStone: String, imgLogo: String, imgLogo1: String, redC: CGFloat, greenC: CGFloat, blueC: CGFloat) {
        
        self.playSound(name: "MM_BEEJA_MEDITATION_COMPLETE_V1")
        alertNotificationView = UINib(nibName: "WWMMilestonePopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMMilestonePopUp
        let window = UIApplication.shared.keyWindow!
        
        alertNotificationView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertNotificationView.lblHourMeditated.text = titles
        alertNotificationView.lblHourDescript.text = titleDescript
        alertNotificationView.lblNextMileText.text = textNextMileStone
        alertNotificationView.lblCongrats.textColor = UIColor.init(red: redC/255.0, green: greenC/255.0, blue: blueC/255.0, alpha: 1.0)
        alertNotificationView.imgViewLogo.image = UIImage(named: imgLogo)
        alertNotificationView.imgViewLogo1.image = UIImage(named: imgLogo1)
        alertNotificationView.btnDismiss.addTarget(self, action: #selector(btnDissmissPopUp), for: .touchUpInside)
        WWMHelperClass.milestoneType = ""
        window.rootViewController?.view.addSubview(alertNotificationView)
    }
    
    @objc func btnDissmissPopUp(){
        WWMHelperClass.milestoneType = ""
        self.player?.stop()
        alertNotificationView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //to check if progrss of challenges have to show or not
        self.btnChallenge21Days.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnChallenge21Days.layer.borderWidth = 2
        
        //check weather 30 days or not
        if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
            self.stackViewPraSpiritual.isHidden = true
            self.constraint21DaysHeader.constant = 0
            self.lbl21DaysTitle.text = ""
            self.viewChallenge21Days.isHidden = false
            self.viewChallenge21DaysHeightConstraint.constant = 0
            self.btnChallenge21Days.isHidden = false
            self.viewSuperChallenge21Days.isHidden = false
            self.constraintSuperView21Days.constant = 0
            self.challengeCalHC.constant = 0
            self.lblPracLine.isHidden = true
            self.lblSpiriLine.isHidden = true
        }else{
            self.viewChallenge21Days.isHidden = true
            self.viewChallenge21DaysHeightConstraint.constant = 0
            self.btnChallenge21Days.isHidden = true
            self.viewSuperChallenge21Days.isHidden = true
            self.constraintSuperView21Days.constant = 0
            self.calenderTopConstraint.constant = 0
            self.stackViewPraSpiritual.isHidden = false
            self.constraint21DaysHeader.constant = 110
            self.lbl21DaysTitle.text = "21 Days meditation Challenge"
        }
        
        self.view8Week.isHidden = true
        self.viewHourMeditate.maxValue = 100
        self.viewAvMinutes.maxValue = 100
        self.viewDays.maxValue = 100
        
        scrollView.setContentOffset(.zero, animated: true)
        self.setUpNavigationBarForDashboard(title: "My Progress")
        
        //print("self.appPreffrence.getType().... \(self.appPreffrence.getType())")
        
        if self.appPreffrence.getType() == "timer"{
            self.btnAddSession.setTitle("Add a Session", for: .normal)
            self.btnAddSessionTopConstraint.constant = 20
            self.btnAddSessionHeightConstraint.constant = 30
            self.viewAddSession.isHidden = false
        }else if self.appPreffrence.getType() == "learn"{
            self.btnAddSession.setTitle("", for: .normal)
            self.btnAddSessionTopConstraint.constant = 0
            self.btnAddSessionHeightConstraint.constant = 0
            self.viewAddSession.isHidden = true
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
            
            self.viewSomeGoals.layer.borderWidth = 2.0
            self.viewSomeGoals.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        }
    }
    
    @IBAction func btnPracticalClicked(_ sender: UIButton){
        self.challType = "Practical"
        self.lblSpiriLine.isHidden = true
        self.lblPracLine.isHidden = false
        DispatchQueue.main.async {
            self.collectionView21Chall.reloadData()
        }
    }
    
    @IBAction func btnSpiritualClicked(_ sender: UIButton){
        self.challType = "Spiritual"
        self.lblSpiriLine.isHidden = false
        self.lblPracLine.isHidden = true
        DispatchQueue.main.async {
            self.collectionView21Chall.reloadData()
        }
    }
    
    @IBAction func btn21TodaysChallClicked(_ sender: UIButton){
        if self.appPreference.getType() == "learn"{
            self.appPreference.set21ChallengeName(value: "30 Day Challenge")
            self.appPreference.setType(value: "learn")
        }
        else{
            self.appPreference.set21ChallengeName(value: "21 Days challenge")
            self.appPreffrence.setType(value: "guided")
        }
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @IBAction func btn8WeekClicked(_ sender: UIButton){
        self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
        self.appPreference.setType(value: "learn")
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func navigateToDashboard() {
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 1
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 1 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func updateDate(date : Date) {
        if self.monthValue == 0 {
            self.btnNextMonth.isHidden = true
        }else {
            self.btnNextMonth.isHidden = false
        }
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
        dateFormatter.dateFormat = "MMM yyyy"
        self.lblMonthYear.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM yyyy"
        
        let str = "01 \(dateFormatter.string(from: date))"
        dateFormatter.dateFormat = "dd MMM yyyy"
        let firstDate1 = dateFormatter.date(from: str)
        
        dateFormatter.dateFormat = "EEE"
        let weedday = dateFormatter.string(from: firstDate1!)
        switch weedday {
            
        case "Mon":
            dayAdded = 0
            break
        case "Tue":
            dayAdded = 1
            break
        case "Wed":
            dayAdded = 2
            break
        case "Thu":
            dayAdded = 3
            break
        case "Fri":
            dayAdded = 4
            break
        case "Sat":
            dayAdded = 5
            break
        case "Sun":
            dayAdded = 6
            break
        default:
            dayAdded = 0
            break
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
            return 24
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
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        addSessionView.txtViewDate.text = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        let strDate = dateFormatter.string(from: Date())
        let date = dateFormatter.date(from: strDate)
        strDateTime = "\(Int(date!.timeIntervalSince1970)*1000)"
        window.rootViewController?.view.addSubview(addSessionView)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        //addSessionView.txtViewDate.isUserInteractionEnabled = false
        let dateFormatter = DateFormatter()
        
        //print("pickerView.date.convertedDate..... \(sender.date.convertedDate) sender.date.... \(sender.date)")
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = NSLocale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        addSessionView.txtViewDate.text = dateFormatter.string(from: sender.date.convertedDate)
        
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        let strDate = dateFormatter.string(from: sender.date.convertedDate)
        let date = dateFormatter.date(from: strDate)
        self.strDateTime = "\(Int(date!.timeIntervalSince1970)*1000)"
    }
    
    @IBAction func btnDateAction(_ sender: Any) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.locale = Locale.current
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
        
        //meditationTime1.... \(meditationTime1) meditationTime2.... \(meditationTime2)")
        
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
        
        if reachable.isConnectedToNetwork() {
            self.addSessionAPI(param: param)
        }else{
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
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
        
        if collectionView == collectionView21Chall{
            if (self.appPreference.getType() == "learn" || self.appPreference.getType() == "Learn"){
                
                if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                    if self.statsData.days30Challenge.count > 0{
                        return self.statsData.days30Challenge.count
                    }else{
                        return 0
                    }
                }else{
                    return 0
                }
            }else if (self.appPreference.getType() == "guided" || self.appPreference.getType() == "Guided") && (self.statsData.days21PracticalChallenge.count != 0 || self.statsData.days21SpiritualChallenge.count != 0) {
                
                if self.challType == "Practical"{
                    return self.statsData.days21PracticalChallenge.count
                }else{
                    return self.statsData.days21SpiritualChallenge.count
                }
            }
        } else if collectionView == collectionViewCal{
            if self.statsData.consecutive_days.count > 35{
                self.calenderHegihtConstraint.constant = 330
            }else{
                self.calenderHegihtConstraint.constant = 280
            }
            
            return self.statsData.consecutive_days.count
        }else{
            return self.statsData.days21PracticalChallenge.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewCal{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMStatsCalCollectionViewCell
            
            let data = statsData.consecutive_days[indexPath.row]
            if data.date == ""{
                let blankCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlankCell", for: indexPath)
                return blankCell
            }
            
            //cell.viewDateCircle.layer.cornerRadius = cell.viewDateCircle.frame.size.width/2
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let monthDate = dateFormatter.date(from:data.date)!
            dateFormatter.dateFormat = "d"
            cell.lblDate.text = dateFormatter.string(from: monthDate)
            
            cell.viewDateCircle.alpha = 0.0
            cell.imgViewLeft.alpha = 0.0
            cell.imgViewRight.alpha = 0.0
            
            cell.imgViewLeft.isHidden = true
            cell.imgViewRight.isHidden = true
            cell.viewDateCircle.backgroundColor = UIColor.clear
            cell.viewDateCircle.layer.borderColor = UIColor.clear.cgColor
            cell.lblDate.textColor = UIColor.white
            if (data.meditation_status == 1 && data.meditation_status2 == 1) || (data.meditation_status == 1 && data.meditation_status2 == -1){
                cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
                cell.lblDate.textColor = UIColor.white
            }else if (data.meditation_status == 0 && data.meditation_status2 == 0) {
                cell.viewDateCircle.backgroundColor = UIColor.clear
                cell.viewDateCircle.layer.borderColor = UIColor.clear.cgColor
            }else {
                cell.viewDateCircle.layer.borderWidth = 2.0
                cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.1*Double(indexPath.item), options: [.curveEaseInOut], animations: {
                cell.viewDateCircle.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.viewDateCircle.alpha = 1
                cell.imgViewLeft.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.imgViewLeft.alpha = 1
                cell.imgViewRight.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.imgViewRight.alpha = 1
                
            }, completion: {
                _ in
                if (data.meditation_status == 1 && data.meditation_status2 == 1) || (data.meditation_status == 1 && data.meditation_status2 == -1){
                    cell.lblDate.textColor = UIColor.black
                }
            })
            
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
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as! WWMStatsCalCollectionViewCell
            
            if indexPath.item == 0{
                cell.imgViewLeft.isHidden = true
            }
            
            if indexPath.item == 29{
                cell.imgViewRight.isHidden = true
            }
            
            if self.appPreference.getType() == "learn" || self.appPreference.getType() == "Learn"{
                
                let data = self.statsData.days30Challenge[indexPath.row]
                cell.lblDate.text = "\(data.day_id)"
                
                if data.completed{
                    cell.lblDate.textColor = UIColor.black
                    cell.viewDateCircle.layer.borderWidth = 2.0
                    cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
                    cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                    cell.imgViewLeft.image = UIImage(named: "singleLineLeft")
                }else{
                    cell.lblDate.textColor = UIColor.white
                    cell.viewDateCircle.layer.borderWidth = 2.0
                    cell.viewDateCircle.layer.borderColor = UIColor.white.cgColor
                    cell.viewDateCircle.backgroundColor = UIColor.clear
                    cell.imgViewLeft.image = UIImage(named: "singleLineLeft1")
                    cell.imgViewRight.image = UIImage(named: "singleLineRight1")
                }
                
                if data.is_milestone{
                    cell.imgMilestone.isHidden = false
                }else{
                    cell.imgMilestone.isHidden = true
                }
                
            }else{
                var data = WWMSatsProgress21DaysChallengeData()
                
                cell.imgMilestone.isHidden = true
                if self.challType == "Practical"{
                    data = statsData.days21PracticalChallenge[indexPath.row]
                    
                    if indexPath.item == statsData.days21PracticalChallenge.count - 1{
                        cell.imgViewRight.isHidden = true
                    }
                }else{
                    data = statsData.days21SpiritualChallenge[indexPath.row]
                    
                    if indexPath.item == statsData.days21SpiritualChallenge.count - 1{
                        cell.imgViewRight.isHidden = true
                    }
                    
                    if indexPath.item == 20{
                        cell.imgViewRight.isHidden = true
                    }
                }
                
                cell.lblDate.text = "\(data.day_id)"
                
                if data.status{
                    
                    cell.lblDate.textColor = UIColor.black
                    cell.viewDateCircle.layer.borderWidth = 2.0
                    cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
                    cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                    cell.imgViewLeft.image = UIImage(named: "singleLineLeft")
                }else{
                    
                    cell.lblDate.textColor = UIColor.white
                    cell.viewDateCircle.layer.borderWidth = 2.0
                    cell.viewDateCircle.layer.borderColor = UIColor.white.cgColor
                    cell.viewDateCircle.backgroundColor = UIColor.clear
                    cell.imgViewLeft.image = UIImage(named: "singleLineLeft1")
                    cell.imgViewRight.image = UIImage(named: "singleLineRight1")
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-80)/7
        return CGSize.init(width: width, height: width)
    }
    
    func addSessionAPI(param:[String:Any]) {

        //print("add session params.... \(param)")
        addSessionView.btnDone.isUserInteractionEnabled = false
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDSESSION, context: "WWMMyProgressStatsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            self.addSessionView.btnDone.isUserInteractionEnabled = true
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
                self.addSessionView.btnDone.isUserInteractionEnabled = true
                //self.saveSessionDatatoDB(param: param)
            }
            self.addSessionView.btnDone.isUserInteractionEnabled = true
             WWMHelperClass.hideLoaderAnimate(on: self.view)
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
            
            if !self.circle{
                self.lblMeditate.text = "\(self.statsData.weekly_session ?? 0)"
                self.lblValueSession.text = "\(self.statsData.avg_session ?? 0)"
                self.lblValueDays.text = "\(self.statsData.longest_session ?? 0)"
            }
            
            self.lblNameMeditate.text = "Weekly Session"
            self.lblAvSession.text = "Av. Session"
            self.lblLongestSession.text = "Longest Session"
            self.viewBottom.isHidden = false
            if let meditationData = self.settingData.meditationData?.array as?  [DBMeditationData] {
                for data in meditationData {
                    if data.isMeditationSelected {
                        if data.meditationName == "Beeja" || data.meditationName == "Vedic/Transcendental" {
                            //self.viewBottom.isHidden = true
                            
                            self.lblAvSession.text = "Total Sessions"
                            self.lblLongestSession.text = "Consecutive Days"
                            
                            if !self.circle{
                                self.lblValueSession.text = "\(self.statsData.total_Session ?? 0)"
                                self.lblValueDays.text = "\(self.statsData.cons_days ?? 0)"
                            }
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
            
            if !self.circle{
                self.lblMeditate.text = "\(self.statsData.hours_of_meditate ?? 0)"
                self.lblValueSession.text = "\(self.statsData.total_Session ?? 0)"
                self.lblValueDays.text = "\(self.statsData.cons_days ?? 0)"
            }
        }
    }
    
    func getStatsData() {
        // WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = ["user_id":self.appPreference.getUserID(),
                     "med_type" : self.appPreference.getType(),
                     "month":self.strMonthYear]
        //print("param stats... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STATSMYPROGRESS, context: "WWMMyProgressStatsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["Response"] as? [String:Any] {
                    
                    print("data stats++++ \(data)")
                    self.statsData = WWMSatsProgressData.init(json: data, dayAdded: self.dayAdded)
                }
                self.isLeft = false
                self.setData()
                
                if self.appPreference.getType() == "guided" || self.appPreference.getType() == "Guided" && self.appPreffrence.getExpiryDate(){
                    DispatchQueue.main.async {
                        self.viewChallenge21Days.isHidden = false
                        self.viewChallenge21DaysHeightConstraint.constant = 355
                        self.btnChallenge21Days.isHidden = false
                        self.calenderTopConstraint.constant = 0
                        self.viewSuperChallenge21Days.isHidden = false
                        self.constraintSuperView21Days.constant = 485
                        self.challengeCalHC.constant = 245
                        self.collectionView21Chall.reloadData()
                    }
                }else if (self.appPreference.getType() == "learn" || self.appPreference.getType() == "Learn"){
                    
                    if self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
                        
                        if self.statsData.week8Challenge.count > 0{
                            let data = self.statsData.week8Challenge[0]
                            if data.total_complete_count > 0{
                                DispatchQueue.main.async {
                                    self.viewChallenge21Days.isHidden = true
                                    self.viewChallenge21DaysHeightConstraint.constant = 0
                                    self.btnChallenge21Days.isHidden = true
                                    self.viewSuperChallenge21Days.isHidden = false
                                    self.constraintSuperView21Days.constant = 86
                                    self.calenderTopConstraint.constant = 0
                                    self.stackViewPraSpiritual.isHidden = true
                                    self.constraint21DaysHeader.constant = 0
                                    self.lbl21DaysTitle.text = ""
                                    self.view8Week.isHidden = false
                                    self.imgBg21Days.isHidden = true
                                    
                                    var myMutableString = NSMutableAttributedString()
                                    let lblText = "8 Week Challenge: \(data.total_complete_count) days completed You're off to a great start so dive back in"
                                    myMutableString = NSMutableAttributedString(string: lblText, attributes: [NSAttributedString.Key.font:UIFont(name: "Maax-Bold", size: 13.0)!])
                                    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "#F0A367")!, range: NSRange(location:0,length:18))
                                    // set label Attribute
                                    self.lbl8Count.attributedText = myMutableString
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.viewChallenge21Days.isHidden = true
                                    self.viewChallenge21DaysHeightConstraint.constant = 0
                                    self.btnChallenge21Days.isHidden = true
                                    self.viewSuperChallenge21Days.isHidden = true
                                    self.constraintSuperView21Days.constant = 0
                                    self.calenderTopConstraint.constant = 0
                                    self.stackViewPraSpiritual.isHidden = false
                                    self.constraint21DaysHeader.constant = 110
                                    self.lbl21DaysTitle.text = ""
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.viewChallenge21Days.isHidden = true
                                self.viewChallenge21DaysHeightConstraint.constant = 0
                                self.btnChallenge21Days.isHidden = true
                                self.viewSuperChallenge21Days.isHidden = true
                                self.constraintSuperView21Days.constant = 0
                                self.calenderTopConstraint.constant = 0
                                self.stackViewPraSpiritual.isHidden = false
                                self.constraint21DaysHeader.constant = 110
                                self.lbl21DaysTitle.text = ""
                            }
                        }
                    }else if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                        if self.statsData.days30Challenge.count > 0{
                            DispatchQueue.main.async {
                                //print(self.statsData.days30Challenge.count)
                                self.stackViewPraSpiritual.isHidden = true
                                self.constraint21DaysHeader.constant = 90
                                self.lbl21DaysTitle.text = "30 Days meditation Challenge"
                                self.viewChallenge21Days.isHidden = false
                                self.viewChallenge21DaysHeightConstraint.constant = 410
                                self.btnChallenge21Days.isHidden = false
                                self.viewSuperChallenge21Days.isHidden = false
                                self.constraintSuperView21Days.constant = 520
                                self.challengeCalHC.constant = 300
                                self.lblPracLine.isHidden = true
                                self.lblSpiriLine.isHidden = true
                                self.collectionView21Chall.reloadData()
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.viewChallenge21Days.isHidden = true
                                self.viewChallenge21DaysHeightConstraint.constant = 0
                                self.btnChallenge21Days.isHidden = true
                                self.viewSuperChallenge21Days.isHidden = true
                                self.constraintSuperView21Days.constant = 0
                                self.calenderTopConstraint.constant = 0
                                self.stackViewPraSpiritual.isHidden = false
                                self.constraint21DaysHeader.constant = 110
                                self.lbl21DaysTitle.text = ""
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.view8Week.isHidden = true
                            self.imgBg21Days.isHidden = false
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.collectionViewCal.reloadData()
                }
                self.getMilestoneData()
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
                WWMHelperClass.hideLoaderAnimate(on: self.view)
            }
            
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func getMilestoneData() {
        let param = ["user_id":self.appPreference.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MILESTONE, context: "WWMMyProgressStatsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["result"] as? [String:Any] {
                    self.milestoneData = WWMMilestoneData.init(json: data)
                    DispatchQueue.main.async {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                    }
                    //print("enabledCount...\(self.milestoneData.milestoneEnabledData.count)++ disabledCount...\(self.milestoneData.milestoneDisabledData.count)")
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

extension Date {
    
    var convertedDate: Date {
        
        let dateFormatter = DateFormatter();
        
        let dateFormat = "dd MMM yyyy";
        dateFormatter.dateFormat = dateFormat;
        let formattedDate = dateFormatter.string(from: self);
        
        dateFormatter.locale = Locale.current;
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00");
        
        
        dateFormatter.dateFormat = dateFormat as String;
        let sourceDate = dateFormatter.date(from: formattedDate as String);
        
        return sourceDate!
    }
}

extension WWMMyProgressStatsVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollview.... \(scrollView.contentOffset.y)")
        
        var yaxis: CGFloat = 395
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //print("iPhone 5 or 5S or 5C")
                yaxis = 400
            case 1334:
                //print("iPhone 6/6S/7/8")
                yaxis = 395
            case 2208:
                //print("iPhone 6+/6S+/7+/8+")
                yaxis = 370
            case 2436:
                //print("iPhone X, XS")
                yaxis = 340
            case 2688:
                //print("iPhone XS Max")
                yaxis = 300
            case 1792:
                //print("iPhone XR")
                yaxis = 370
            default:
                //print("unknown")
                yaxis = 395
            }
        }
        
        if scrollView.contentOffset.y > yaxis{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if self.circle{
                    
                    if self.isLeft{
                        let weeklySession: Int = self.statsData.weekly_session ?? 0
                        //print("weeklySession.... \(weeklySession)")
                        self.lblMeditate.format = "%d"
                        self.lblMeditate.countFrom(0, to: CGFloat(weeklySession), withDuration: 1.0)
                        
                        let avgSession: Int = self.statsData.avg_session ?? 0
                        //print("avg_session.... \(avgSession)")
                        self.lblValueSession.format = "%d"
                        self.lblValueSession.countFrom(0, to: CGFloat(avgSession), withDuration: 1.0)
                        
                        
                        let longestSession: Int = self.statsData.longest_session ?? 0
                        //print("longestSession.... \(longestSession)")
                        self.lblValueDays.format = "%d"
                        self.lblValueDays.countFrom(0, to: CGFloat(longestSession), withDuration: 1.0)
                    }else{
                        let hoursOfMeditateSession: Int = self.statsData.hours_of_meditate ?? 0
                        //print("hoursOfMeditateSession.... \(hoursOfMeditateSession)")
                        self.lblMeditate.format = "%d"
                        self.lblMeditate.countFrom(0, to: CGFloat(hoursOfMeditateSession), withDuration: 1.0)
                        
                        let totalSession: Int = self.statsData.total_Session ?? 0
                        //print("totalSession.... \(totalSession)")
                        self.lblValueSession.format = "%d"
                        self.lblValueSession.countFrom(0, to: CGFloat(totalSession), withDuration: 1.0)
                        
                        
                        let consdaysSession: Int = self.statsData.cons_days ?? 0
                        //print("consdaysSession.... \(consdaysSession)")
                        self.lblValueDays.format = "%d"
                        self.lblValueDays.countFrom(0, to: CGFloat(consdaysSession), withDuration: 1.0)
                    }
                    
                    self.circle = false
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewHourMeditate.startProgress(to: 100, duration: 1.0)
                self.viewAvMinutes.startProgress(to: 100, duration: 1.0)
                self.viewDays.startProgress(to: 100, duration: 1.0)
            }
        }
    }
}

extension WWMMyProgressStatsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.milestoneData.milestoneEnabledData.count + self.milestoneData.milestoneDisabledData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.tableViewHeightConstraint.constant = 190 * CGFloat(self.milestoneData.milestoneEnabledData.count + self.milestoneData.milestoneDisabledData.count)
        
        if self.milestoneData.milestoneEnabledData.count > indexPath.row{
                        
            if indexPath.row%2 == 0{
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMMilestoneCell2") as! WWMMilestoneCell2
                
                cell.imgViewBack1.isHidden = true
                cell.imgViewBack.isHidden = false
                
                cell.view1.isHidden = false
                cell.view2.isHidden = true
                cell.lblTitle1.isHidden = false
                cell.lblTitle1_.isHidden = true
                cell.imgViewTitle1.isHidden = false
                cell.imgViewTitle1_.isHidden = true
                
                if self.milestoneData.milestoneEnabledData[indexPath.row].type == "hours_meditate"{
                    cell.imgViewTitle.image = UIImage(named: "hour")
                    cell.imgViewTitle1.image = UIImage(named: "mileHour1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileHour1")
                    cell.lblTitle.text = "Hours\nMeditated"
                }else if self.milestoneData.milestoneEnabledData[indexPath.row].type == "consecutive_days"{
                    cell.imgViewTitle.image = UIImage(named: "consecutive_days")
                    cell.imgViewTitle1.image = UIImage(named: "mileConsecutiveDays2")
                    cell.imgViewTitle1_.image = UIImage(named: "mileConsecutiveDays2")
                    cell.lblTitle.text = "Consecutive\nDays"
                }else if self.milestoneData.milestoneEnabledData[indexPath.row].type == "sessions"{
                    cell.imgViewTitle.image = UIImage(named: "session")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileSession1")
                    cell.lblTitle.text = "Sessions"
                }else{
                    cell.imgViewTitle.image = UIImage(named: "mileChallenge")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileSession1")
                    cell.lblTitle.text = "Challenges"
                }
                
                if indexPath.row == 0{
                    cell.imgViewBack.image = UIImage(named: "sliceTop")
                }else{
                   cell.imgViewBack.image = UIImage(named: "slice_back")
                }
                
                cell.lblTitle1.text = self.milestoneData.milestoneEnabledData[indexPath.row].title
                cell.lblTitle1_.text = self.milestoneData.milestoneEnabledData[indexPath.row].title
                cell.lblDate.text = self.milestoneData.milestoneEnabledData[indexPath.row].complete_date
                return cell
            }else{

                let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMMilestoneCell1") as! WWMMilestoneCell1
                
                cell.imgViewBack1.isHidden = true
                cell.imgViewBack.isHidden = false
                if self.milestoneData.milestoneEnabledData[indexPath.row].type == "hours_meditate"{
                    cell.imgViewTitle.image = UIImage(named: "hour")
                    cell.imgViewTitle1.image = UIImage(named: "mileHour2")
                    cell.lblTitle.text = "Hours\nMeditated"
                }else if self.milestoneData.milestoneEnabledData[indexPath.row].type == "consecutive_days"{
                    cell.imgViewTitle.image = UIImage(named: "consecutive_days")
                    cell.imgViewTitle1.image = UIImage(named: "mileConsecutiveDays1")
                    cell.lblTitle.text = "Consecutive\nDays"
                }else if self.milestoneData.milestoneEnabledData[indexPath.row].type == "sessions"{
                    cell.imgViewTitle.image = UIImage(named: "session")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession2")
                    cell.lblTitle.text = "Sessions"
                }else{
                    cell.imgViewTitle.image = UIImage(named: "mileChallenge")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession2")
                    cell.lblTitle.text = "Completed\n\(self.milestoneData.milestoneEnabledData[indexPath.row].type)"
                }
                cell.lblTitle1.text = self.milestoneData.milestoneEnabledData[indexPath.row].title
                cell.lblDate.text = self.milestoneData.milestoneEnabledData[indexPath.row].complete_date
                cell.imgViewBack.image = UIImage(named: "slice")
                return cell
                
            }
            
        }else{
            //print("indexpathrow....+++\(indexPath.row)")
            let indexPathRow1 = indexPath.row - (self.milestoneData.milestoneEnabledData.count)
            
            if indexPath.row%2 == 0{
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMMilestoneCell2") as! WWMMilestoneCell2
                
                    cell.imgViewBack.isHidden = true
                    cell.imgViewBack1.isHidden = false
                
                    cell.view1.isHidden = true
                    cell.view2.isHidden = false
                    cell.lblTitle1.isHidden = true
                    cell.lblTitle1_.isHidden = false
                    cell.imgViewTitle1.isHidden = true
                    cell.imgViewTitle1_.isHidden = false
                
                if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "hours_meditate"{
                    cell.imgViewTitle.image = UIImage(named: "hour")
                    cell.imgViewTitle1.image = UIImage(named: "mileHour1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileHour1")
                    cell.lblTitle.text = "Hours\nMeditated"
                }else if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "consecutive_days"{
                    cell.imgViewTitle.image = UIImage(named: "consecutive_days")
                    cell.imgViewTitle1.image = UIImage(named: "mileConsecutiveDays2")
                    cell.imgViewTitle1_.image = UIImage(named: "mileConsecutiveDays2")
                    cell.lblTitle.text = "Consecutive\nDays"
                }else if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "sessions"{
                    cell.imgViewTitle.image = UIImage(named: "session")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileSession1")
                    cell.lblTitle.text = "Sessions"
                }else{
                    cell.imgViewTitle.image = UIImage(named: "mileChallenge")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession1")
                    cell.imgViewTitle1_.image = UIImage(named: "mileSession1")
                    cell.lblTitle.text = "Challenges"
                }
                
                cell.imgViewBack1.image = UIImage(named: "slice_back1")
                cell.lblTitle1.text = self.milestoneData.milestoneDisabledData[indexPathRow1].title
                cell.lblTitle1_.text = self.milestoneData.milestoneDisabledData[indexPathRow1].title
                cell.lblDate.text = self.milestoneData.milestoneDisabledData[indexPathRow1].complete_date
                return cell

            }else{
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMMilestoneCell1") as! WWMMilestoneCell1
                
                cell.imgViewBack.isHidden = true
                cell.imgViewBack1.isHidden = false
                
                if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "hours_meditate"{
                    cell.imgViewTitle.image = UIImage(named: "hour")
                    cell.imgViewTitle1.image = UIImage(named: "mileHour2")
                    cell.lblTitle.text = "Hours\nMeditated"
                }else if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "consecutive_days"{
                    cell.imgViewTitle.image = UIImage(named: "consecutive_days")
                    cell.imgViewTitle1.image = UIImage(named: "mileConsecutiveDays1")
                    cell.lblTitle.text = "Consecutive\nDays"
                }else if self.milestoneData.milestoneDisabledData[indexPathRow1].type == "sessions"{
                    cell.imgViewTitle.image = UIImage(named: "session")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession2")
                    cell.lblTitle.text = "Sessions"
                }else{
                    cell.imgViewTitle.image = UIImage(named: "mileChallenge")
                    cell.imgViewTitle1.image = UIImage(named: "mileSession2")
                    cell.lblTitle.text = "Challenges"
                }
                cell.imgViewBack1.image = UIImage(named: "slice1")
                cell.lblTitle1.text = self.milestoneData.milestoneDisabledData[indexPath.row - (self.milestoneData.milestoneEnabledData.count)].title
                cell.lblDate.text = self.milestoneData.milestoneDisabledData[indexPath.row - (self.milestoneData.milestoneEnabledData.count)].complete_date
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func playSound(name: String ) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            player?.delegate = self
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player?.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    
        //print("finished")//It is working now! printed "finished"!
        self.player?.stop()
    }
}

extension WWMMyProgressStatsVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        itemInfo
    }
}

extension WWMMyProgressStatsVC{
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"      : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : "guided",
            "guided_type"   : self.challType.lowercased()
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                //print("result hometabvc meditation data... \(result) success meditationdata api WWMHomeTabVC background thread")
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                    }
                }
            }
        }
    }
}
