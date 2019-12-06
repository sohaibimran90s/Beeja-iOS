//
//  WWMStartTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie
import CoreData

class WWMStartTimerVC: WWMBaseViewController {

    let appPreffrence = WWMAppPreference()
    var seconds = 0
    var timer = Timer()
    var isStop = false
    var timerType = "Prep"
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    
    var meditationTimeAnalytics = 0
    var meditationTimeSecondsAnalytics = 0
    
    
    var meditationID = ""
    var levelID = ""
    var meditationName = ""
    var levelName = ""
    var player: AVAudioPlayer?
    var playerAmbient: AVAudioPlayer?
   // var playerSlient: AVAudioPlayer?
    var settingData = DBSettings()
 
    var isAmbientSoundPlay = false
    var notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblTimerType: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var timer1 = Timer()
    var animateBool: Int = 0
    
    var animationViewMed = AnimationView()
    var animationViewPrep = AnimationView()
    var animationViewRest = AnimationView()
    
    var updateBgTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var flag = 0
    var meditationPlayPercentageCompleteStatus = ""
    var meditationPlayPercentage = 0
    
    var backgroundFlag = false
    //var meditationLTMTime = 0
    var meditationLTMTimeFlag = false
    var offlineCompleteData: [String: Any] = [:]
    var meditationLTMPlayPercentage = 0
    var dataAppendFlag = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        animationViewMed = AnimationView(name: "final1")
        animationViewMed.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        animationViewMed.center = self.view.center
        animationViewMed.contentMode = .scaleAspectFill
        animationViewMed.loopMode = .loop
        view.insertSubview(animationViewMed, belowSubview: viewPause)
        
        animationViewRest = AnimationView(name: "circle_loader")
        animationViewRest.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        animationViewRest.center = self.view.center
        animationViewRest.contentMode = .scaleAspectFill
        animationViewRest.loopMode = .loop
        view.insertSubview(animationViewRest, belowSubview: viewPause)
        
        animationViewPrep = AnimationView(name: "all_discs")
        animationViewPrep.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        animationViewPrep.alpha = 0.15
        animationViewPrep.center = self.view.center
        animationViewPrep.contentMode = .scaleAspectFill
        animationViewPrep.loopMode = .loop
        backView.insertSubview(animationViewPrep, belowSubview: viewPause)
        
        animationViewPrep.isHidden = false
        animationViewMed.isHidden = true
        animationViewRest.isHidden = true
        
        animationViewPrep.play()

