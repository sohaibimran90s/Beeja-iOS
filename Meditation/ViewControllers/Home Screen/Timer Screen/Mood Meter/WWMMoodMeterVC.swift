//
//  WWMMoodMeterVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Lottie
import CoreData

class WWMMoodMeterVC: WWMBaseViewController,CircularSliderDelegate {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAskMeAgain: UIButton!
    @IBOutlet weak var lblMoodselect: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var moodView: UIView?
    @IBOutlet weak var viewLottieAnimation: UIView?
    @IBOutlet weak var circularSlider: CircularSlider?
    var moodScroller: UIScrollView?
    
    @IBOutlet weak var viewMoodMeter: UIView!
    @IBOutlet weak var imgMoodMeter: UIImageView!
    @IBOutlet weak var lblMoodMeter: UILabel!
    
    let appPreffrence = WWMAppPreference()
    
    var arrMoodData = [WWMMoodMeterData]()
    var moodData = WWMMoodMeterData()
    var selectedIndex = -1
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var type = ""   // Pre | Post
    var meditationID = ""
    var levelID = ""
    var category_Id = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var watched_duration = "0"
    var rating = "0"
    var step_id: String = ""
    var mantra_id: String = ""
    var selectedType: String = ""
    
    var settingData = DBSettings()
    var alertPrompt = WWMPromptMsg()
    var alertPopupView1 = WWMAlertController()
    
    var button = UIButton()
    var arrButton = [UIButton]()
    
    var animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if type == "pre" {
            self.btnAskMeAgain.isHidden = true
            self.btnSkip.isHidden = true
        }else{
            self.btnBack.isHidden = true
        }
        
        if WWMHelperClass.selectedType == "learn"{
            self.btnAskMeAgain.isHidden = true
        }
        
        self.xibCall()
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)

        self.btnConfirm.layer.borderWidth = 2.0
        self.btnConfirm.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnConfirm.isHidden = true
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        let moodMeter = WWMMoodMeterData()
        arrMoodData = moodMeter.getMoodMeterData()
        
        self.moodView?.isHidden = true
        self.lblMoodMeter.isHidden = true
        self.moodView?.layer.cornerRadius = 20
        self.moodView?.clipsToBounds = true
        
        
        animationView = AnimationView(name: "hand")
        animationView.frame = CGRect(x: 0, y: 0, width: 106, height: 106)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        viewLottieAnimation!.addSubview(animationView)
        view.addSubview(viewLottieAnimation!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.animationView.play()
        })
    }
    
    func xibCall(){
        alertPrompt = UINib(nibName: "WWMPromptMsg", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMPromptMsg
        let window = UIApplication.shared.keyWindow!
        
        alertPrompt.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPrompt, duration: 0.8, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPrompt)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.alertPrompt.removeFromSuperview()
                
                if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
                    
                    if self.type == "pre" {
                        let getPreMoodCount = self.appPreference.getPreMoodCount()
                        let getPreJournalCount = self.appPreference.getPreJournalCount()
                        
                        //if (getPreMoodCount < 7 && getPreMoodCount != 0) || (getPreJournalCount < 7 && getPreJournalCount != 0)
                        if (getPreMoodCount == 0 && getPreJournalCount == 0) || (getPreMoodCount == 0 && getPreJournalCount > 0){
                            print("getPreMoodCount... \(getPreMoodCount)")
                            
                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPreMoodCount), title: KSUBSPLANEXP, subTitle: KNOFREEMOODJOU, type: "Pre")
                            self.view.isUserInteractionEnabled = false
                            
                        }
