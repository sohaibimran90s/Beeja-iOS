//
//  WWMStartTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation

class WWMStartTimerVC: WWMBaseViewController {

    var seconds = 0
    var timer = Timer()
    var isStop = false
    var timerType = "Prep"
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var player = AVAudioPlayer()
    var playerAmbient = AVAudioPlayer()
    var settingData = DBSettings()
 
    var notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblTimerType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
        self.playerAmbient.stop()
    }
    func colorCombination() {
        UIView.animate(withDuration: 1, delay: 0.0, options:[.repeat, .curveLinear], animations: {
            self.view.backgroundColor = UIColor.black
            self.view.backgroundColor = UIColor.green
            self.view.backgroundColor = UIColor.gray
            self.view.backgroundColor = UIColor.red
        }, completion: nil)
    }
    
//    func getRandomColor() {
//        let red   = Float((arc4random() % 256)) / 255.0
//        let green = Float((arc4random() % 256)) / 255.0
//        let blue  = Float((arc4random() % 256)) / 255.0
//        let alpha = Float(1.0)
//
//        UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
//            self.view.backgroundColor = UIColor.init(displayP3Red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
//        }, completion:nil)
//    }
    @objc func appMovedToBackground() {
        print("App moved to background!")
        self.pauseAction()
        
    }
    
    func setUpView() {
        self.seconds = self.prepTime
        lblTimerType.text = "Prep"
        lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
       // self.playAudioFile(fileName: "CONCH")
        self.playAmbientSoundAudioFile(fileName: settingData.ambientChime!)
        runTimer()
       // self.colorCombination()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
       // self.getRandomColor()
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
            
            
            playerAmbient.play()
            playerAmbient.numberOfLoops = -1
            
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
            if self.seconds == 1 {
                self.lblTimerType.text = "Meditation"
                self.timerType = "Meditation"
                self.seconds = self.meditationTime
                self.playAudioFile(fileName: settingData.startChime!)
            }
                seconds = seconds-1
                self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
            
        }else if timerType == "Meditation"{
            if self.seconds == 1 {
                self.lblTimerType.text = "Rest"
                self.timerType = "Rest"
                self.seconds = self.restTime
                self.playAudioFile(fileName: settingData.endChime!)
            }else{
                if self.seconds == self.meditationTime/2+1 {
                    self.playAudioFile(fileName: settingData.intervalChime!)
                }
                
            }
            seconds = seconds-1
            self.lblTimer.text = self.secondsToMinutesSeconds(second: seconds)
            
        }else if timerType == "Rest"{
            if self.seconds == 1 {
                self.playAudioFile(fileName: settingData.finishChime!)
                self.timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + self.player.duration) {
                    if self.settingData.moodMeterEnable {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
                        vc.type = "Post"
                        vc.prepTime = self.prepTime
                        vc.meditationTime = self.meditationTime
                        vc.restTime = self.restTime
                        self.navigationController?.pushViewController(vc, animated: false)
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
                        vc.type = "Post"
                        vc.prepTime = self.prepTime
                        vc.meditationTime = self.meditationTime
                        vc.restTime = self.restTime
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                    
                }
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
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.timer.invalidate()
            self.isStop = true
            self.playerAmbient.stop()
        }, completion: nil)
    }
    // MARK:- Button Action
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.runTimer()
            self.playerAmbient.play()
        }, completion: nil)
        
    }
    @IBAction func btnPlayAction(_ sender: Any) {
        self.pauseAction()
    }
    
    @IBAction func btnPauseAction(_ sender: Any) {
        if !isStop {
            timer.invalidate()
            self.isStop = true
            self.playerAmbient.stop()
        }
        let alert = UIAlertController.init(title: "End your Meditation Session", message: "Is this really the end?", preferredStyle: .alert)
        //let btnCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let btnCancel = UIAlertAction.init(title: "Cancel", style: .default) { (UIAlertAction) in
            self.isStop = false
            self.runTimer()
            self.playerAmbient.play()
        }
        let btnOk = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
            
            if self.settingData.moodMeterEnable {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
                vc.type = "Post"
                if self.timerType == "Prep"{
                    vc.prepTime = self.seconds
                    vc.meditationTime = 0
                    vc.restTime = 0
                }else if self.timerType == "Meditation"{
                    vc.prepTime = self.prepTime
                    vc.meditationTime = self.seconds
                    vc.restTime = 0
                }else if self.timerType == "Rest"{
                    vc.prepTime = self.prepTime
                    vc.meditationTime = self.meditationTime
                    vc.restTime = self.seconds
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
                vc.type = "Post"
                if self.timerType == "Prep"{
                    vc.prepTime = self.seconds
                    vc.meditationTime = 0
                    vc.restTime = 0
                }else if self.timerType == "Meditation"{
                    vc.prepTime = self.prepTime
                    vc.meditationTime = self.seconds
                    vc.restTime = 0
                }else if self.timerType == "Rest"{
                    vc.prepTime = self.prepTime
                    vc.meditationTime = self.meditationTime
                    vc.restTime = self.seconds
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        alert.addAction(btnCancel)
        alert.addAction(btnOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        
        
        animateGradient()
        
    }
    
    func animateGradient() {
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
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
}





extension WWMStartTimerVC: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
