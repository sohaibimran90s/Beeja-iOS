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

class WWMStartTimerVC: WWMBaseViewController {

    var seconds = 0
    var timer = Timer()
    var isStop = false
    var timerType = "Prep"
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var player = AVAudioPlayer()
    var playerAmbient = AVAudioPlayer()
    var settingData = DBSettings()
 
    var isAmbientSoundPlay = false
    var notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblTimerType: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    
    //var alertPopupView = WWMAlertController()
    var animationView = AnimationView()
    override func viewDidLoad() {
        super.viewDidLoad()

            animationView = AnimationView(name: "final1")
            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.center = self.view.center
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
        view.insertSubview(animationView, belowSubview: viewPause)
           // view.addSubview(animationView)
            
            animationView.play()
        spinnerImage.isHidden = true
        self.setUpView()
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
         notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
        self.playerAmbient.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
//    func rotationImage() {
//
//        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
//
//            self.spinnerImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 2))
//        }) { (finished) in
//            self.rotationImage()
//        }
//    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
         self.animationView.pause()

    }
    @objc func appMovedToForeground() {
        print("App moved to background!")
        self.animationView.play()
        
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
        
        if self.prepTime > 0 {
            self.seconds = self.prepTime
            lblTimerType.text = "Prep"
            timerType = "Prep"
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else if self.meditationTime > 0 {
            self.lblTimerType.text = "Meditation"
            self.timerType = "Meditation"
            self.seconds = self.meditationTime
            self.playAudioFile(fileName: settingData.startChime!)
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else if self.restTime > 0 {
            self.lblTimerType.text = "Rest"
            self.timerType = "Rest"
            self.seconds = self.restTime
            lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        }else {
            self.timerType = ""
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
            vc.type = "Post"
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.playAmbientSoundAudioFile(fileName: settingData.ambientChime!)
        runTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.type = .radial
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        
        
        animateGradient(animate: true)
       // self.spinnerImage.rotate360Degrees()
        //self.spinnerImage.layer.removeAllAnimations()
        //self.rotationImage()
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
            
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playAmbientSoundAudioFile(fileName:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            playerAmbient = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            if isAmbientSoundPlay {
                playerAmbient.play()
                playerAmbient.numberOfLoops = -1
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    //#selector(self.updateTimer)
    @objc func updateTimer() {
        if timerType == "Prep"{
            if self.seconds < 1 {
                if self.meditationTime > 0 {
                    self.lblTimerType.text = "Meditation"
                    self.timerType = "Meditation"
                    self.seconds = self.meditationTime
                    self.playAudioFile(fileName: settingData.startChime!)
                }else if self.restTime > 0 {
                    self.lblTimerType.text = "Rest"
                    self.timerType = "Rest"
                    self.seconds = self.restTime
                    self.playAudioFile(fileName: settingData.endChime!)
                }else {
                    self.playAudioFile(fileName: settingData.finishChime!)
                    self.timer.invalidate()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                    vc.type = "Post"
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
                    self.lblTimerType.text = "Rest"
                    self.timerType = "Rest"
                    self.seconds = self.restTime
                    self.playAudioFile(fileName: settingData.endChime!)
                }else {
                    self.playAudioFile(fileName: settingData.finishChime!)
                    self.timer.invalidate()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                    vc.type = "Post"
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
                        self.playAudioFile(fileName: settingData.intervalChime!)
                    }
                }
                
            }
            seconds = seconds-1
            self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
        }else if timerType == "Rest"{
            if self.seconds < 1 {
                self.playAudioFile(fileName: settingData.finishChime!)
                self.timer.invalidate()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
                vc.type = "Post"
                vc.prepTime = self.prepTime
                vc.meditationTime = self.meditationTime
                vc.restTime = self.restTime
                
                vc.meditationID = self.meditationID
                vc.levelID = self.levelID
                self.navigationController?.pushViewController(vc, animated: true)
//                DispatchQueue.main.asyncAfter(deadline: .now() + self.player.duration) {
                    //}
            }
                seconds = seconds-1
                self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
            
        }
        
        
        
//        if seconds < 1 {
//            if timerType == "Prep"{
//                self.lblTimerType.text = "Meditation"
//                self.timerType = "Meditation"
//                self.seconds = self.meditationTime
//                self.playAudioFile(fileName: "CONCH")
//            }else if timerType == "Meditation"{
//                self.lblTimerType.text = "Rest"
//                self.timerType = "Rest"
//                self.seconds = self.restTime
//                self.playAudioFile(fileName: "SITAR")
//            }else if timerType == "Rest"{
//                self.timer.invalidate()
//                self.player.stop()
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
//                vc.type = "Post"
//                vc.prepTime = 0
//                vc.meditationTime = 0
//                vc.restTime = self.seconds
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
//        }else {
//            seconds = seconds-1
//            self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
//        }
        
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    func pauseAction() {
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.timer.invalidate()
            self.isStop = true
            self.playerAmbient.stop()
            self.animationView.pause()
           // self.spinnerImage.layer.removeAllAnimations()
            self.animateGradient(animate: false)
        }, completion: nil)
    }
    // MARK:- Button Action
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.runTimer()
            if self.isAmbientSoundPlay {
                self.playerAmbient.play()
            }
            self.animationView.play()
           // self.spinnerImage.rotate360Degrees()
            self.animateGradient(animate: true)
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
        animateGradient(animate: true)
        self.isStop = false
        self.runTimer()
        if self.isAmbientSoundPlay {
            self.playerAmbient.play()
        }
        self.animationView.play()
       // self.spinnerImage.rotate360Degrees()
        alertPopupView.removeFromSuperview()
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
         alertPopupView.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
        vc.type = "Post"
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
            self.playerAmbient.stop()
            self.animationView.pause()
           // self.spinnerImage.layer.removeAllAnimations()
        }
        
        animateGradient(animate: false)
        
        self.xibCall()
        
        
        
        
        
//        let alert = UIAlertController.init(title: "End your Meditation Session", message: "Is this really the end?", preferredStyle: .alert)
//        ///let btnCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
//        let btnCancel = UIAlertAction.init(title: "Cancel", style: .default) { (UIAlertAction) in
//            self.isStop = false
//            self.runTimer()
//            self.playerAmbient.play()
//            self.spinnerImage.rotate360Degrees()
//        }
//        let btnOk = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMFinishTimerVC") as! WWMFinishTimerVC
//            vc.type = "Post"
//            if self.timerType == "Prep"{
//                vc.prepTime = self.prepTime - self.seconds
//                vc.meditationTime = 0
//                vc.restTime = 0
//            }else if self.timerType == "Meditation"{
//                vc.prepTime = self.prepTime
//                vc.meditationTime = self.meditationTime - self.seconds
//                vc.restTime = 0
//            }else if self.timerType == "Rest"{
//                vc.prepTime = self.prepTime
//                vc.meditationTime = self.meditationTime
//                vc.restTime = self.restTime - self.seconds
//            }
//            vc.meditationID = self.meditationID
//            vc.levelID = self.levelID
//            self.navigationController?.pushViewController(vc, animated: true)
//
//        }
//        alert.addAction(btnCancel)
//        alert.addAction(btnOk)
//        self.present(alert, animated: true, completion: nil)
    }
//
    
    
    
//    <color name="gradient1">#00EBA9</color>
//    <color name="gradient2">#49298A</color>
//    <color name="gradient3">#001252</color>
//
//    <color name="gradient4">#FFC02F</color>
//    <color name="gradient5">#49298A</color>
//    <color name="gradient6">#FF3A49</color>
//
//    <!--*  Yellow purple    ///  gradient colors
//    FFC02F
//    49298A
//    FF3A49
//    *  Red Purple
//    001252
//    49298A
//    FF3A49
//
//    *  Blue Green
//    00EBA9
//    49298A
//    001252-->
    
    
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor.init(hexString: "#00EBA9")!.cgColor
    let gradientTwo = UIColor.init(hexString: "#49298A")!.cgColor
    let gradientThree = UIColor.init(hexString: "#001252")!.cgColor
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        gradientSet.append([gradientOne, gradientTwo])
//        gradientSet.append([gradientTwo, gradientThree])
//        gradientSet.append([gradientThree, gradientOne])
//
//
//        gradient.frame = self.view.bounds
//        gradient.colors = gradientSet[currentGradient]
//        gradient.type = .radial
//        gradient.startPoint = CGPoint(x:0, y:0)
//        gradient.endPoint = CGPoint(x:1, y:1)
//        gradient.drawsAsynchronously = true
//
//
//        animateGradient()
//
//    }
    
    func animateGradient(animate: Bool) {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 10.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.both
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        if animate{
            gradient.add(gradientChangeAnimation, forKey: "colorChange")
            self.view.layer.insertSublayer(gradient, at: 0)
        }else{
            gradient.removeFromSuperlayer()
        }
        
        
    }
    
}





extension WWMStartTimerVC: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print(flag)
        if flag == true {
            //gradient.colors = gradientSet[currentGradient]
            animateGradient(animate: true)
        }else{
            
            //gradient.colors = gradientSet[currentGradient]
            animateGradient(animate: false)
        }
    }
}

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
