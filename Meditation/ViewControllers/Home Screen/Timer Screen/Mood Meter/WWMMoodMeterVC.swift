//
//  WWMMoodMeterVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Lottie

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
        
        let attributeString = NSMutableAttributedString(string: "Skip",
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
                            
                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPreMoodCount), title: "Your subscription plan has expired.", subTitle: "You can't lock your mood before purchase of any subscription plan.", type: "Pre")
                            self.view.isUserInteractionEnabled = false
                            
                        }else{
                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPreMoodCount), title: "Your subscription plan has expired.", subTitle: "You have only pre \(getPreMoodCount) mood and \(getPreJournalCount) journal enteries left.", type: "Pre")
                            self.view.isUserInteractionEnabled = true
                            
                        }
                    }else{
                        let getPostMoodCount = self.appPreference.getPostMoodCount()
                        let getPostJournalCount = self.appPreference.getPostJournalCount()
                        
                        //if (getPostMoodCount < 7 && getPostMoodCount != 0) || (getPostJournalCount < 7 && getPostJournalCount != 0)
                        if (getPostMoodCount == 0) && (getPostJournalCount == 0){
                            print("getPostMoodCount... \(getPostMoodCount)")

                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPostMoodCount), title: "Your subscription plan has expired.", subTitle: "You can't lock your mood before purchase of any subscription plan.", type: "Post")
                            self.view.isUserInteractionEnabled = false
                            
                        }else{
                            self.getFreeMoodMeterAlert(freeMoodMeterCount: String(getPostMoodCount), title: "Your subscription plan has expired.", subTitle: "You have only post \(getPostMoodCount) mood and \(getPostJournalCount) journal enteries left.", type: "Post")
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
                completeMeditationAPI()
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
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
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
                "mood_id":self.moodData.id == -1 ? "0" : self.moodData.id,
                ] as [String : Any]
        }else{
            param = [
                "type":self.userData.type,
                "category_id" : self.category_Id,
                "emotion_id" : self.emotion_Id,
                "audio_id" : self.audio_Id,
                "guided_type" : self.userData.guided_type,
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
                "mood_id":self.moodData.id == -1 ? "0" : self.moodData.id,
                ] as [String : Any]
        }
        
        print("meter param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    self.appPreffrence.setSessionAvailableData(value: true)
                    self.navigateToDashboard()
                }else {
                    self.saveToDB(param: param)
                }
                
            }else {
                self.saveToDB(param: param)
            }

            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.createMoodScroller()
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
            button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
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
        
//        let diff = Double(360) / Double(self.arrMoodData.count)
//        let angle = Double(selectedIndex) * diff
//        self.circularSlider(circularSlider!, angleDidChanged: angle)
//        self.circularSlider?.updateAngle()
//        self.circularSlider?.updateThumb(with: true)
        
        let x = Int(self.moodView!.bounds.size.width / 2) * selectedIndex
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
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
        self.moodView?.isHidden = false
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        let x = Int(self.moodView!.bounds.size.width / 2) * Int(selectedMood)
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func circularSlider(slidingDidEnd circularSlider: CircularSlider) -> Void {
        let angle = self.translatedAngle(angle: circularSlider.angleInDegrees())
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        let moodIndex = Int(selectedMood)
        selectedIndex = moodIndex
        let mood = self.arrMoodData[moodIndex]

        print("selected index slider... \(selectedIndex)")
        
        for index in 0..<arrButton.count {
            let button = arrButton[index]
            if index == moodIndex {
                button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 16)
                button.setTitleColor(UIColor.white, for: .normal)
            }else{
                button.titleLabel?.font = UIFont(name: "Maax-Medium", size: 13)
                button.setTitleColor(UIColor.lightGray, for: .normal)
            }
        }
        
        print("selected mood = \(mood.name)")
        self.btnConfirm.isHidden = false
        self.lblMoodselect.text = "Move dot to select your current feeling"
    }
    

    // MARK:- Button Action

    @IBAction func btnSkipAction(_ sender: Any) {
        
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

            WWMHelperClass.showLoaderAnimate(on: self.view)
            let param = [
                "type": self.userData.type,
                "category_id": self.category_Id,
                "emotion_id": self.emotion_Id,
                "audio_id": self.audio_Id,
                "guided_type": self.userData.guided_type,
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
                "mood_id": self.moodData.id == -1 ? "0" : self.moodData.id,
                ] as [String : Any]
            
            print("meter param... \(param)")
            
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    if let success = result["success"] as? Bool {
                        print(success)
                        self.appPreffrence.setSessionAvailableData(value: true)
                        self.navigateToDashboard()
                    }else {
                        self.saveToDB(param: param)
                    }
                    
                }else {
                    self.saveToDB(param: param)
                }
                //WWMHelperClass.dismissSVHud()
                WWMHelperClass.hideLoaderAnimate(on: self.view)
            }
        }
    }
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        self.navigateToDashboard()
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
                        
                        completeMeditationAPI()
                    }else if (self.appPreference.getPreMoodCount() == 0) && (self.appPreference.getPreJournalCount() > 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPreMoodCount() > 0) && (self.appPreference.getPreJournalCount() == 0){
                        
                        completeMeditationAPI()
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
                        
                        completeMeditationAPI()
                    }else if (self.appPreference.getPostMoodCount() == 0) && (self.appPreference.getPostJournalCount() > 0){
                        
                        self.callWWMMoodMeterLogVC()
                    }else if (self.appPreference.getPostMoodCount() > 0) && (self.appPreference.getPostJournalCount() == 0){
                        
                        completeMeditationAPI()
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
