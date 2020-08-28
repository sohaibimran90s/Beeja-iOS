//
//  WWMWalkThoghVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWalkThoghVC: WWMBaseViewController {
//close_small
    
    @IBOutlet weak var viewVideo: VideoView!
    @IBOutlet weak var btnCrossSkip: UIButton!
    @IBOutlet weak var sliderBackView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var beginTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var btnCrossTrailC: NSLayoutConstraint!
    @IBOutlet weak var btnCrossTopC: NSLayoutConstraint!
    
    var videoURL: String = ""
    var value: String = "help"
    var videoCompleted = 0
    var watched_duration = ""
    let reachable = Reachabilities()
    let appPreffrence = WWMAppPreference()
    var lat = ""
    var long = ""
    var player1: AVPlayer?
    var videoSliderOnOff = false
    var timer = Timer()
    var playerLayer = AVPlayerLayer()

    //21day challenge variables
    var emotionKey: String = ""
    var emotionId: String = ""
    var id = ""
    var category = ""
    var subCategory = ""
    var challengePopupView = WWMAlertController()
    var challenge_type = ""
    var vc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        if (value == "help" || value == "learnStepList" || value == "curatedCards" || value == "21_days" || value == "30days" || value == "8weeks"){
            self.btnCrossSkip.setBackgroundImage(UIImage(named: "close_small"), for: .normal)
            btnCrossSkip.setTitle("", for: .normal)
        }else if value == "SignupLetsStart"{
        
            self.appPreffrence.setCheckEnterSignupLogin(value: true)
            self.btnCrossSkip.setBackgroundImage(UIImage(named: ""), for: .normal)
            
            let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            let attributeString = NSMutableAttributedString(string: KSKIP,
                                                            attributes: attributes)
            btnCrossSkip.setAttributedTitle(attributeString, for: .normal)
            
            self.sliderBackView.isHidden = false
            
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkViewTapGesture))
            self.view.addGestureRecognizer(gesture)
        }else{
            self.btnCrossSkip.setBackgroundImage(UIImage(named: ""), for: .normal)
            
            let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            let attributeString = NSMutableAttributedString(string: KSKIP,
                                                            attributes: attributes)
            btnCrossSkip.setAttributedTitle(attributeString, for: .normal)
        }
        
        self.playVideo()
    }
    
    func setUpView(){
        if WWMHelperClass.hasTopNotch{
            self.btnCrossTrailC.constant = 20
            self.btnCrossTopC.constant = 52
        }else{
            self.btnCrossTrailC.constant = 16
            self.btnCrossTopC.constant = 26
        }
        
        var prefersStatusBarHidden: Bool {
            return true
        }
                
        self.slider.setThumbImage(UIImage(named: "spinCircle"), for: .normal)
        self.sliderBackView.isHidden = true
        self.sliderBackView.isUserInteractionEnabled = false
        
        let videoFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewVideo.frame = videoFrame
        
        setNavigationBar(isShow:false,title:"")
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.btnCrossSkip.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.player1?.pause()
        self.stopPlayer()
        self.timer.invalidate()
        
        btnCrossSkip.setTitle("", for: .normal)
        
       var prefersStatusBarHidden: Bool {
            return false
        }
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player1 {
            //print("stopped")
            play.pause()
            self.player1 = nil
            //print("player deallocated")
        } else {
            //print("player was already deallocated")
        }
    }
    
    @objc func checkViewTapGesture(sender : UITapGestureRecognizer) {
        // Do what you want
        if videoSliderOnOff{
            self.sliderBackView.isHidden = false
            self.videoSliderOnOff = false
        }else{
            self.sliderBackView.isHidden = true
            self.videoSliderOnOff = true
        }
    }
    
    //MARK:- video function
    func playVideo() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            //print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        if value == "SignupLetsStart"{
            //videoURL = self.appPreffrence.getHomePageURL()
            guard let path = Bundle.main.path(forResource: "walkthough", ofType:"mp4") else { 
                debugPrint("video.mp4 not found")
                return
            }
            
            player1 = AVPlayer(url: URL(fileURLWithPath: path))
            player1?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
            self.playerLayer = AVPlayerLayer(player: player1)
            playerLayer.frame = self.view.frame
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            self.viewVideo.layer.addSublayer(playerLayer)
            player1?.seek(to: CMTime.zero)
            
            
            //time set with begin and end*
            let duration = CMTimeGetSeconds((self.player1?.currentItem?.asset.duration)!)
            let duration1 = Int(round(duration))
            let totalAudioLength = self.secondToMinuteSecond(second : duration1)
            //print("duration... \(duration)... duration1.... \(duration1)... totalAudioLength.... \(totalAudioLength)")
            
            self.endTimeLbl.text = "\(totalAudioLength)"
            
            self.beginTimeLbl.text = "00:00"
            self.slider.maximumValue = Float(duration1)
            self.slider.value = 0.0
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
            player1?.play()
            self.videoCompleted = 1
            return
        }else if value == "help"{
            guard let path = Bundle.main.path(forResource: "walkthough", ofType:"mp4") else {
                debugPrint("video.mp4 not found")
                return
            }
            
            player1 = AVPlayer(url: URL(fileURLWithPath: path))
            player1?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
            self.playerLayer = AVPlayerLayer(player: player1)
            playerLayer.frame = self.view.frame
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            self.viewVideo.layer.addSublayer(playerLayer)
            player1?.seek(to: CMTime.zero)
            player1?.play()
            self.videoCompleted = 1
            return
        }else if value == "learnStepList"{
            videoURL = self.appPreffrence.getLearnPageURL()
        }else if value == "curatedCards"{
            //videoURL = self.appPreffrence.getLearnPageURL()
        }else if value == "30days"{
            videoURL = self.appPreference.get30DaysURL()
        }else if value == "8weeks"{
            videoURL = self.appPreference.get8WeekURL()
        }else{
            videoURL = self.appPreffrence.getLearnPageURL()
        }

        if videoURL != "" {
            //print("videourl... \(videoURL)")
            viewVideo.configure(url: "\(videoURL)")
            viewVideo.isLoop = true
            viewVideo.play()
            self.videoCompleted = 1
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        let currentTime = CMTimeGetSeconds((self.player1?.currentTime())!)
        //print("currentTime... \(currentTime)")
        self.slider.value = Float(currentTime)
        self.beginTimeLbl.text = "\(self.secondToMinuteSecond(second : Int(currentTime)))"
        
        if self.beginTimeLbl.text == self.endTimeLbl.text{
            self.timer.invalidate()
        }
    }
    
    @IBAction func btnSkipCrossClicked(_ sender: UIButton) {
        self.viewVideo.stop()
        self.player1?.pause()
        self.timer.invalidate()
        
        if (value == "help" || value == "learnStepList" || value == "curatedCards"){
            self.callHomeVC(index: 2)
        }else if (value == "21_days" || value == "30days" || value == "8weeks") {
            if challenge_type == "30days" || challenge_type == "8weeks"{
                if vc == "HomeTabVC"{
                    self.callHomeVC(index: 0)
                }else{
                    if value == "30days"{
                        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                    }else{
                        self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
                    }
                    self.callHomeVC1()
                }
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        }else{
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "VIDEO_SKIPPED", itemName: "")
// TODO - change for onboarding
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        //print("abc....***** \(self.videoCompleted) value... \(value)")
        self.timer.invalidate()
        if self.videoCompleted == 1{
            if !reachable.isConnectedToNetwork() {
                self.navigationController?.popViewController(animated: true)
                return
            }
            if value == "help" || value == "learnStepList"{
                self.navigationController?.popViewController(animated: true)
            }else if (value == "curatedCards" || value == "30days" || value == "8weeks"){
                self.challengeIntroVideoCompleted()
            }else if value == "21_days"{
                self.navigationController?.popViewController(animated: false)
            }else{
                // Analytics
                WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "VIDEO_COMPLETED", itemName: "")
// TODO - change for onboarding
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    func challengePopup() {
        
        challengePopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        challengePopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        challengePopupView.btnOK.layer.borderWidth = 2.0
        challengePopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if self.emotionKey == "7day_challenge"{
            challengePopupView.lblTitle.text = "Do you accept the 7 Day challenge?"
        }else{
            challengePopupView.lblTitle.text = "Do you accept the 21 Day challenge?"
        }
        
        challengePopupView.lblSubtitle.numberOfLines = 0
        challengePopupView.lblSubtitle.text = ""
        challengePopupView.lblSubtitle.isHidden = true
        challengePopupView.btnOK.setTitle(kYES, for: .normal)
        challengePopupView.btnClose.setTitle(kNO, for: .normal)
        
        challengePopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        challengePopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(challengePopupView)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.challengeIntroVideoCompleted()
    }
    
    @IBAction func btnCloseAction(_ sender: Any){
        self.callHomeVC(index: 2)
        self.challengePopupView.removeFromSuperview()
    }
    
    func challengeIntroVideoCompleted() {
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = [
            "user_id": self.appPreffrence.getUserID(),
            "emotion_id": self.emotionId,
            "emotion_key": self.emotionKey,
            "guided_id": self.id,
            "challenge_type": self.challenge_type
            ] as [String : Any]
        print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ACCEPT_CHALLENGE, context: "WWMWalkThoughVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, success) in
            
            if success {
                if self.challenge_type == ""{
                    self.getGuidedListAPI1()
                }else{
                    self.getLearnAPI1()
                }
            }else {
                
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if error != nil {
                    
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                    }
                    
                }
            }
        }
    }
    
    //App enter in forground.
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        if ((player1?.pause()) != nil){
            self.player1?.play()
        }
    }
    
    //App enter in forground.
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        self.player1?.pause()
    }
}

