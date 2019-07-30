//
//  WWMLearnTimerVC.swift
//  Meditation
//
//  Created by Prema Negi on 21/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Lottie

class WWMLearnTimerVC: WWMBaseViewController {

    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblTimerType: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var notificationCenter = NotificationCenter.default

    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var timer1 = Timer()
    var animateBool: Int = 0
    
    var seconds = 0
    var totalDuration: Int = 0
    var totalAudioLength: String = ""
    
    var settingData = DBSettings()
    var animationView = AnimationView()
    var timer = Timer()

    var isPlayer = false
    var isStop = false
    var player = AVPlayer()
    
    var paidFreeUSer: String = ""
    var ismove = false
    var watched_duration: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        notificationCenter.addObserver(self, selector: #selector(self.methodOfCallEndedIdentifier(notification:)), name: Notification.Name("NotificationCallEndedIdentifier"), object: nil)
        
        self.lblTimer.text = self.secondToMinuteSecond(second: self.seconds)
        animationView.play()

        if WWMHelperClass.step_id > 3{
            self.combinedMantraAPI()
        }else{
            self.play(url: URL.init(string: WWMHelperClass.timer_audio)!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.createColorSets()
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
        
        print("animateBool.... \(animateBool)")
        
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
        
        if WWMHelperClass.step_id == 4{
            param = ["step_id": WWMHelperClass.step_id, "mantra_id": WWMHelperClass.mantra_id] as [String : Any]
        }else{
            param = ["step_id": WWMHelperClass.step_id, "mantra_id": self.settingData.mantraID] as [String : Any]
        }
        
        print("param learn timer... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMBINEDMANTRA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [String: Any]{
                    if let audio_url = data["audio_url"] as? String{
                        self.play(url: URL(string: audio_url)!)
                    }
                }
                print("combinedMantra.... \(result)")
                
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
        
        
        alertPopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.player.play()
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
        if self.animateBool == 1{
            self.resumeAnimation()
            self.animateBool = 0
            self.timer1 = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        }
        
        self.isStop = false
        self.player.play()
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
            self.player.pause()
        }
        
        self.animateBool = 1
        self.pauseAnimation()
        self.timer1.invalidate()
        
        self.xibCall()
    }
    
    func play(url:URL) {
        print("playing \(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem:playerItem)
            
            let duration = CMTimeGetSeconds((self.player.currentItem?.asset.duration)!)
            self.totalDuration  = Int(round(duration))
            self.totalAudioLength = self.secondToMinuteSecond(second : self.totalDuration)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            self.lblTimer.text = "\(totalAudioLength)"
            player.volume = 1.0
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            
            player.play()
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
            
            self.player.pause()
        }, completion: nil)
    }
    
    @objc func updateTimer() {
        if isPlayer {
            if self.totalAudioLength != ""{
                print("totalaudiolength... \(self.totalDuration)")
                print("currentTime... \(self.player.currentTime().seconds)")
                self.watched_duration = Int(round(self.player.currentTime().seconds))
                let remainingTime = self.totalDuration - Int(round(self.player.currentTime().seconds))
                self.lblTimer.text = self.secondToMinuteSecond(second: remainingTime)
            }
        }
    }
    
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        if !ismove {
            
            ismove = true
            self.timer.invalidate()
            self.animationView.stop()
            self.player.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
            
            vc.watched_duration = "\(self.watched_duration)"
            vc.value = "learnCongrats"
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func moveToFeedBack() {
        if !ismove {
            
            ismove = true
            self.timer.invalidate()
            self.animationView.stop()
            self.player.pause()
            
            self.animateBool = 1
            self.pauseAnimation()
            self.timer1.invalidate()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
            
            vc.watched_duration = "\(self.watched_duration)"
            vc.value = "learnCongrats"
            self.navigationController?.pushViewController(vc, animated: false)
            
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
            
            self.player.pause()
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
