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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewLottieAnimation.isHidden = true
        spinnerImage.isHidden = true
        
        
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
            let remainingTime = self.seconds - Int((self.player?.currentTime().seconds)!)
            self.lblTimer.text = self.secondsToMinutesSeconds(second: remainingTime)
            if remainingTime == 0 {
                self.moveToFeedBack()
            }
        }
    }
    
    var ismove = false
    
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
            var analyticCatName = self.cat_Name.uppercased()
            analyticCatName = analyticCatName.replacingOccurrences(of: " ", with: "_")
            var analyticEmotionName = self.emotion_Name.uppercased()
            analyticEmotionName = analyticEmotionName.replacingOccurrences(of: " ", with: "_")
            
            var audioPlayPercentageCompleteStatus = ""
            if let audioPlayPercentage = Int(self.convertDurationIntoPercentage(duration:Int(round((self.player?.currentTime().seconds)!)))){
                if audioPlayPercentage >= 95{
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
        self.moveToFeedBack()
        alertPopupView.removeFromSuperview()
    }
    
    @IBAction func btnPauseAction(_ sender: Any) {
        if !isStop {
            self.isStop = true
            self.animationView.pause()
            self.player?.pause()
        }
        
        self.animateBool = 1
        self.pauseAnimation()
        self.timer1.invalidate()
        
        self.xibCall()
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
