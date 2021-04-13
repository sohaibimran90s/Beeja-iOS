//
//  WWMLearnTimerVC.swift
//  Meditation
//
//  Created by Prema Negi on 21/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Lottie
import CoreData

class WWMLearnTimerVC: WWMBaseViewController {
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblTimerType: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    //notificationCenter.removeObserver(self)
    var notificationCenter = NotificationCenter.default
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var timer1 = Timer()
    var animateBool: Int = 0
    
    var seconds = 0
    var totalDuration: Int = 0
    var totalAudioLength: String = ""
    var totalAudioLengthAnalytics: Int = 0
    
    var settingData = DBSettings()
    var animationView = AnimationView()
    var timer = Timer()
    
    var isPlayer = false
    var isStop = false
    var player: AVPlayer?
    
    var paidFreeUSer: String = ""
    var ismove = false
    var watched_duration: Int = 0
    
    //for offline meditation data parameters
    var offlineCompleteData: [String: Any] = [:]
    var meditationLTMPlayPercentage = 0
    var dataAppendFlag = false
    
    let reachable = Reachabilities()
    
    var ninetyFiveCompletedFlag = "1"
    var isComplete = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("self.min_limit++ \(self.appPreference.getLearnMin_limit()) self.max_limit++ \(self.appPreference.getLearnMax_limit())")
        
        WWMHelperClass.addNinetyFivePercentData(type: "Learn")
        
        self.lblTimerType.text = "\(KSTEP)\(WWMHelperClass.step_id): \(WWMHelperClass.step_title)"
        setUpView()
        
        animationView = AnimationView(name: "final1")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        view.insertSubview(animationView, belowSubview: viewPause)
        spinnerImage.isHidden = true
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.lblTimer.text = self.secondToMinuteSecond(second: self.seconds)
        animationView.play()
        
        if WWMHelperClass.step_id == 4 || WWMHelperClass.step_id == 5{
            self.combinedMantraAPI()
        }else{
            //BASS-999
            print("WWMHelperClass.timer_audio \(WWMHelperClass.timer_audio)")
            let videoAsset = AVAsset(url: URL.init(string: WWMHelperClass.timer_audio)!)
            let assetLength = Float(videoAsset.duration.value) / Float(videoAsset.duration.timescale)
            if assetLength > 0 {
                self.play(url: URL.init(string: WWMHelperClass.timer_audio)!)
                print("WWMHelperClass.timer_audio... \(WWMHelperClass.timer_audio)")
            }else{
                self.invalidURLPopUp(pushVC: "timer", title1: "Sorry something went wrong, Please try again later.")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.createColorSets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
        self.timer.invalidate()
        self.timer1.invalidate()
        self.player?.pause()
        self.stopPlayer()
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player {
            //print("stopped")
            play.pause()
            self.player = nil
            //print("player deallocated")
        } else {
            //print("player was already deallocated")
        }
    }
    
    //MARK: animated View
    func createColorSets() {
        
        colorSets.append([hexStringToUIColor(hex: "00EBA9").cgColor, hexStringToUIColor(hex: "49298A").cgColor])
        colorSets.append([hexStringToUIColor(hex: "49298A").cgColor, hexStringToUIColor(hex: "001252").cgColor])
        colorSets.append([hexStringToUIColor(hex: "001252").cgColor, hexStringToUIColor(hex: "49298A").cgColor])
        
        currentColorSet = 0
        createGradientLayer()
    }
    
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.type = .radial
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 2.0, y: 1.0)
        gradientLayer.drawsAsynchronously = true
        self.view.layer.addSublayer(gradientLayer)
        