//                        else{
//                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPreMoodCount), title: KSUBSPLANEXP, subTitle: "You have \(getPreMoodCount) pre mood and \(getPreJournalCount) journal entries left. Subscribe for more.", type: "Pre")
//                            self.view.isUserInteractionEnabled = true
//                        }
                    }else{
                        let getPostMoodCount = self.appPreference.getPostMoodCount()
                        let getPostJournalCount = self.appPreference.getPostJournalCount()
                        
                        //if (getPostMoodCount < 7 && getPostMoodCount != 0) || (getPostJournalCount < 7 && getPostJournalCount != 0)
                        if (getPostMoodCount == 0) && (getPostJournalCount == 0){
                            print("getPostMoodCount... \(getPostMoodCount)")

                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPostMoodCount), title: KSUBSPLANEXP, subTitle: KNOFREEMOODJOU, type: "Post")
                            self.view.isUserInteractionEnabled = false
                            
                        }else if(getPostMoodCount == 0) && (getPostJournalCount != 0){
                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPostMoodCount), title: KSUBSPLANEXP, subTitle: KNOFREEMOOD, type: "Post")
                            
                            self.view.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        }
    }
    
    func getFreeMoodMeterAlert(freeMoodMeterCount: String, title: String, subTitle: String, type: String){
        self.alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        self.alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.alertPopupView1.lblTitle.numberOfLines = 0
        self.alertPopupView1.btnOK.layer.borderWidth = 2.0
        self.alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.alertPopupView1.lblTitle.text = title
        self.alertPopupView1.lblSubtitle.text = subTitle
        self.alertPopupView1.btnClose.isHidden = true
        
        self.alertPopupView1.btnOK.addTarget(self, action: #selector(btnAlertDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @objc func btnAlertDoneAction(_ sender: Any){
        if type == "pre" {
            
            print("getPreJournalCount.... \(self.appPreference.getPreJournalCount())")
             print("getPreMoodCount.... \(self.appPreference.getPreMoodCount())")
            if (self.appPreference.getPreMoodCount() < 7 && self.appPreference.getPreMoodCount() != 0) && (self.appPreference.getPreJournalCount() < 7 && self.appPreference.getPreJournalCount() != 0){
                
                self.view.isUserInteractionEnabled = true
                self.alertPopupView1.removeFromSuperview()
            }else if (self.appPreference.getPreMoodCount() == 0) && (self.appPreference.getPreJournalCount() == 0){
                
                self.view.isUserInteractionEnabled = false
                self.alertPopupView1.removeFromSuperview()
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popViewController(animated: true)
            }else if (self.appPreference.getPreMoodCount() == 0) && (self.appPreference.getPreJournalCount() > 0){
                
                self.view.isUserInteractionEnabled = false
                self.alertPopupView1.removeFromSuperview()
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.popViewController(animated: true)
            }else if (self.appPreference.getPreMoodCount() > 0) && (self.appPreference.getPreJournalCount() == 0){
                
                self.alertPopupView1.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }else{
                
                self.alertPopupView1.removeFromSuperview()
                self.view.isUserInteractionEnabled = false
                self.callWWMMoodMeterLogVC()
            }
        }else{
            
            print("getPostJournalCount.... \(self.appPreference.getPostJournalCount())")
            if (self.appPreference.getPostMoodCount() < 7 && self.appPreference.getPostMoodCount() != 0) && (self.appPreference.getPostJournalCount() < 7 && self.appPreference.getPostJournalCount() != 0){
                self.view.isUserInteractionEnabled = true
                self.alertPopupView1.removeFromSuperview()
            }else if (self.appPreference.getPostMoodCount() == 0) && (self.appPreference.getPostJournalCount() == 0){
                self.view.isUserInteractionEnabled = false
                self.alertPopupView1.removeFromSuperview()
                
                DispatchQueue.global(qos: .background).async {
                    self.completeMeditationAPI()
                }
                self.navigateToDashboard()
                
            }else if (self.appPreference.getPostMoodCount() == 0) && (self.appPreference.getPostJournalCount() > 0){
                self.alertPopupView1.removeFromSuperview()
                self.view.isUserInteractionEnabled = false
                self.callWWMMoodMeterLogVC()
            }else if (self.appPreference.getPostMoodCount() > 0) && (self.appPreference.getPostJournalCount() == 0){
                self.alertPopupView1.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }else{
                self.alertPopupView1.removeFromSuperview()
                self.view.isUserInteractionEnabled = false
                self.callWWMMoodMeterLogVC()
            }
        }
    }
    
    func callWWMMoodMeterLogVC(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
        
        print("type..... \(self.type)")
        print("apppre... \(self.appPreffrence.getPrePostJournalBool())")
        print("postmoddcount.. \(self.appPreference.getPostMoodCount())")
        print("getPreMoodCount.. \(self.appPreference.getPreMoodCount())")
        
        vc.selectedIndex = String(selectedIndex)
        if self.type == "pre"{
            if !self.appPreffrence.getPrePostJournalBool(){
                vc.moodData = arrMoodData[selectedIndex]
                vc.selectedIndex = String(selectedIndex)
            }else{
                if self.appPreference.getPreMoodCount() > 0{
                    vc.moodData = arrMoodData[selectedIndex]
                    vc.selectedIndex = String(selectedIndex)
                }
            }
        }else{
            if !self.appPreffrence.getPrePostJournalBool(){
                vc.moodData = arrMoodData[selectedIndex]
                vc.selectedIndex = String(selectedIndex)
            }else{
                if self.appPreference.getPostMoodCount() > 0{
                    vc.moodData = arrMoodData[selectedIndex]
                    vc.selectedIndex = String(selectedIndex)
                }
            }
        }
        
        vc.type = self.type
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        vc.meditationID = self.meditationID
        vc.levelID = self.levelID
        vc.category_Id = self.category_Id
        vc.emotion_Id = self.emotion_Id
        vc.audio_Id = self.audio_Id
        vc.rating = self.rating
        vc.watched_duration = self.watched_duration
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func completeMeditationAPI() {
        
        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: "\(nintyFivePercentDB.count - 1)")
        }

        var param: [String: Any] = [:]
        if WWMHelperClass.selectedType == "learn"{
            param = [
                "type":"learn",
                "step_id": WWMHelperClass.step_id,
                "mantra_id": WWMHelperClass.mantra_id,
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.userData.guided_type,
                "duration" : self.watched_duration,
                "rating" : self.rating,
                "user_id":self.appPreference.getUserID(),
                "meditation_type":type,
                "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                "tell_us_why":"",
                "prep_time":prepTime,
                "meditation_time":meditationTime,
                "rest_time":restTime,
                "meditation_id": self.meditationID,
                "level_id":self.levelID,
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
                "complete_percentage": WWMHelperClass.complete_percentage
                ] as [String : Any]
        }else{
            param = [
                "type": WWMHelperClass.selectedType,
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.appPreffrence.getGuideType(),
                "watched_duration" : self.watched_duration,
                "rating" : self.rating,
                "user_id":self.appPreference.getUserID(),
                "meditation_type":type,
                "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
                "tell_us_why":"",
                "prep_time":prepTime,
                "meditation_time":meditationTime,
                "rest_time":restTime,
                "meditation_id": self.meditationID,
                "level_id":self.levelID,
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
                "complete_percentage": WWMHelperClass.complete_percentage
                ] as [String : Any]
        }
        
        print("meter param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMMoodMeterVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                if let _ = result["success"] as? Bool {
                    self.appPreffrence.setSessionAvailableData(value: true)
                    print("success... moodmetervc meditationcomplete api in background")
                    self.meditationHistoryListAPI()

                    WWMHelperClass.complete_percentage = "0"
                    
                    //self.navigateToDashboard()
                }else {
                    self.saveToDB(param: param)
                }
                
            }else {
                self.saveToDB(param: param)
            }
        }
    }
    
    //MeditationHistoryList API
    func meditationHistoryListAPI() {
        
        let param = ["user_id": self.appPreffrence.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONHISTORY+"?page=1", context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [String: Any]{
                    if let records = data["records"] as? [[String: Any]]{
                        
                        let meditationHistoryData = WWMHelperClass.fetchDB(dbName: "DBMeditationHistory") as! [DBMeditationHistory]
                        if meditationHistoryData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBMeditationHistory")
                        }
                        
                        for dict in records{
                            let dbMeditationHistory = WWMHelperClass.fetchEntity(dbName: "DBMeditationHistory") as! DBMeditationHistory
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                            let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                            dbMeditationHistory.data = myString
                            WWMHelperClass.saveDb()
                            
                        }
                    }
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationMeditationHistory"), object: nil)
                print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result)")
                print("success moodmeterVC meditationhistoryapi in background thread")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        //self.createMoodScroller()
    }

    func createMoodScroller() {
        
        let scrollView = UIScrollView(frame: self.moodView!.bounds)
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.moodView!.bounds.size.width * CGFloat(self.arrMoodData.count / 2) + self.moodView!.bounds.size.width / 2, height: self.moodView!.bounds.size.height)
        var x = self.moodView!.bounds.size.width / 4
        let y = CGFloat(0)
        let width = self.moodView!.bounds.size.width / 2
        let height = self.moodView!.bounds.size.height

        self.arrButton.removeAll()
        var tags: Int = 0
        for mood in self.arrMoodData {
            
            print("mood...\(mood.id)")
            print("mood...\(mood.name)")
            
            //buttons....
            
            //Modified By Akram Fonts
            let widthButton = width+24
            let xDimensionButton = x-15
            button = UIButton(frame: CGRect(x: xDimensionButton, y: y, width: widthButton, height: height))

            
            //button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
            button.backgroundColor = .clear
            
            button.setTitle(mood.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 13)
            button.titleLabel?.textAlignment = .center
            button.tag = tags
            
            button.addTarget(self, action: #selector(selectedMoodAction), for: .touchUpInside)
            scrollView.addSubview(button)
            x = x + width
            self.arrButton.append(button)
            tags += 1
        }
        
        self.moodView!.addSubview(scrollView)
        self.moodScroller = scrollView
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @objc func selectedMoodAction(sender: UIButton){
        print("sender selected button label with tag.....\(sender.tag) selectedName...\(self.arrMoodData[sender.tag].name) buttonName.... \(arrButton[sender.tag].titleLabel?.text ?? "") selected index button... \(sender.tag)")
        
        selectedIndex = sender.tag
        

        for index in 0..<arrButton.count {
            let button = arrButton[index]
            if index == sender.tag {
                button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 16)
                button.setTitleColor(UIColor.white, for: .normal)
            }else {
                button.titleLabel?.font = UIFont(name: "Maax-Medium", size: 13)
                button.setTitleColor(UIColor.lightGray, for: .normal)
            }
        }
        
        let diff = Double(360) / Double(self.arrMoodData.count)
        let angle1 = Double(selectedIndex) * diff
        let angle = self.translatedAngle(angle: angle1)
        
        let distance = self.distance(a: CGPoint.init(x: (self.circularSlider?.frame.size.width)!/2, y: 0), b: CGPoint.init(x: (self.circularSlider?.frame.size.width)!/2, y: (self.circularSlider?.frame.size.height)!/2))
        print("distance... \(distance) angle... \(angle)")
        
        let rect = CGPoint.init(x:(self.circularSlider?.frame.size.width)!/2 + CGFloat(distance * cos(angle)) , y: (self.circularSlider?.frame.size.height)!/2 + CGFloat(distance*sin(angle)))
        
        self.circularSlider?.thumbCenter = self.circularSlider?.findIntersectionOfCircleWithLineFromCenter(to: rect)
        self.circularSlider?.setTouchIndicator(true)
        self.circularSlider?.updateThumb(with: true)
        self.circularSlider?.updateAngle()
        
        //(x + r*cos(a), y + r*sin(a))
//        self.circularSlider(circularSlider!, angleDidChanged: angle)
//        self.circularSlider?.updateAngle()
//        self.circularSlider?.updateThumb(with: true)
        
        let x = Int(self.moodView!.bounds.size.width / 2) * selectedIndex
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func distance( a: CGPoint,  b: CGPoint) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        
        return Double(sqrt(xDist*xDist + yDist*yDist))
    }
    
    func translatedAngle(angle: Double) -> Double {
        print("angle ****..... \(angle)")
        //450
        var angle = Double(450) -  angle
        if angle > 360 {
            angle = angle - 360
        }
        return angle
    }
    
    func circularSlider(_ circularSlider: CircularSlider, angleDidChanged newAngle: Double) -> Void {
        
        self.animationView.stop()
        self.viewLottieAnimation?.isHidden = true
        print("newAngle ***.... \(newAngle)")
        let angle = self.translatedAngle(angle: newAngle)
        //self.moodView?.isHidden = false
        self.lblMoodMeter.isHidden = false
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        
        let moodIndex = Int(selectedMood)
        selectedIndex = moodIndex
        
        print("moodIndex... \(selectedIndex) self.arrMoodData... \(self.arrMoodData.count) self.arrMoodData[selectedIndex].name... \(self.arrMoodData[selectedIndex].name)")
        
        self.appPreference.setMoodId(value: "\(self.arrMoodData[selectedIndex].id)")
        
        if selectedIndex >= 72{
            self.lblMoodMeter.text = self.arrMoodData[71].name
            self.imgMoodMeter.image = UIImage(named: self.arrMoodData[71].name)
        }else{
            self.lblMoodMeter.text = self.arrMoodData[selectedIndex].name
            self.imgMoodMeter.image = UIImage(named: self.arrMoodData[selectedIndex].name)
        }
        
        let x = Int(self.moodView!.bounds.size.width / 2) * Int(selectedMood)
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func circularSlider(slidingDidEnd circularSlider: CircularSlider) -> Void {
        let angle = self.translatedAngle(angle: circularSlider.angleInDegrees())
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        let moodIndex = Int(selectedMood)
        selectedIndex = moodIndex
        let mood = self.arrMoodData[selectedIndex]

        print("selected index slider... \(selectedIndex) name+++ \(self.arrMoodData[selectedIndex].name) ")
        self.lblMoodMeter.text = self.arrMoodData[selectedIndex].name
        self.imgMoodMeter.image = UIImage(named: self.arrMoodData[selectedIndex].name)
        
        print("selected mood = \(mood.name) selected mood id = \(mood.id)")
        self.appPreference.setMoodId(value: "\(mood.id)")
        self.btnConfirm.isHidden = false
        self.lblMoodselect.text = KMOVEDOTSELECT
    }
    

    // MARK:- Button Action

    @IBAction func btnSkipAction(_ sender: Any) {
        
        print("self.userData.type.... \(self.userData.type)")
        self.appPreference.setMoodId(value: "")

        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: "\(nintyFivePercentDB.count - 1)")
        }
        
        // Analytics
        if self.type == "pre" {
            WWMHelperClass.sendEventAnalytics(contentType: "MOODMETER_PRE", itemId: "SKIPPED", itemName: "")
        }else {
            WWMHelperClass.sendEventAnalytics(contentType: "MOODMETER_POST", itemId: "SKIPPED", itemName: "")
        }
        
        if WWMHelperClass.selectedType == "learn"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
            vc.type = self.type
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            vc.category_Id = self.category_Id
            vc.emotion_Id = self.emotion_Id
            vc.audio_Id = self.audio_Id
            vc.rating = self.rating
            vc.watched_duration = self.watched_duration
            self.navigationController?.pushViewController(vc, animated: true)
        }else{

            let param = [
                "type": WWMHelperClass.selectedType,
                "category_id": self.category_Id,
                "emotion_id": self.emotion_Id,
                "audio_id": self.audio_Id,
                "guided_type": self.appPreffrence.getGuideType(),
                "watched_duration": self.watched_duration,
                "rating": self.rating,
                "user_id": self.appPreference.getUserID(),
                "meditation_type": self.type,
                "date_time": "\(Int(Date().timeIntervalSince1970*1000))",
                "tell_us_why": "",
                "prep_time": self.prepTime,
                "meditation_time": self.meditationTime,
                "rest_time": self.restTime,
                "meditation_id": self.meditationID,
                "level_id": self.levelID,
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
                "complete_percentage": WWMHelperClass.complete_percentage
                ] as [String : Any]
            
            print("meter param... \(param)")
            
            
            //background thread meditation api*
            DispatchQueue.global(qos: .background).async {
                WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMMoodMeterVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                    if sucess {
                        if let _ = result["success"] as? Bool {
                            print("success... moodmetervc meditationcomplete api in background")
                            self.appPreffrence.setSessionAvailableData(value: true)
                            self.meditationHistoryListAPI()
                            
                            WWMHelperClass.complete_percentage = "0"
                            //self.navigateToDashboard()
                        }else {
                            self.saveToDB(param: param)
                        }
                        
                    }else {
                        self.saveToDB(param: param)
                    }
                }
            }//background thread meditation api*

            self.navigateToDashboard()
            
        }
    }
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        //self.navigateToDashboard()
    }
    
    func navigateToDashboard() {
        
        if WWMHelperClass.selectedType == "learn"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFAQsVC") as! WWMFAQsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.navigationController?.isNavigationBarHidden = false
            
            if let tabController = self.tabBarController as? WWMTabBarVC {
                tabController.selectedIndex = 4
                for index in 0..<tabController.tabBar.items!.count {
                    let item = tabController.tabBar.items![index]
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                    if index == 4 {
                        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                    }
                }
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        // Analytics
        let moodData = arrMoodData[selectedIndex]
        if self.type == "pre" {
            WWMHelperClass.sendEventAnalytics(contentType: "MOODMETER_PRE", itemId: moodData.name.uppercased(), itemName: "")
        }else {
            WWMHelperClass.sendEventAnalytics(contentType: "MOODMETER_POST", itemId: moodData.name.uppercased(), itemName: "")
        }
        remainingLogFunc()
    }
    
    func remainingLogFunc(){
        if selectedIndex != -1 {
            if KUSERDEFAULTS.bool(forKey: "getPrePostMoodBool"){
                
                if self.type == "pre" {
                    
                    print("getPostJournalCount.... \(self.appPreference.getPreJournalCount())")
                    if (self.appPreference.getPreMoodCount() < 7 && self.appPreference.getPreMoodCount() != 0) && (self.appPreference.getPreJournalCount() < 7 && self.appPreference.getPreJournalCount() != 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPreMoodCount() == 0) && (self.appPreference.getPreJournalCount() == 0){
                        
                        
                        DispatchQueue.global(qos: .background).async {
                            self.completeMeditationAPI()
                        }
                        self.navigateToDashboard()
                        
                    }else if (self.appPreference.getPreMoodCount() == 0) && (self.appPreference.getPreJournalCount() > 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPreMoodCount() > 0) && (self.appPreference.getPreJournalCount() == 0){
                        
                        DispatchQueue.global(qos: .background).async {
                            self.completeMeditationAPI()
                        }
                        self.navigateToDashboard()
                        
                    }else{
                        
                        self.callWWMMoodMeterLogVC()
                    }
                    
                    let getPreMoodCount = self.appPreference.getPreMoodCount()
                    if getPreMoodCount < 7 && getPreMoodCount != 0{
                        self.appPreference.setPreMoodCount(value: self.appPreference.getPreMoodCount() - 1)
                    }
                }else{
                    
                    let getPostMoodCount = self.appPreference.getPostMoodCount()
                    if getPostMoodCount < 7 && getPostMoodCount != 0{
                        self.appPreference.setPostMoodCount(value: self.appPreference.getPostMoodCount() - 1)
                    }
                    
                    print("getPostJournalCount.... \(self.appPreference.getPostJournalCount())")
                    if (self.appPreference.getPostMoodCount() < 7 && self.appPreference.getPostMoodCount() != 0) && (self.appPreference.getPostJournalCount() < 7 && self.appPreference.getPostJournalCount() != 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPostMoodCount() == 0) && (self.appPreference.getPostJournalCount() == 0){
                        
                        DispatchQueue.global(qos: .background).async {
                            self.completeMeditationAPI()
                        }
                        self.navigateToDashboard()
                        
                    }else if (self.appPreference.getPostMoodCount() == 0) && (self.appPreference.getPostJournalCount() > 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPostMoodCount() > 0) && (self.appPreference.getPostJournalCount() == 0){
                        
                        DispatchQueue.global(qos: .background).async {
                            self.completeMeditationAPI()
                        }
                        self.navigateToDashboard()
                        
                    }else{
                        
                        self.callWWMMoodMeterLogVC()
                    }
                }
            }else{
                self.callWWMMoodMeterLogVC()
            }
        }
    }
    
    @IBAction func btnAskMeAgainAction(_ sender: Any) {
        
        self.settingData.moodMeterEnable = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
        vc.type = self.type
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        vc.meditationID = self.meditationID
        vc.levelID = self.levelID
        vc.category_Id = self.category_Id
        vc.emotion_Id = self.emotion_Id
        vc.audio_Id = self.audio_Id
        vc.rating = self.rating
        vc.watched_duration = self.watched_duration
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func btnPreBackAction(_ sender: UIButton) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
}
