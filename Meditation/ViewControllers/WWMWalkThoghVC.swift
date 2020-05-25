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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("watched walk... \(self.watched_duration) id... \(self.id) category... \(self.category) subCategory... \(self.subCategory) emotionKey... \(emotionKey) emotionId... \(emotionId) guided_id... \(self.id)")
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
        
        if (value == "help" || value == "learnStepList" || value == "curatedCards" || value == "21_days"){
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
            print("stopped")
            play.pause()
            self.player1 = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
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
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        
        if value == "SignupLetsStart"{
            //videoURL = self.appPreffrence.getHomePageURL()
            guard let path = Bundle.main.path(forResource: "walkthough", ofType:"mp4") else { 
                debugPrint("video.mp4 not found")
                return
            }
            
            
            //viewVideo.configure(url: "\(path)")
            
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
            print("duration... \(duration)... duration1.... \(duration1)... totalAudioLength.... \(totalAudioLength)")
            
            self.endTimeLbl.text = "\(totalAudioLength)"
            
            self.beginTimeLbl.text = "00:00"
            self.slider.maximumValue = Float(duration1)
            self.slider.value = 0.0
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
            
            //*
            
            
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
            videoURL = self.appPreffrence.getLearnPageURL()
        }else if value == "curatedCards"{
            videoURL = self.appPreffrence.getLearnPageURL()
        }else{
            videoURL = self.appPreffrence.getLearnPageURL()
        }
        
        print("walkthough videoURL... \(videoURL)")
        
        if videoURL != "" {
            print("videourl... \(videoURL)")
            viewVideo.configure(url: "\(videoURL)")
            viewVideo.isLoop = true
            viewVideo.play()
            self.videoCompleted = 1
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        let currentTime = CMTimeGetSeconds((self.player1?.currentTime())!)
        print("currentTime... \(currentTime)")
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
            self.navigateToDashboard()
        }else if value == "21_days"{
            self.navigationController?.popViewController(animated: false)
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
        print("abc....***** \(self.videoCompleted )")
        print("value... \(value)")
        self.timer.invalidate()
        if self.videoCompleted == 1{
            if !reachable.isConnectedToNetwork() {
                self.navigationController?.popViewController(animated: true)
                return
            }
            if value == "help"  || value == "learnStepList"{
                self.navigationController?.popViewController(animated: true)
            }else if value == "curatedCards"{
                self.challengeIntroVideoCompleted()
                //self.challengePopup()
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
        self.challengePopupView.removeFromSuperview()
        self.navigateToDashboard()
    }
    
    func challengeIntroVideoCompleted() {
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = [
            "user_id": self.appPreffrence.getUserID(),
            "emotion_id": self.emotionId,
            "emotion_key": self.emotionKey,
            "guided_id": self.id
            ] as [String : Any]
        
        print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ACCEPT_CHALLENGE, context: "WWMWalkThoughVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, success) in
            
            if success {
                print("success... \(result)")
                //WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.getGuidedListAPI()
                DispatchQueue.global(qos: .background).async {
                    self.bannerAPI()
                }
                //self.navigateToDashboard()
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
            //WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    //banner api
    func bannerAPI() {
        
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_BANNERS, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                print("result")
                if let result = result["result"] as? [Any]{
                    self.appPreffrence.setBanners(value: result)
                    print(self.appPreffrence.getBanners().count)
                }
            }
        }
    }
    
    func getGuidedListAPI() {
        
        /// WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = ["user_id":self.appPreffrence.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success result getGuidedListAPI walkthough... \(result)")
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    if let result = result["result"] as? [[String:Any]] {
                        
                        print("result... \(result)")
                        
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
                                    
                                    //print("dbGuidedData.last_time_stamp \(dbGuidedData.last_time_stamp) dbGuidedData.name \(dbGuidedData.name) dbGuidedData.guided_name \(dbGuidedData.guided_name) dbGuidedData.meditation_type \(dbGuidedData.meditation_type) dbGuidedData.guided_mode \(dbGuidedData.guided_mode) dbGuidedData.min_limit \(dbGuidedData.min_limit) dbGuidedData.max_limit \(dbGuidedData.max_limit) dbGuidedData.meditation_key \(dbGuidedData.meditation_key) dbGuidedData.complete_count\(dbGuidedData.complete_count) dbGuidedData.intro_url \(dbGuidedData.intro_url)")
                                    
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
                                            
                                            //print("dbGuidedEmotionsData.guided_id \(dbGuidedEmotionsData.guided_id) dbGuidedEmotionsData.emotion_id \(dbGuidedEmotionsData.emotion_id) dbGuidedEmotionsData.author_name  \(dbGuidedEmotionsData.author_name ) dbGuidedEmotionsData.emotion_image \(dbGuidedEmotionsData.emotion_image) dbGuidedEmotionsData.emotion_name \(dbGuidedEmotionsData.emotion_name) dbGuidedEmotionsData.intro_completed \(dbGuidedEmotionsData.intro_completed) dbGuidedEmotionsData.tile_type \(dbGuidedEmotionsData.tile_type) dbGuidedEmotionsData.emotion_key \(dbGuidedEmotionsData.emotion_key) dbGuidedEmotionsData.emotion_body \(dbGuidedEmotionsData.emotion_body) dbGuidedEmotionsData.completed  \(dbGuidedEmotionsData.completed) dbGuidedEmotionsData.completed_date \(dbGuidedEmotionsData.completed_date) dbGuidedEmotionsData.intro_url \(dbGuidedEmotionsData.intro_url)")
                                            
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
                                                    
                                                    //print("dbGuidedAudioData.emotion_id \(dbGuidedAudioData.emotion_id) dbGuidedAudioData.audio_id \(dbGuidedAudioData.audio_id) dbGuidedAudioData.audio_image \(dbGuidedAudioData.audio_image) dbGuidedAudioData.audio_name \(dbGuidedAudioData.audio_name) dbGuidedAudioData.audio_url \(dbGuidedAudioData.audio_url) dbGuidedAudioData.author_name \(dbGuidedAudioData.author_name) dbGuidedAudioData.duration \(dbGuidedAudioData.duration) dbGuidedAudioData.paid \(dbGuidedAudioData.paid) dbGuidedAudioData.vote \(dbGuidedAudioData.vote)")
                                                    
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
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuided"), object: nil)
                        print("guided data tabbarvc in background thread...")
                    }
                }
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func fetchGuidedDataFromDB() {
        let guidedData = WWMHelperClass.fetchGuidedFilterDB(type: self.subCategory, dbName: "DBGuidedData", name: "meditation_type")
        print("guidedDataDB.count*** \(guidedData.count)")
        for dict in guidedData{
            if (dict as AnyObject).guided_name == self.category{
                print(Int((dict as AnyObject).guided_id ?? "0") ?? 0)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                       
                vc.subCategory = self.subCategory
                vc.category = self.category
                vc.id = (dict as AnyObject).guided_id ?? ""
                       self.navigationController?.pushViewController(vc, animated: false)
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
