//
//  WWMGuidedMeditationTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 23/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie
import CoreData

class WWMGuidedMeditationTimerVC: WWMBaseViewController {
    
    var seconds = 0
    var timer = Timer()
    var isStop = false
    var player: AVPlayer?
    var settingData = DBSettings()
    var audioData = WWMGuidedAudioData()
    var notificationCenter = NotificationCenter.default
    var isPlayer = false
    var cat_id = "0"
    var cat_Name = ""
    var emotion_Id = "0"
    var emotion_Name = ""
    var isFavourite = false
    var rating = 0
    var totalDuration: Int = 0
    var totalTime = 0
    
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblGuidedFlowType: UILabel!
    @IBOutlet weak var lblGuidedName: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var btnFavourite: UIButton!
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var timer1 = Timer()
    var animateBool: Int = 0
    
    var animationView = AnimationView()
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var viewLottieAnimation: UIView!
    
    var nintyFivedata: [DBNintyFiveCompletionData] = []
    
    //for offline meditation data parameters
    var offlineCompleteData: [String: Any] = [:]
    var meditationGuidedPlayPercentage = 0
    var dataAppendFlag = false
    var ismove = false
    var ninetyFiveCompletedFlag = "1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("self.min_limit++ \(min_limit) self.max_limit++ \(max_limit) self.meditation_key++ \(meditation_key)")
        
        WWMHelperClass.addNinetyFivePercentData(type: self.meditation_key)
        
        self.viewLottieAnimation.isHidden = true
        spinnerImage.isHidden = true
        
        self.totalTime = self.seconds
        
        animationView = AnimationView(name: "all_discs")
        animationView.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        animationView.alpha = 0.15
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        backView.insertSubview(animationView, belowSubview: viewPause)
        
        
        
//        animationView = AnimationView(name: "final1")
//        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//        //animationView.center = self.viewLottieAnimation.center
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = .loop
//        viewLottieAnimation.addSubview(animationView)
        
