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
    var user_id: Int = 0
    var emotionId: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("watched walk... \(self.watched_duration)")
        
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
        
        if (value == "help" || value == "learnStepList" || value == "curatedCards"){
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
        
        var prefersStatusBarHidden: Bool {
            return true
        }
       // player1?.play()
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
        
        var videoURL: String = ""

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
            playerLayer.videoGravity = AVLayerVideoGravity.resize
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
            playerLayer.videoGravity = AVLayerVideoGravity.resize
            self.viewVideo.layer.addSublayer(playerLayer)
            player1?.seek(to: CMTime.zero)
            
            player1?.play()
            self.videoCompleted = 1
            return
            
        
        }else if value == "learnStepList"{
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
        }else{
            // Analytics
            WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "VIDEO_SKIPPED", itemName: "")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    @objc func reachTheEndOfTheVideo1(note: NSNotification){
//        if self.videoCompleted == 1{
//            if !reachable.isConnectedToNetwork() {
//                self.navigationController?.popViewController(animated: true)
//                return
//            }
//
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
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
            }else{
                // Analytics
                WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "VIDEO_COMPLETED", itemName: "")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func challengeIntroVideoCompleted() {
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = [
            "user_id": self.user_id,
            "emotion_id": self.emotionId,
            "emotion_key": self.emotionKey
            ] as [String : Any]
        
        print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ACCEPT_CHALLENGE, context: "WWMWalkThoughVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, success) in
            
            if success {
                print("success... \(result)")
                //WWMHelperClass.hideLoaderAnimate(on: self.view)
                self.getGuidedListAPI()
                //self.navigateToDashboard()
            }else {
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
    
    func getGuidedListAPI() {
        
         WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = ["user_id":self.appPreffrence.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success result getGuidedListAPI walkthough... \(result)")
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    if let audioList = result["result"] as? [[String:Any]] {
                        
                        print("audioList... \(audioList)")
                        
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
                        
                        for guidedDict in audioList {
                            
                            let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            print("timeInterval.... \(timeInterval)")
                            
                            dbGuidedData.last_time_stamp = "\(timeInterval)"
                            
                            if let id = guidedDict["id"]{
                                dbGuidedData.guided_id = "\(id)"
                            }
                            
                            if let name = guidedDict["name"] as? String{
                                dbGuidedData.guided_name = name
                            }
                            
                            if let meditation_type = guidedDict["meditation_type"] as? String{
                                dbGuidedData.meditation_type = meditation_type
                            }
                            
                            if let guided_mode = guidedDict["mode"] as? String{
                                dbGuidedData.guided_mode = guided_mode
                            }
                            
                            if let emotion_list = guidedDict["emotion_list"] as? [[String: Any]]{
                                for emotionsDict in emotion_list {
                                    
                                    let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                    
                                    if let id = guidedDict["id"]{
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
                            
                            WWMHelperClass.saveDb()
                        }
                        WWMHelperClass.hideLoaderAnimate(on: self.view)
                        self.navigateToDashboard()
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuided"), object: nil)
                        print("guided data tabbarvc in background thread...")
                    }
                }
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func navigateToDashboard() {
        
        self.navigationController?.isNavigationBarHidden = false
        if let tabController = self.tabBarController as? WWMTabBarVC {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationReloadGuidedTabs"), object: nil)
            
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