        spinnerImage.isHidden = true
        self.setUpView()
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
         notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.methodOfCallEndedIdentifier(notification:)), name: Notification.Name("NotificationCallEndedIdentifier"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.createColorSets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
        self.playerAmbient?.stop()
        self.timer1.invalidate()
        self.timer.invalidate()
        //self.playerSlient?.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //MARK: Run timer in background
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addObserver()
    }
    
    //register background task
    func registerBackgroundTask(){
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil); assert(self.backgroundTask != .invalid)
    }
    
    //end background task
    func endBackgroundTask(){
        if backgroundTask != .invalid{
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }
    
    func addObserver(){
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func didEnterBackground(){
        registerBackgroundTask()
        if self.updateBgTimer == nil && self.backgroundTask == .invalid{
            self.updateBgTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerInBackground), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimerInBackground(){
        switch UIApplication.shared.applicationState {
        case .active:
            print("active state")
            
            self.updateBgTimer?.invalidate()
            self.updateBgTimer = nil
            self.endBackgroundTask()
            
        case .background:
            print("backgrond state")
            updateTimer()
        default:
            print("default state")
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
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        
        self.appPreffrence.setMeditationLTMTimeFlag(value: true)
        
        self.animationViewMed.pause()
        self.animationViewPrep.pause()
        self.animationViewRest.pause()
        self.updateTimer()
    }
    
    @objc func appMovedToForeground() {
        
        print("App moved to background!")
        if KUSERDEFAULTS.string(forKey: "CallEndedIdentifier") == "true"{
            self.animationViewMed.pause()
            self.animationViewPrep.pause()
            self.animationViewRest.pause()
        }else{
            self.animationViewMed.play()
            self.animationViewPrep.play()
            self.animationViewRest.play()
        }
        KUSERDEFAULTS.set("", forKey: "CallEndedIdentifier")
    }
    
    func setUpView() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        
        if let arrMeditationData = settingData.meditationData?.array as?  [DBMeditationData] {
            for data in arrMeditationData {
                if data.isMeditationSelected {
                    if !(data.meditationName == "Beeja" || data.meditationName == "Vedic/Transcendental") {
                        isAmbientSoundPlay = true
                    }
                    
                }
            }
        }
        
        self.meditationTimeAnalytics = self.meditationTime
        
        if self.prepTime > 0 {
            self.seconds = self.prepTime
            lblTimerType.text = "Prep"
            timerType = "Prep"
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else if self.meditationTime > 0 {
            self.lblTimerType.text = "Meditation"
            self.timerType = "Meditation"
            self.seconds = self.meditationTime
            self.playAudioFile(fileName: settingData.startChime ?? kChimes_BURMESE_BELL)
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else if self.restTime > 0 {
            self.lblTimerType.text = "Rest"
            self.timerType = "Rest"
            self.seconds = self.restTime
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else {
            self.timerType = ""
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
            
            if flag == 1{
                WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\( meditationPlayPercentageCompleteStatus)")
            }else{
                WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\(self.meditationPlayPercentage)")
            }

            
            vc.meditationMaxTime = self.meditationTime
            vc.meditationName = self.meditationName
            vc.levelName = self.levelName
            vc.type = "post"
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            
            
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if isAmbientSoundPlay {
            self.playAmbientSoundAudioFile(fileName: settingData.ambientChime!)
        }else {
            self.playAmbientSoundAudioFile(fileName: "slient")
        }
        //self.playSlientAudioFile(fileName: "slient")
        runTimer()
    }

    
    
    @objc func methodOfCallEndedIdentifier(notification: Notification) {
        
        print("call ended notification..........")
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.timer.invalidate()
            self.isStop = true
            self.playerAmbient?.stop()
            self.animationViewMed.pause()
            self.animationViewPrep.pause()
            self.animationViewRest.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
        }, completion: nil)
    }
    
    func playAudioFile(fileName:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
//    func playSlientAudioFile(fileName:String) {
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            playerSlient = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            /* iOS 10 and earlier require the following line:
//             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//
//
//                playerSlient?.play()
//                playerSlient?.numberOfLoops = -1
//
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    func playAmbientSoundAudioFile(fileName:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            playerAmbient = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
                playerAmbient?.play()
                playerAmbient?.numberOfLoops = -1
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    
    //#selector(self.updateTimer)
    @objc func updateTimer() {
        print("seconds... \(seconds)")
        if timerType == "Prep"{
            if self.seconds < 1 {
                if self.meditationTime > 0 {
                    self.animationViewPrep.stop()
                    self.animationViewPrep.isHidden = true
                    self.animationViewMed.isHidden = false
                    self.animationViewRest.isHidden = true
                    self.animationViewMed.play()
                    
                    self.lblTimerType.text = "Meditation"
                    self.timerType = "Meditation"
                    self.seconds = self.meditationTime
                    self.playAudioFile(fileName: settingData.startChime ?? kChimes_BURMESE_BELL)
                }else if self.restTime > 0 {
                    self.lblTimerType.text = "Rest"
                    self.timerType = "Rest"
                    self.seconds = self.restTime
                    self.playAudioFile(fileName: settingData.endChime ?? kChimes_JaiGuruDev)
                }else {
                    self.playAudioFile(fileName: settingData.finishChime ?? kChimes_HARP)
                    self.timer.invalidate()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                    
                    if flag == 1{
                        WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\( meditationPlayPercentageCompleteStatus)")
                    }else{
                        WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\(self.meditationPlayPercentage)")
                    }

                    
                    vc.meditationMaxTime = self.meditationTime
                    vc.meditationName = self.meditationName
                    vc.levelName = self.levelName
                    vc.type = "post"
                    vc.prepTime = self.prepTime
                    vc.meditationTime = 0
                    vc.restTime = 0
                    
                    vc.meditationID = self.meditationID
                    vc.levelID = self.levelID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
                seconds = seconds-1
                self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
            
        }else if timerType == "Meditation"{
            if self.seconds < 1 {
                if self.restTime > 0 {
                    self.animationViewMed.stop()
                    self.animationViewPrep.stop()
                    self.animationViewMed.isHidden = true
                    self.animationViewPrep.isHidden = true
                    self.animationViewRest.isHidden = false
                    self.animationViewRest.play()
                    
                    self.lblTimerType.text = "Rest"
                    self.timerType = "Rest"
                    self.seconds = self.restTime
                    self.playAudioFile(fileName: settingData.endChime ?? kChimes_JaiGuruDev)
                }else {
                    self.playAudioFile(fileName: settingData.finishChime ?? kChimes_HARP)
                    self.timer.invalidate()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                    
                    if flag == 1{
                        WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\( meditationPlayPercentageCompleteStatus)")
                    }else{
                        WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\(self.meditationPlayPercentage)")
                    }

                    
                    vc.meditationMaxTime = self.meditationTime
                    vc.meditationName = self.meditationName
                    vc.levelName = self.levelName
                    vc.type = "post"
                    vc.prepTime = self.prepTime
                    vc.meditationTime = self.meditationTime
                    vc.restTime = 0
                    
                    vc.meditationID = self.meditationID
                    vc.levelID = self.levelID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                if self.seconds == self.meditationTime/2+1 {
                    if isAmbientSoundPlay {
                        self.playAudioFile(fileName: settingData.intervalChime ?? kChimes_CONCH)
                    }
                }
            }
            seconds = seconds-1
            
            //convertDurationIntoPercentage
            self.meditationTimeSecondsAnalytics = self.meditationTimeAnalytics - seconds
            print("self.meditationTimeSecondsAnalytics++++ \(self.meditationTimeSecondsAnalytics)")
            
            //for 95% LTM
        
            
            
            if let meditationPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round(Double( self.meditationTimeSecondsAnalytics))))){
                
                self.meditationLTMPlayPercentage = meditationPlayPercentage
                if meditationPlayPercentage < 95{
                    
                }else if meditationPlayPercentage < 98{
                    
                }else{
                    
                }
            }
            
            //to insert into database
            offlineCompleteData["type"] = "timer"
            offlineCompleteData["category_id"] = "0"
            offlineCompleteData["emotion_id"] = "0"
            offlineCompleteData["audio_id"] = "0"
            offlineCompleteData["guided_type"] = ""
            offlineCompleteData["watched_duration"] = "0"
            offlineCompleteData["rating"] = "0"
            offlineCompleteData["user_id"] = self.appPreference.getUserID()
            offlineCompleteData["meditation_type"] = "post"
            offlineCompleteData["date_time"] = "\(Int(Date().timeIntervalSince1970*1000))"
            offlineCompleteData["tell_us_why"] = ""
            offlineCompleteData["prep_time"] = self.prepTime
            offlineCompleteData["meditation_time"] = self.meditationTime
            offlineCompleteData["rest_time"] = self.restTime
            offlineCompleteData["meditation_id"] = self.meditationID
            offlineCompleteData["level_id"] = self.levelID
            offlineCompleteData["mood_id"] = "0"
            offlineCompleteData["complete_percentage"] = self.meditationLTMPlayPercentage
             
            if !self.dataAppendFlag{
                self.addNintyFiveCompletionDataFromDB(dict: offlineCompleteData)
            }else{
                let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
                if nintyFivePercentDB.count > 0{
                    self.updateNintyFiveCompletionDataFromDB(id: "\(nintyFivePercentDB.count - 1)", data: offlineCompleteData)
                }
                
                print("nintyFivePercentDB... \(nintyFivePercentDB.count)")
            }
            
            //analytics
            if let meditationPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round(Double( self.meditationTimeSecondsAnalytics))))){
                if meditationPlayPercentage >= 95{
                    self.meditationPlayPercentageCompleteStatus = "_COMPLETED"
                    self.flag = 1
                }else{
                    self.meditationPlayPercentage = meditationPlayPercentage
                }
            }
            
            
            print("self.meditationTimeAnalytics... \(self.meditationTimeAnalytics) meditationTimeSecondsAnalytics... \(self.meditationTimeSecondsAnalytics)")
            
            self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
        }else if timerType == "Rest"{
            if self.seconds < 1 {
                self.playAudioFile(fileName: settingData.finishChime ?? kChimes_HARP)
                self.timer.invalidate()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                
                if flag == 1{
                    WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\( meditationPlayPercentageCompleteStatus)")
                }else{
                    WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\(self.meditationPlayPercentage)")
                }
                
                vc.meditationMaxTime = self.meditationTime
                vc.meditationName = self.meditationName
                vc.levelName = self.levelName
                vc.type = "post"
                vc.prepTime = self.prepTime
                vc.meditationTime = self.meditationTime
                vc.restTime = self.restTime
                
                vc.meditationID = self.meditationID
                vc.levelID = self.levelID
                self.navigationController?.pushViewController(vc, animated: true)
            }
                seconds = seconds-1
                self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }
    }
    
    
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
    
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    func pauseAction() {
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.timer.invalidate()
            self.isStop = true
            self.playerAmbient?.stop()
            //self.playerSlient?.stop()
            self.animationViewMed.pause()
            self.animationViewPrep.pause()
            self.animationViewRest.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
        }, completion: nil)
    }
    // MARK:- Button Action
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.runTimer()
            if self.isAmbientSoundPlay {
                self.playerAmbient?.play()
            }
           // self.playerSlient?.play()
            self.animationViewMed.play()
            self.animationViewPrep.play()
            self.animationViewRest.play()
            
            if self.animateBool == 1{
                self.resumeAnimation()
                self.animateBool = 0
                self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            }
            
        }, completion: nil)
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.pauseAction()
       // self.spinnerImage.layer.removeAllAnimations()
    }
    
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        
        alertPopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        
        if animateBool == 1{
            self.resumeAnimation()
            self.animateBool = 0
            self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
        self.isStop = false
        self.runTimer()
        if self.isAmbientSoundPlay {
            self.playerAmbient?.play()
        }
        //self.playerSlient?.play()
        self.animationViewMed.play()
        self.animationViewPrep.play()
        self.animationViewRest.play()
        alertPopupView.removeFromSuperview()
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
         alertPopupView.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
        
        print("self.meditationTimeAnalytics... \(self.meditationTimeAnalytics) meditationTimeSecondsAnalytics... \(self.meditationTimeSecondsAnalytics)")
        
        if flag == 1{
            WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\( meditationPlayPercentageCompleteStatus)")
        }else{
            WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "BEEJA_BEGINNER", itemName: "\(self.meditationPlayPercentage)")
        }
        
        vc.meditationMaxTime = self.meditationTime
        vc.meditationName = self.meditationName
        vc.levelName = self.levelName
        vc.type = "post"
        if self.timerType == "Prep"{
            vc.prepTime = self.prepTime - self.seconds
            vc.meditationTime = 0
            vc.restTime = 0
        }else if self.timerType == "Meditation"{
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime - self.seconds
            vc.restTime = 0
        }else if self.timerType == "Rest"{
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime - self.seconds
        }
        vc.meditationID = self.meditationID
        vc.levelID = self.levelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPauseAction(_ sender: Any) {
        if !isStop {
            timer.invalidate()
            self.isStop = true
            self.playerAmbient?.stop()
           // self.playerSlient?.stop()
            self.animationViewMed.pause()
            self.animationViewPrep.pause()
            self.animationViewRest.pause()
        }
        
        self.animateBool = 1
        self.pauseAnimation()
        self.timer1.invalidate()
        
        self.xibCall()
    }
    
    func convertDurationIntoPercentage(duration:Int) -> String  {

          let per = (Double(duration)/Double(meditationTimeAnalytics))*100

          guard !(per.isNaN || per.isInfinite) else {
               return "0" // or do some error handling
           }

          WWMHelperClass.complete_percentage = "\(Int(per))"

          return "\(Int(per))"
    }
}

//extension WWMStartTimerVC: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        print(flag)
//        if flag == true {
//            //gradient.colors = gradientSet[currentGradient]
//            animateGradient(animate: true)
//        }else{
//
//            //gradient.colors = gradientSet[currentGradient]
//            animateGradient(animate: false)
//        }
//    }
//}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 8) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

extension WWMStartTimerVC: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
            self.resumeAnimation()
        }
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