        animationView.play()
        
        
        self.setUpView()
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.methodOfCallEndedIdentifier(notification:)), name: Notification.Name("NotificationCallEndedIdentifier"), object: nil)

        self.play(url: URL.init(string: self.audioData.audio_Url)!)
        self.lblTimer.text = self.secondsToMinutesSeconds(second: self.seconds)
        self.lblGuidedName.text = "\(self.audioData.audio_Name) \(self.audioData.author_name)"

        print(self.appPreference.getGuideType())
        if self.appPreference.getGuideType() == "practical" {
            self.lblGuidedFlowType.text = "\(KPRACTICAL) ~ \(self.cat_Name) ~ \(self.emotion_Name)"
        }else {
            self.lblGuidedFlowType.text = "\(KSPIRITUAL) ~ \(self.cat_Name) ~ \(self.emotion_Name)"
        }
        if self.audioData.vote {
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }
        
        self.appPreference.setMoodId(value: "")
    }
    
    
    func play(url:URL) {
        print("playing \(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem:playerItem)
            
            let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
            self.totalDuration  = Int(round(duration)/60)
            print("totalDuration... \(totalDuration)")
            
            player?.volume = 1.0
            player?.play()
            self.isPlayer = true
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @objc func methodOfCallEndedIdentifier(notification: Notification) {
        
        print("call ended notification..........")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
        self.player?.pause()
        self.timer1.invalidate()
        self.timer.invalidate()
        self.stopPlayer()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.createColorSets()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player {
            print("stopped")
            play.pause()
            player = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
        }
    }
    
    
    //MARK: animated View
    
    func createColorSets() {
//        colorSets.append([hexStringToUIColor(hex: "FF3A49").cgColor, hexStringToUIColor(hex: "49298A").cgColor, hexStringToUIColor(hex: "FFC02F").cgColor])
//        colorSets.append([hexStringToUIColor(hex: "001252").cgColor, hexStringToUIColor(hex: "49298A").cgColor, hexStringToUIColor(hex: "FF3A49").cgColor])
//        colorSets.append([hexStringToUIColor(hex: "00EBA9").cgColor, hexStringToUIColor(hex: "49298A").cgColor, hexStringToUIColor(hex: "001252").cgColor])
        
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
        //0 0 1 1
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 2.0, y: 1.0)
        gradientLayer.drawsAsynchronously = true
        self.view.layer.addSublayer(gradientLayer)
        
        self.animateBool = 0
        self.timerAction(value: self.animateBool)
        timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction(value: Int) {
        
        print("animateBool.... \(animateBool)")
        
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        }
        else {
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
    
    
    func setUpView() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        self.animationView.pause()
        
    }
    
    @objc func appMovedToForeground() {
        print("App moved to background!")
        if KUSERDEFAULTS.string(forKey: "CallEndedIdentifier") == "true"{
            self.animationView.pause()
        }else{
            self.animationView.play()
        }
        KUSERDEFAULTS.set("", forKey: "CallEndedIdentifier")
        
    }
    
    @objc func updateTimer() {
        if isPlayer {
            
            self.meditationGuidedPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!)))) ?? 0
            
            print("self.meditationGuidedPlayPercentage... \(self.meditationGuidedPlayPercentage)")
            
            //offline for meditation to insert into database
            offlineCompleteData["type"] = "guided"
            offlineCompleteData["step_id"] = ""
            offlineCompleteData["mantra_id"] = ""
            offlineCompleteData["category_id"] = "\(self.cat_id)"
            offlineCompleteData["emotion_id"] = "\(self.emotion_Id)"
            offlineCompleteData["audio_id"] = "\(audioData.audio_Id)"
            offlineCompleteData["guided_type"] = self.appPreference.getGuideType()
            offlineCompleteData["watched_duration"] = "\(Int(round((self.player?.currentTime().seconds)!)))"
            offlineCompleteData["rating"] = "\(self.rating)"
            offlineCompleteData["user_id"] = self.appPreference.getUserID()
            offlineCompleteData["meditation_type"] = "post"
            offlineCompleteData["date_time"] = "\(Int(Date().timeIntervalSince1970*1000))"
            offlineCompleteData["tell_us_why"] = ""
            offlineCompleteData["prep_time"] = ""
            offlineCompleteData["meditation_time"] = Int(round((self.player?.currentTime().seconds)!))
            offlineCompleteData["rest_time"] = ""
            offlineCompleteData["meditation_id"] = "0"
            offlineCompleteData["level_id"] = "0"
            offlineCompleteData["mood_id"] = "0"
            offlineCompleteData["complete_percentage"] = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!))))
             
            if !self.dataAppendFlag{
                self.addNintyFiveCompletionDataFromDB(dict: offlineCompleteData)
            }else{
                let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
                if nintyFivePercentDB.count > 0{
                    self.updateNintyFiveCompletionDataFromDB(id: "\(nintyFivePercentDB.count - 1)", data: offlineCompleteData)
                    
                    print("nintyFivePercentDB... \(nintyFivePercentDB.count)")
                }
                
                print("nintyFivePercentDB...++++ \(nintyFivePercentDB.count)")
            }//offline data meditation*
            
            if meditationGuidedPlayPercentage < Int(self.min_limit) ?? 95{
                self.ninetyFiveCompletedFlag = "0"
            }
            
            if meditationGuidedPlayPercentage >= Int(self.max_limit) ?? 98{
                self.ninetyFiveCompletedFlag = "1"
            }
            
            let remainingTime = self.seconds - Int((self.player?.currentTime().seconds)!)
            self.lblTimer.text = self.secondsToMinutesSeconds(second: remainingTime)
            if remainingTime == 0 {
                self.moveToFeedBack()
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
        
        print("id+++++ \(id) data+++++ \(data)")
        
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
    
    func convertDurationIntoPercentage(duration:Int) -> String  {
        if ((self.player?.currentItem?.duration) != nil) {
            let totalTime = Double(self.totalTime)
            print("totalTime...++++ \(totalTime)")
            
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
            
            //For analytics
            var analyticCatName = self.cat_Name.uppercased()
            analyticCatName = analyticCatName.replacingOccurrences(of: " ", with: "_")
            var analyticEmotionName = self.emotion_Name.uppercased()
            analyticEmotionName = analyticEmotionName.replacingOccurrences(of: " ", with: "_")
            
            var audioPlayPercentageCompleteStatus = ""
            if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!)))){
                if audioPlayPercentage >= Int(self.min_limit) ?? 95{
                    audioPlayPercentageCompleteStatus = "_COMPLETED"
                }
            }
            
            
            if self.appPreference.getGuideType() == "practical" {
                if self.rating == 1 {
                    WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_PRACTICAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "LIKE")
                }
                WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_PRACTICAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "\(self.totalDuration)\(audioPlayPercentageCompleteStatus)")
                
                
            }else {
                if self.rating == 1 {
                    WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_SPIRITUAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "LIKE")
                }
                WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_SPIRITUAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "\(self.totalDuration)\(audioPlayPercentageCompleteStatus)")
            }
            
            ismove = true
            self.timer.invalidate()
            self.animationView.stop()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            //save in database
            let guidedAudioDataDB = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
            for dict1 in guidedAudioDataDB{
                if dict1.emotion_id == self.emotion_Id{
                    if self.rating == 1{
                        dict1.vote = true
                    }else{
                        dict1.vote = false
                    }
                    WWMHelperClass.saveDb()
                }
            }
            
            //to push view controllers
            if self.settingData.moodMeterEnable {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
                vc.type = "post"
                vc.meditationID = "0"
                vc.levelID = "0"
                vc.category_Id = self.cat_id
                vc.emotion_Id = self.emotion_Id
                vc.audio_Id = "\(audioData.audio_Id)"
                vc.rating = "\(self.rating)"
                vc.watched_duration = "\(Int(round((self.player?.currentTime().seconds)!)))"
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
                vc.type = "post"
                vc.prepTime = 0
                vc.meditationTime = 0
                vc.restTime = 0
                vc.meditationID = "0"
                vc.levelID = "0"
                vc.category_Id = self.cat_id
                vc.emotion_Id = self.emotion_Id
                vc.audio_Id = "\(audioData.audio_Id)"
                vc.rating = "\(self.rating)"
                vc.watched_duration = "\(Int(round((self.player?.currentTime().seconds)!)))"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func fetchNintyFiveCompletionDataFromDB() {
        
        //self.data.removeAll()
         let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
         if nintyFivePercentDB.count > 0 {

            for dict in nintyFivePercentDB {
                let dbNintyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNintyFiveCompletionData") as! DBNintyFiveCompletionData
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                dbNintyFivePercent.data = myString
                WWMHelperClass.saveDb()
            }
        }
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
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
    
    // MARK:- Button Action
    
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
    
    @IBAction func btnFavouriteAction(_ sender: Any) {
        if !isFavourite {
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }else {
            isFavourite = false
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
            self.rating = 0
        }
    }
    
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if self.meditationGuidedPlayPercentage >= Int(self.min_limit) ?? 95 && self.meditationGuidedPlayPercentage < Int(self.max_limit) ?? 98{
            
            self.ninetyFiveCompletedFlag = WWMHelperClass.checkNinetyFivePercentData(type: self.meditation_key)
            alertPopupView.lblSubtitle.text = kLTMABOVENINTEYFIVEPOPUP
        }else{
            alertPopupView.lblSubtitle.text = kLTMBELOWNINTEYFIVEPOPUP
        }
        
        print("self.ninetyFiveCompletedFlag \(self.ninetyFiveCompletedFlag )")
        alertPopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        
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
        
        self.pushNavigationController()
    }
    
    func pushNavigationController(){
        
        print("ninetyFiveCompletedFlag+++ \(ninetyFiveCompletedFlag)")
        if self.ninetyFiveCompletedFlag == "0"{
            if !ismove{
                //For analytics
                var analyticCatName = self.cat_Name.uppercased()
                analyticCatName = analyticCatName.replacingOccurrences(of: " ", with: "_")
                var analyticEmotionName = self.emotion_Name.uppercased()
                analyticEmotionName = analyticEmotionName.replacingOccurrences(of: " ", with: "_")
                
                var audioPlayPercentageCompleteStatus = ""
                if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!)))){
                    if audioPlayPercentage >= Int(self.min_limit) ?? 95{
                        audioPlayPercentageCompleteStatus = "_COMPLETED"
                    }
                }
                
                if self.appPreference.getGuideType() == "practical" {
                    if self.rating == 1 {
                        WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_PRACTICAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "LIKE")
                    }
                    WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_PRACTICAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "\(self.totalDuration)\(audioPlayPercentageCompleteStatus)")
                    
                    
                }else {
                    if self.rating == 1 {
                        WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_SPIRITUAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "LIKE")
                    }
                    WWMHelperClass.sendEventAnalytics(contentType: "GUIDED_SPIRITUAL", itemId: "\(analyticCatName)_\(analyticEmotionName)", itemName: "\(self.totalDuration)\(audioPlayPercentageCompleteStatus)")
                }
                
                ismove = true
                self.timer.invalidate()
                self.animationView.stop()
                
                self.animateBool = 1
                self.pauseAnimation()
                self.timer1.invalidate()
                
                //save in database
                let guidedAudioDataDB = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                for dict1 in guidedAudioDataDB{
                    if dict1.emotion_id == self.emotion_Id{
                        if self.rating == 1{
                            dict1.vote = true
                        }else{
                            dict1.vote = false
                        }
                        WWMHelperClass.saveDb()
                    }
                }
                
                self.completeMeditationAPI(mood_id: "0", user_id: self.appPreference.getUserID(), rest_time: "", emotion_id: "\(self.emotion_Id)", tell_us_why: "", prep_time: "", meditation_time: "\(Int(round((self.player?.currentTime().seconds)!)))", watched_duration: "\(Int(round((self.player?.currentTime().seconds)!)))", level_id: "0", complete_percentage: "\(Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!)))) ?? 0)", rating: "\(self.rating)", meditation_type: "post", category_id: "\(self.cat_id)", meditation_id: "0", date_time: "\(Int(Date().timeIntervalSince1970*1000))", type: "guided", guided_type: self.appPreference.getGuideType(), audio_id: "\(audioData.audio_Id)", step_id: "", mantra_id: "")
                
            }//ismovefinish
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
        if type == "learn"{
            param = [
                "type": type,
                "step_id": step_id,
                "mantra_id": mantra_id,
                "category_id" : category_id,
                "emotion_id" : emotion_id,
                "audio_id" : audio_id,
                "guided_type" : guided_type,
                "duration" : watched_duration,
                "rating" : rating,
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
                "complete_percentage": complete_percentage
                ] as [String : Any]
        }else{
            param = [
                "type": type,
                "category_id": category_id,
                "emotion_id": emotion_id,
                "audio_id": audio_id,
                "guided_type": guided_type,
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
                "complete_percentage": complete_percentage
                ] as [String : Any]
        }
        
        print("meter param WWMGuidedMeditationTimerVC... \(param)")
        
        //background thread meditation api*
        DispatchQueue.global(qos: .background).async {
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMStartTimerVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    
                    if let _ = result["success"] as? Bool {
                        print("success... WWMGuidedMeditationTimerVC meditationcomplete api in background")
                        self.appPreference.setSessionAvailableData(value: true)
                        self.meditationHistoryListAPI()
                        
                        WWMHelperClass.complete_percentage = "0"
                        //self.navigateToDashboard()
                    }else {
                        self.saveToDB(param: param)
                    }
                }else{
                    self.saveToDB(param: param)
                }
            }//background thread meditation api*
            
            DispatchQueue.main.async {
                self.navigateToDashboard()
            }
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
                print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result)")
                print("success WWMGuidedMeditationTimerVC meditationhistoryapi in background thread")
            }
        }
    }
    
    
    func navigateToDashboard() {
        
        self.navigationController?.isNavigationBarHidden = false
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 2 {
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
        
        if self.meditationGuidedPlayPercentage < Int(self.max_limit) ?? 98{
            self.xibCall()
        }else{
            self.ninetyFiveCompletedFlag = "1"
            alertPopupView.removeFromSuperview()
            self.pushNavigationController()
        }
    }
}

extension WWMGuidedMeditationTimerVC: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
            self.resumeAnimation()
        }
    }
}