        self.animateBool = 0
        self.timerAction(value: self.animateBool)
        timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func setUpView() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
    }
    
    @objc func timerAction(value: Int) {
        
        //print("animateBool.... \(animateBool)")
        
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        }else {
            currentColorSet = 0
        }
        
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.delegate = self
        colorChangeAnimation.duration = 4.0
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    //MARK: API call
    func combinedMantraAPI() {
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        var param: [String: Any] = [:]
        param = ["step_id": WWMHelperClass.step_id, "mantra_id": self.appPreference.getMyntraId()] as [String : Any]
        //print("param learn timer... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMBINEDMANTRA, context: "WWMLearnTimerVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [String: Any]{
                    if let audio_url = data["audio_url"] as? String{
                        //BASS-999
                        print("audio_url \(audio_url)")
                        let videoAsset = AVAsset(url: URL.init(string: audio_url)!)
                        let assetLength = Float(videoAsset.duration.value) / Float(videoAsset.duration.timescale)
                        if assetLength > 0 {
                            self.play(url: URL(string: audio_url)!)
                            print("audio_url... \(audio_url)")
                        }else{
                            DispatchQueue.main.async {
                                self.invalidURLPopUp(pushVC: "timer", title1: "Sorry something went wrong, Please try again later.")
                                return
                            }
                        }
                    }
                }
                //print("combinedMantra.... \(result)")
                
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if self.meditationLTMPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95 && self.meditationLTMPlayPercentage < Int(self.appPreference.getLearnMax_limit()) ?? 98{
            
            isComplete = 1
            let msg = WWMHelperClass.ninetyFivePercentMsg(type: "Learn")
            
            alertPopupView.btnClose.setTitle(msg.2, for: .normal)
            alertPopupView.btnOK.setTitle(msg.1, for: .normal)
            alertPopupView.lblSubtitle.text = msg.0
        }else{
            
            isComplete = 0
            alertPopupView.lblSubtitle.text = kLTMBELOWNINTEYFIVEPOPUP
        }
        
        //print("self.ninetyFiveCompletedFlag \(self.ninetyFiveCompletedFlag )")
        alertPopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.player?.play()
            self.animationView.play()
            
            if self.animateBool == 1{
                self.resumeAnimation()
                self.animateBool = 0
                self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            }
            
        }, completion: nil)
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.pauseAction()
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        
        isComplete = 0
        if self.animateBool == 1{
            self.resumeAnimation()
            self.animateBool = 0
            self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        }
        
        self.isStop = false
        self.player?.play()
        self.animationView.play()
        alertPopupView.removeFromSuperview()
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        alertPopupView.removeFromSuperview()
        
        if isComplete == 1{
            self.ninetyFiveCompletedFlag = WWMHelperClass.checkNinetyFivePercentData(type: "Learn")
        }
        
        self.pushNavigationController()
    }
    
    func pushNavigationController(){
        
        //print("ninetyFiveCompletedFlag+++ \(ninetyFiveCompletedFlag)")
        if self.ninetyFiveCompletedFlag == "0"{
            if !ismove {
                var analyticStepName = "\(WWMHelperClass.step_id)".uppercased()
                analyticStepName = analyticStepName.replacingOccurrences(of: " ", with: "_")
                var analyticStepTitle = WWMHelperClass.step_title.uppercased()
                analyticStepTitle = analyticStepTitle.replacingOccurrences(of: " ", with: "_")
                
                var audioPlayPercentageCompleteStatus = ""
                if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))){
                    if audioPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95{
                        audioPlayPercentageCompleteStatus = "_COMPLETED"
                    }
                }
                
                WWMHelperClass.sendEventAnalytics(contentType: "LEARN", itemId: "\(analyticStepName)_\(analyticStepTitle)", itemName: "\(self.totalAudioLengthAnalytics)\(audioPlayPercentageCompleteStatus)")
                
                ismove = true
                self.timer.invalidate()
                self.animationView.stop()
                self.player?.pause()
                
                self.animateBool = 1
                self.pauseAnimation()
                self.timer1.invalidate()
                
                self.completeMeditationAPI(mood_id: "0", user_id: self.appPreference.getUserID(), rest_time: "", emotion_id: "0", tell_us_why: "", prep_time: "", meditation_time: "\(Int(round((self.player?.currentTime().seconds ?? 0))))", watched_duration: "\(Int(round((self.player?.currentTime().seconds ?? 0))))", level_id: "0", complete_percentage: "\(Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))) ?? 0)", rating: "0", meditation_type: "post", category_id: "0", meditation_id: "0", date_time: "\(Int(Date().timeIntervalSince1970*1000))", type: "learn", guided_type: "", audio_id: "0", step_id: "\(WWMHelperClass.step_id)", mantra_id: self.appPreference.getMyntraId())
            }
        }else{
            self.moveToFeedBack()
        }
    }
    
    //meditationComplete
    func completeMeditationAPI(mood_id: String, user_id: String, rest_time: String, emotion_id: String, tell_us_why: String, prep_time: String, meditation_time: String, watched_duration: String, level_id: String, complete_percentage: String, rating: String, meditation_type: String, category_id: String, meditation_id: String, date_time: String, type: String, guided_type: String, audio_id: String, step_id: String, mantra_id: String) {
        
        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: "\(nintyFivePercentDB.count - 1)", type: "id")
        }
        
        var param: [String: Any] = [:]
        param = [
            "type": type,
            "step_id": step_id,
            "mantra_id": mantra_id,
            "category_id": category_id,
            "emotion_id": emotion_id,
            "audio_id": audio_id,
            "guided_type": guided_type,
            "duration" : watched_duration,
            "watched_duration": watched_duration,
            "rating": rating,
            "user_id": user_id,
            "meditation_type": meditation_type,
            "date_time": date_time,
            "tell_us_why": tell_us_why,
            "prep_time": prep_time,
            "meditation_time": meditation_time,
            "rest_time": rest_time,
            "meditation_id": meditation_id,
            "level_id": level_id,
            "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
            "complete_percentage": complete_percentage,
            "is_complete": self.ninetyFiveCompletedFlag,
            "title": "",
            "journal_type": "",
            "challenge_day_id":"",
            "challenge_type":""
        ] as [String : Any]
        
        //background thread meditation api*
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMStartTimerVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                if let _ = result["success"] as? Bool {
                    self.appPreference.setSessionAvailableData(value: true)
                    self.meditationHistoryListAPI()
                    
                    DispatchQueue.global(qos: .background).async {
                        self.getLearnAPI()
                    }
                    DispatchQueue.main.async {
                        self.navigateToDashboard()
                    }
                }else {
                    self.saveToDB(param: param)
                    DispatchQueue.main.async {
                        self.navigateToDashboard()
                    }
                }
            }else{
                self.saveToDB(param: param)
                DispatchQueue.main.async {
                    self.navigateToDashboard()
                }
            }
            
            WWMHelperClass.complete_percentage = "0"
        }//background thread meditation api*
    }
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        //self.navigateToDashboard()
    }
    
    //MeditationHistoryList API
    func meditationHistoryListAPI() {
        
        let param = ["user_id": self.appPreference.getUserID()]
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
                //print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result) success WWMGuidedMeditationTimerVC meditationhistoryapi in background thread")
            }
        }
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
    }//meditationComplete*
    
    @IBAction func btnPauseAction(_ sender: Any) {
        if !isStop {
            self.isStop = true
            self.animationView.pause()
            self.player?.pause()
        }
        
        self.animateBool = 1
        self.pauseAnimation()
        self.timer1.invalidate()
        
        if self.meditationLTMPlayPercentage < Int(self.appPreference.getLearnMax_limit()) ?? 98{
            self.xibCall()
        }else{
            self.ninetyFiveCompletedFlag = "1"
            alertPopupView.removeFromSuperview()
            self.pushNavigationController()
        }
    }
    
    func play(url:URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem:playerItem)
            
            let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
            if (duration.isNaN) || (duration.isInfinite) {
                self.totalDuration  = 0
                self.totalAudioLengthAnalytics = self.totalDuration/60
            }else{
                self.totalDuration  = Int(round(duration))
                self.totalAudioLengthAnalytics = self.totalDuration/60
            }
            
            self.totalAudioLength = self.secondToMinuteSecond(second : self.totalDuration)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            self.lblTimer.text = "\(totalAudioLength)"
            player?.volume = 1.0
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            
            player?.play()
            self.isPlayer = true
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func pauseAnimation() {
        let pausedTime = gradientLayer.convertTime(CACurrentMediaTime(), from: nil)
        gradientLayer.speed = 0
        gradientLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        let pausedTime = gradientLayer.timeOffset
        gradientLayer.speed = 1
        gradientLayer.timeOffset = 0
        gradientLayer.beginTime = 0
        let timeSincePause = gradientLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        gradientLayer.beginTime = timeSincePause
    }
    
    
    @objc func appMovedToBackground() {
        //print("App moved to background!")
        self.animationView.pause()
        
    }
    
    @objc func appMovedToForeground() {
        //print("App moved to background!")
        if KUSERDEFAULTS.string(forKey: "CallEndedIdentifier") == "true"{
            self.animationView.pause()
        }else{
            self.animationView.play()
        }
        KUSERDEFAULTS.set("", forKey: "CallEndedIdentifier")
        
    }
    
    @objc func methodOfCallEndedIdentifier(notification: Notification) {
        
        //print("call ended notification..........")
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.isStop = true
            // self.spinnerImage.layer.removeAllAnimations()
            self.animationView.pause()
            
            if self.animateBool == 1{
                self.resumeAnimation()
                self.animateBool = 0
                self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            }
            
            self.player?.pause()
        }, completion: nil)
    }
    
    @objc func updateTimer() {
        
        self.meditationLTMPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))) ?? 0
        
        if meditationLTMPlayPercentage < Int(self.appPreference.getLearnMin_limit()) ?? 95{
            self.ninetyFiveCompletedFlag = "0"
        }
        
        if meditationLTMPlayPercentage >= Int(self.appPreference.getLearnMax_limit()) ?? 98{
            self.ninetyFiveCompletedFlag = "1"
        }
        
        if meditationLTMPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95 && self.meditationLTMPlayPercentage < Int(self.appPreference.getLearnMax_limit()) ?? 98{
            
            self.ninetyFiveCompletedFlag = WWMHelperClass.checkNinetyFivePercentData(type: "Learn")
        }
        
        if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))){
            if audioPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95{
                self.fetchStepsDataFromDB()
            }
        }
        
        var watched_duration = "0"
        var complete_percentage = 0
        if self.player?.currentTime().seconds != nil{
            watched_duration = "\(Int(round((self.player?.currentTime().seconds ?? 0))))"
            complete_percentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))) ?? 0
        }
        
        //offline for meditation to insert into database
        offlineCompleteData["type"] = "learn"
        offlineCompleteData["step_id"] = WWMHelperClass.step_id
        offlineCompleteData["mantra_id"] = self.appPreference.getMyntraId()
        offlineCompleteData["category_id"] = "0"
        offlineCompleteData["emotion_id"] = "0"
        offlineCompleteData["audio_id"] = "0"
        offlineCompleteData["guided_type"] = ""
        offlineCompleteData["watched_duration"] = watched_duration
        offlineCompleteData["rating"] = "0"
        offlineCompleteData["user_id"] = self.appPreference.getUserID()
        offlineCompleteData["meditation_type"] = "post"
        offlineCompleteData["date_time"] = "\(Int(Date().timeIntervalSince1970*1000))"
        offlineCompleteData["tell_us_why"] = ""
        offlineCompleteData["prep_time"] = ""
        offlineCompleteData["meditation_time"] = watched_duration
        offlineCompleteData["rest_time"] = ""
        offlineCompleteData["meditation_id"] = "0"
        offlineCompleteData["level_id"] = "0"
        offlineCompleteData["mood_id"] = "0"
        offlineCompleteData["complete_percentage"] = complete_percentage
        offlineCompleteData["is_complete"] = self.ninetyFiveCompletedFlag
        
        if !self.dataAppendFlag{
            self.addNintyFiveCompletionDataFromDB(dict: offlineCompleteData)
        }else{
            let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
            if nintyFivePercentDB.count > 0{
                self.updateNintyFiveCompletionDataFromDB(id: "\(nintyFivePercentDB.count - 1)", data: offlineCompleteData)
            }
            
        }//offline data meditation*
        
        if isPlayer {
            if self.totalAudioLength != ""{
                //print("totalaudiolength... \(self.totalDuration) currentTime... \(self.player!.currentTime().seconds)")
                self.watched_duration = Int(round(self.player!.currentTime().seconds))
                let remainingTime = self.totalDuration - Int(round(self.player!.currentTime().seconds))
                self.lblTimer.text = self.secondToMinuteSecond(second: remainingTime)
            }
        }
    }
    
    //offline data for meditation
    func addNintyFiveCompletionDataFromDB(dict: [String: Any]) {
        
        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        
        let dbNintyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNintyFiveCompletionData") as! DBNintyFiveCompletionData
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbNintyFivePercent.data = myString
        dbNintyFivePercent.id = "\(nintyFivePercentDB.count)"
        WWMHelperClass.saveDb()
        self.dataAppendFlag = true
    }
    
    func updateNintyFiveCompletionDataFromDB(id: String, data: [String: Any]){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "DBNintyFiveCompletionData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let fetchResults = try? appDelegate.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
            if fetchResults?.count != 0 {
                // update
                let managedObject = fetchResults?[0]
                
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: data, options:.prettyPrinted)
                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                
                managedObject?.setValue(myString, forKey: "data")
                managedObject?.setValue(id, forKey: "id")
                
                WWMHelperClass.saveDb()
            }
        }
    }
    
    //MARK: Fetch Steps Data From DB
    func fetchStepsDataFromDB() {
        let getStepsDataDB = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
        
        if getStepsDataDB.count > 0 {
            //print("self.stepFaqDataDB... \(getStepsDataDB.count)")
            //self.arrImages.removeAll()
            
            for dict in getStepsDataDB {
                
                //print("dict.id... \(dict.id ?? "") WWMHelperClass.step_id... \(WWMHelperClass.step_id)")
                if dict.id == "\(WWMHelperClass.step_id)"{
                    
                    dict.completed = true
                    let dateFormatter = DateFormatter()
                    //                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.locale = Locale.current
                    dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let currentDateString = dateFormatter.string(from: Date())
                    dict.date_completed = "\(currentDateString)"
                    
                    //print("faq current date string... \(currentDateString) dict.date_completed... \(dict.date_completed ?? "nothing")")
                    WWMHelperClass.saveDb()
                }
            }
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        if !ismove {
            //for 95% LTM
            ismove = true
            self.timer.invalidate()
            self.animationView.stop()
            self.player?.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            //for analytics
            var analyticStepName = "\(WWMHelperClass.step_id)".uppercased()
            analyticStepName = analyticStepName.replacingOccurrences(of: " ", with: "_")
            var analyticStepTitle = WWMHelperClass.step_title.uppercased()
            analyticStepTitle = analyticStepTitle.replacingOccurrences(of: " ", with: "_")
            
            var audioPlayPercentageCompleteStatus = ""
            if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round(self.player!.currentTime().seconds)))){
                if audioPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95{
                    audioPlayPercentageCompleteStatus = "_COMPLETED"
                }
            }
            
            WWMHelperClass.sendEventAnalytics(contentType: "LEARN", itemId: "\(analyticStepName)_\(analyticStepTitle)", itemName: "\(self.totalAudioLengthAnalytics)\(audioPlayPercentageCompleteStatus)")
            
            
            if WWMHelperClass.outro_audio != ""{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnOutroVC") as! WWMLearnOutroVC
                
                self.appPreference.setType(value: "learn")
                vc.watched_duration = "\(self.watched_duration)"
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
                
                self.appPreference.setType(value: "learn")
                vc.watched_duration = "\(self.watched_duration)"
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    func convertDurationIntoPercentage(duration:Int) -> String  {
        if ((self.player?.currentItem?.duration) != nil) {
            let totalTime = CMTimeGetSeconds(((self.player?.currentItem!.duration)!))
            let per = (Double(duration)/totalTime)*100
            
            guard !(per.isNaN || per.isInfinite) else {
                return "0" // or do some error handling
            }
            
            WWMHelperClass.complete_percentage = "\(Int(per))"
            
            return "\(Int(per))"
        }
        return "0"
    }
    
    func moveToFeedBack() {
        if !ismove {
            var analyticStepName = "\(WWMHelperClass.step_id)".uppercased()
            analyticStepName = analyticStepName.replacingOccurrences(of: " ", with: "_")
            var analyticStepTitle = WWMHelperClass.step_title.uppercased()
            analyticStepTitle = analyticStepTitle.replacingOccurrences(of: " ", with: "_")
            
            
            var audioPlayPercentageCompleteStatus = ""
            if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds ?? 0))))){
                if audioPlayPercentage >= Int(self.appPreference.getLearnMin_limit()) ?? 95{
                    audioPlayPercentageCompleteStatus = "_COMPLETED"
                }
            }
            
            WWMHelperClass.sendEventAnalytics(contentType: "LEARN", itemId: "\(analyticStepName)_\(analyticStepTitle)", itemName: "\(self.totalAudioLengthAnalytics)\(audioPlayPercentageCompleteStatus)")
            
            ismove = true
            self.timer.invalidate()
            self.animationView.stop()
            self.player?.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            if WWMHelperClass.outro_audio != ""{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnOutroVC") as! WWMLearnOutroVC
                
                self.appPreference.setType(value: "learn")
                vc.watched_duration = "\(self.watched_duration)"
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
                
                self.appPreference.setType(value: "learn")
                vc.watched_duration = "\(self.watched_duration)"
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    func pauseAction() {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.isStop = true
            self.animationView.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            self.player?.pause()
        }, completion: nil)
    }
}


extension WWMLearnTimerVC: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
            self.resumeAnimation()
        }
    }
}