extension WWMWalkThoghVC{
   
    //21 days guided
    func getGuidedListAPI1() {
                
        let param = ["user_id":self.appPreffrence.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    //print("success result getGuidedListAPI walkthough... \(result)")
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    if let result = result["result"] as? [[String:Any]] {
                        
                        //print("result... \(result)")
                        
                        let guidedData = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
                        if guidedData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                        }
                        
                        let guidedEmotionsData = WWMHelperClass.fetchDB(dbName: "DBGuidedEmotionsData") as! [DBGuidedEmotionsData]
                        if guidedEmotionsData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                        }
                        
                        let guidedAudioData = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                        if guidedAudioData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                        }
                        
                        for dict in result {
                            
                            if let meditation_list = dict["meditation_list"] as? [[String: Any]]{
                                
                                for meditationList in meditation_list {
                                    let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                                    
                                    let timeInterval = Int(Date().timeIntervalSince1970)
                                    
                                    dbGuidedData.last_time_stamp = "\(timeInterval)"
                                    dbGuidedData.cat_name = dict["name"] as? String
                                    
                                    if let id = meditationList["id"]{
                                        dbGuidedData.guided_id = "\(id)"
                                    }
                                    
                                    if let name = meditationList["name"] as? String{
                                        dbGuidedData.guided_name = name
                                    }
                                    
                                    if let meditation_type = meditationList["meditation_type"] as? String{
                                        dbGuidedData.meditation_type = meditation_type
                                    }
                                    
                                    if let guided_mode = meditationList["mode"] as? String{
                                        dbGuidedData.guided_mode = guided_mode
                                    }
                                    
                                    if let min_limit = meditationList["min_limit"] as? String{
                                        dbGuidedData.min_limit = min_limit
                                    }else{
                                        dbGuidedData.min_limit = "95"
                                    }
                                    
                                    if let max_limit = meditationList["max_limit"] as? String{
                                        dbGuidedData.max_limit = max_limit
                                    }else{
                                        dbGuidedData.max_limit = "98"
                                    }
                                    
                                    if let meditation_key = meditationList["meditation_key"] as? String{
                                        dbGuidedData.meditation_key = meditation_key
                                    }else{
                                        if let meditation_type = dict["meditation_type"] as? String{
                                            dbGuidedData.meditation_key = meditation_type
                                        }
                                    }
                                    
                                    if let complete_count = meditationList["complete_count"] as? Int{
                                        dbGuidedData.complete_count = "\(complete_count)"
                                    }else{
                                        dbGuidedData.complete_count = "0"
                                    }
                                    
                                    if let intro_url = meditationList["intro_url"] as? String{
                                        dbGuidedData.intro_url = intro_url
                                    }else{
                                        dbGuidedData.intro_url = ""
                                    }
                                    
                                    if let intro_completed = meditationList["intro_completed"] as? Bool{
                                        dbGuidedData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedData.intro_completed = false
                                    }
                                                                        
                                    if let emotion_list = meditationList["emotion_list"] as? [[String: Any]]{
                                        for emotionsDict in emotion_list {
                                            
                                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                            
                                            if let id = meditationList["id"]{
                                                dbGuidedEmotionsData.guided_id = "\(id)"
                                            }
                                            
                                            if let emotion_id = emotionsDict["emotion_id"]{
                                                dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                            }
                                            
                                            if let author_name = emotionsDict["author_name"]{
                                                dbGuidedEmotionsData.author_name = "\(author_name)"
                                            }
                                            
                                            if let emotion_image = emotionsDict["emotion_image"] as? String{
                                                dbGuidedEmotionsData.emotion_image = emotion_image
                                            }
                                            
                                            if let emotion_name = emotionsDict["emotion_name"] as? String{
                                                dbGuidedEmotionsData.emotion_name = emotion_name
                                            }
                                            
                                            if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                                dbGuidedEmotionsData.intro_completed = intro_completed
                                            }else{
                                                dbGuidedEmotionsData.intro_completed = false
                                            }
                                            
                                            if let tile_type = emotionsDict["tile_type"] as? String{
                                                dbGuidedEmotionsData.tile_type = tile_type
                                            }
                                            
                                            if let emotion_key = emotionsDict["emotion_key"] as? String{
                                                dbGuidedEmotionsData.emotion_key = emotion_key
                                            }
                                            
                                            if let emotion_body = emotionsDict["emotion_body"] as? String{
                                                dbGuidedEmotionsData.emotion_body = emotion_body
                                            }
                                            
                                            if let completed = emotionsDict["completed"] as? Bool{
                                                dbGuidedEmotionsData.completed = completed
                                            }
                                            
                                            if let completed_date = emotionsDict["completed_date"] as? String{
                                                dbGuidedEmotionsData.completed_date = completed_date
                                            }
                                            
                                            if let intro_url = emotionsDict["intro_url"] as? String{
                                                dbGuidedEmotionsData.intro_url = intro_url
                                            }else{
                                                dbGuidedEmotionsData.intro_url = ""
                                            }
                                            
                                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                                dbGuidedEmotionsData.emotion_type = emotion_type
                                            }else{
                                                dbGuidedEmotionsData.emotion_type = ""
                                            }
                                                                                        
                                            if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                                for audioDict in audio_list {
                                                    
                                                    let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                                    
                                                    if let emotion_id = emotionsDict["emotion_id"]{
                                                        dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                                    }
                                                    
                                                    if let audio_id = audioDict["id"]{
                                                        dbGuidedAudioData.audio_id = "\(audio_id)"
                                                    }
                                                    
                                                    if let audio_image = audioDict["audio_image"] as? String{
                                                        dbGuidedAudioData.audio_image = audio_image
                                                    }
                                                    
                                                    if let audio_name = audioDict["audio_name"] as? String{
                                                        dbGuidedAudioData.audio_name = audio_name
                                                    }
                                                    
                                                    if let audio_url = audioDict["audio_url"] as? String{
                                                        dbGuidedAudioData.audio_url = audio_url
                                                    }
                                                    
                                                    if let author_name = audioDict["author_name"] as? String{
                                                        dbGuidedAudioData.author_name = author_name
                                                    }
                                                    
                                                    if let duration = audioDict["duration"]{
                                                        dbGuidedAudioData.duration = "\(duration)"
                                                    }
                                                    
                                                    if let paid = audioDict["paid"] as? Bool{
                                                        dbGuidedAudioData.paid = paid
                                                    }
                                                    
                                                    if let vote = audioDict["vote"] as? Bool{
                                                        dbGuidedAudioData.vote = vote
                                                    }
                                                
                                                    WWMHelperClass.saveDb()
                                                }
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                        }
                                    }
                                }
                            }
                            WWMHelperClass.saveDb()
                        }
                        WWMHelperClass.hideLoaderAnimate(on: self.view)
                        self.fetchGuidedDataFromDB()
                    }
                }
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func fetchGuidedDataFromDB() {
        let guidedData = WWMHelperClass.fetchGuidedFilterDB(type: self.subCategory, dbName: "DBGuidedData", name: "meditation_type")
        //print("guidedDataDB.count*** \(guidedData.count)")
        for dict in guidedData{
            if (dict as AnyObject).guided_name == self.category{
                print(Int((dict as AnyObject).guided_id ?? "0") ?? 0)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                      
                vc.type = "curatedCards"
                vc.subCategory = self.subCategory
                vc.category = self.category
                vc.id = (dict as AnyObject).guided_id ?? ""
                       self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    //MARK: getLearnSetps API call
    func getLearnAPI1() {
        
        let param = ["user_id": self.appPreffrence.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_LEARN_, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                if let total_paid = result["total_paid"] as? Double{
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    
                    let getDBLearn = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
                    if getDBLearn.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBLearn")
                    }
                    
                    let getStepsData = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                    if getStepsData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBSteps")
                    }
                    
                    let getThirtyDaysData = WWMHelperClass.fetchDB(dbName: "DBThirtyDays") as! [DBThirtyDays]
                    if getThirtyDaysData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBThirtyDays")
                    }
                    
                    let getEightWeekData = WWMHelperClass.fetchDB(dbName: "DBEightWeek") as! [DBEightWeek]
                    if getEightWeekData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBEightWeek")
                    }
                    
                    for dict in data{
                        
                        let dbLearnData = WWMHelperClass.fetchEntity(dbName: "DBLearn") as! DBLearn
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        dbLearnData.last_time_stamp = "\(timeInterval)"
                        
                        if dict["name"] as? String == "30 Day Challenge"{
                            self.appPreffrence.set30IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreffrence.set30DaysURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreffrence.set30DaysIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                        
                        if dict["name"] as? String == "8 Weeks Challenge"{
                            self.appPreffrence.set8IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreffrence.set8WeekURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreffrence.set8WeekIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                                                
                        if let name = dict["name"] as? String{
                            dbLearnData.name = name
                        }
                        
                        if let intro_url = dict["intro_url"] as? String{
                            dbLearnData.intro_url = intro_url
                        }
                        
                        if let intro_completed = dict["intro_completed"] as? Bool{
                            dbLearnData.intro_completed = intro_completed
                        }
                        
                        if let min_limit = dict["min_limit"] as? String{
                            dbLearnData.min_limit = min_limit
                        }
                        
                        if let max_limit = dict["max_limit"] as? String{
                            dbLearnData.max_limit = max_limit
                        }
                        
                        if let is_expired = dict["is_expired"] as? Bool{
                            dbLearnData.is_expired = is_expired
                        }else{
                            dbLearnData.is_expired = false
                        }
                        
                        if let step_list = dict["step_list"] as? [[String: Any]]{
                            for dict in step_list{
                                let dbStepsData = WWMHelperClass.fetchEntity(dbName: "DBSteps") as! DBSteps
                                if let completed = dict["completed"] as? Bool{
                                    dbStepsData.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbStepsData.date_completed = date_completed
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbStepsData.description1 = description
                                }
                                
                                if let id = dict["id"]{
                                    dbStepsData.id = "\(id)"
                                }
                                
                                if let outro_audio = dict["outro_audio"] as? String{
                                    dbStepsData.outro_audio = outro_audio
                                }
                                
                                if let step_audio = dict["step_audio"] as? String{
                                    dbStepsData.step_audio = step_audio
                                }
                                
                                if let step_name = dict["step_name"] as? String{
                                    dbStepsData.step_name = step_name
                                }
                                
                                if let timer_audio = dict["timer_audio"] as? String{
                                    dbStepsData.timer_audio = timer_audio
                                }
                                
                                if let title = dict["title"] as? String{
                                    dbStepsData.title = title
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbStepsData.min_limit = min_limit
                                }else{
                                    dbStepsData.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbStepsData.max_limit = max_limit
                                }else{
                                    dbStepsData.max_limit = "98"
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        if let day_list = dict["day_list"] as? [[String: Any]]{
                            for dict in day_list{
                                let dbThirtyDays = WWMHelperClass.fetchEntity(dbName: "DBThirtyDays") as! DBThirtyDays
                                                                
                                if let id = dict["id"]{
                                    dbThirtyDays.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbThirtyDays.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbThirtyDays.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbThirtyDays.description1 = description
                                }
                                
                                if let is_milestone = dict["is_milestone"] as? Bool{
                                    dbThirtyDays.is_milestone = is_milestone
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbThirtyDays.min_limit = min_limit
                                }else{
                                    dbThirtyDays.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbThirtyDays.max_limit = max_limit
                                }else{
                                    dbThirtyDays.max_limit = "98"
                                }
                                
                                if let prep_time = dict["prep_time"] as? String{
                                    dbThirtyDays.prep_time = prep_time
                                }else{
                                    dbThirtyDays.prep_time = "60"
                                }
                                
                                if let meditation_time = dict["meditation_time"] as? String{
                                    dbThirtyDays.meditation_time = meditation_time
                                }else{
                                    dbThirtyDays.meditation_time = "1200"
                                }
                                
                                if let rest_time = dict["rest_time"] as? String{
                                    dbThirtyDays.rest_time = rest_time
                                }else{
                                    dbThirtyDays.rest_time = "120"
                                }
                                
                                if let prep_min = dict["prep_min"] as? String{
                                    dbThirtyDays.prep_min = prep_min
                                }else{
                                    dbThirtyDays.prep_min = "0"
                                }
                                
                                if let prep_max = dict["prep_max"] as? String{
                                    dbThirtyDays.prep_max = prep_max
                                }else{
                                    dbThirtyDays.prep_max = "300"
                                }
                                
                                if let rest_min = dict["rest_min"] as? String{
                                    dbThirtyDays.rest_min = rest_min
                                }else{
                                    dbThirtyDays.prep_max = "0"
                                }
                                
                                if let rest_max = dict["rest_max"] as? String{
                                    dbThirtyDays.rest_max = rest_max
                                }else{
                                    dbThirtyDays.prep_max = "600"
                                }
                                
                                if let med_min = dict["med_min"] as? String{
                                    dbThirtyDays.med_min = med_min
                                }else{
                                    dbThirtyDays.med_min = "0"
                                }
                                
                                if let med_max = dict["med_max"] as? String{
                                    dbThirtyDays.med_max = med_max
                                }else{
                                    dbThirtyDays.med_max = "2400"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbThirtyDays.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbThirtyDays.date_completed = date_completed
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbThirtyDays.image = image
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        //8 week
                        if let daywise_list = dict["daywise_list"] as? [[String: Any]]{
                            for dict in daywise_list{
                                let dbEightWeek = WWMHelperClass.fetchEntity(dbName: "DBEightWeek") as! DBEightWeek
                                                                
                                if let id = dict["id"]{
                                    dbEightWeek.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbEightWeek.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbEightWeek.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbEightWeek.description1 = description
                                }
                                
                                if let secondDescription = dict["second_description"] as? String{
                                    dbEightWeek.secondDescription = secondDescription
                                }else{
                                    dbEightWeek.secondDescription = ""
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbEightWeek.image = image
                                }else{
                                    dbEightWeek.image = ""
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbEightWeek.min_limit = min_limit
                                }else{
                                    dbEightWeek.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbEightWeek.max_limit = max_limit
                                }else{
                                    dbEightWeek.max_limit = "98"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbEightWeek.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbEightWeek.date_completed = date_completed
                                }
                                
                                if let is_pre_opened = dict["is_pre_opened"] as? Bool{
                                    dbEightWeek.is_pre_opened = is_pre_opened
                                }
                                
                                if let second_session_required = dict["second_session_required"] as? Bool{
                                    dbEightWeek.second_session_required = second_session_required
                                }
                                
                                if let second_session_completed = dict["second_session_completed"] as? Bool{
                                    dbEightWeek.second_session_completed = second_session_completed
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        WWMHelperClass.saveDb()
                    }
                }
                
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if self.appPreference.getType() == "learn" || self.appPreference.getType() == "Learn"{
                    if self.value == "30days"{
                        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM30DaysGearUpVC") as! WWM30DaysGearUpVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
                        self.callHomeVC1()
                    }
                    
                }else{
                   self.callHomeVC(index: 2)
                }
                return
            }else{
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if self.appPreference.getType() == "learn" || self.appPreference.getType() == "Learn"{
                    if self.value == "30days"{
                        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM30DaysGearUpVC") as! WWM30DaysGearUpVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
                        self.callHomeVC1()
                    }
                }else{
                   self.callHomeVC(index: 2)
                }
            }
        }
        WWMHelperClass.hideLoaderAnimate(on: self.view)
    }
}
