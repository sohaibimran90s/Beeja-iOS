//
//  WWMGuidedMeditationTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 23/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation

class WWMGuidedMeditationTimerVC: WWMBaseViewController {

    var seconds = 0
    var timer = Timer()
    var isStop = false
   // var player = AVAudioPlayer()
    var player = AVPlayer()
    var settingData = DBSettings()
    var audioData = WWMGuidedAudioData()
    var notificationCenter = NotificationCenter.default
    var isPlayer = false
    var cat_id = "0"
    var cat_Name = ""
    var emotion_Id = "0"
    var emotion_Name = ""
    var isFavourite = false
    var rating = -1
    
    @IBOutlet weak var viewPause: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblGuidedFlowType: UILabel!
    @IBOutlet weak var lblGuidedName: UILabel!
    @IBOutlet weak var spinnerImage: UIImageView!
    @IBOutlet weak var btnFavourite: UIButton!
    
    
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor.init(hexString: "#00EBA9")!.cgColor
    let gradientTwo = UIColor.init(hexString: "#49298A")!.cgColor
    let gradientThree = UIColor.init(hexString: "#001252")!.cgColor
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
      //  self.downloadFileFromURL(url: URL.init(string: self.audioData.audio_Url)!)
        //self.playAudioFile(fileName: URL.init(string: self.audioData.audio_Url)!)
        self.play(url: URL.init(string: self.audioData.audio_Url)!)
        self.lblTimer.text = self.secondsToMinutesSeconds(second: self.audioData.audio_Duration)
        self.lblGuidedName.text = "\(self.audioData.audio_Name) \(self.audioData.author_name)"
        if self.appPreference.getGuideType() == "pratical" {
            self.lblGuidedFlowType.text = "Practical ~ \(self.cat_Name) ~ \(self.emotion_Name)"
        }else {
            self.lblGuidedFlowType.text = "Spiritual ~ \(self.cat_Name) ~ \(self.emotion_Name)"
        }
        
        self.seconds = self.audioData.audio_Duration
        // Do any additional setup after loading the view.
    }
    func play(url:URL) {
        print("playing \(url)")
            let playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem:playerItem)
            player.volume = 1.0
            player.play()
            self.isPlayer = true
    }
//    func downloadFileFromURL(url:URL){
//       // WWMHelperClass.showSVHud()
//        var downloadTask:URLSessionDownloadTask
//        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (resultUrl, response, error) in
////            DispatchQueue.main.async {
////                WWMHelperClass.dismissSVHud()
////            }
//            if let playUrl = resultUrl {
//                self.playAudioFile(fileName: playUrl)
//            }
//
//        })
////        downloadTask = URLSession.sharedSession.downloadTaskWithURL(url, completionHandler: { [weak self](URL, response, error) -> Void in
////            self?.play(URL)
////        })
//
//        downloadTask.resume()
//
//    }
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
       // self.playerAmbient.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        self.timer.invalidate()
        self.spinnerImage.layer.removeAllAnimations()
        self.animateGradient(animate: false)
        
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
        self.spinnerImage.rotate360Degrees()
        //self.spinnerImage.layer.removeAllAnimations()
        //self.rotationImage()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    func setUpView() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        //self.playAmbientSoundAudioFile(fileName: settingData.ambientChime!)
    }
    func rotationImage() {
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: {
            
            self.spinnerImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 2))
        }) { (finished) in
            self.rotationImage()
        }
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        self.pauseAction()
        
    }

//    func playAudioFile(fileName:URL) {
//
//
//        do {
//            //try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//           // try AVAudioSession.sharedInstance().setActive(true)
//            player = try AVAudioPlayer.init(contentsOf: fileName)
//            player.prepareToPlay()
//            player.play()
//            self.isPlayer = true
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    @objc func updateTimer() {
        if isPlayer {
            
            let remainingTime = self.seconds - Int(self.player.currentTime().seconds)
            self.lblTimer.text = self.secondsToMinutesSeconds(second: remainingTime)
            if remainingTime == 0 {
                self.moveToFeedBack()
            }
        }
        
    }

    var ismove = false
    func moveToFeedBack() {
        if !ismove {
            ismove = true
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
            vc.type = "Post"
            vc.meditationID = "0"
            vc.levelID = "0"
            vc.category_Id = self.cat_id
            vc.emotion_Id = self.emotion_Id
            vc.audio_Id = "\(audioData.audio_Id)"
            vc.rating = "\(self.rating)"
            vc.watched_duration = "\(self.player.currentTime().seconds)"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }

    func pauseAction() {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = false
            self.isStop = true
            self.spinnerImage.layer.removeAllAnimations()
            self.animateGradient(animate: false)
            self.player.pause()
        }, completion: nil)
    }
    // MARK:- Button Action
    
    @IBAction func btnResumeAction(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewPause.isHidden = true
            self.isStop = false
            self.player.play()
            self.spinnerImage.rotate360Degrees()
            self.animateGradient(animate: true)
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
        animateGradient(animate: true)
        self.isStop = false
        self.player.play()
        self.spinnerImage.rotate360Degrees()
        alertPopupView.removeFromSuperview()
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.moveToFeedBack()
        alertPopupView.removeFromSuperview()
    }
    
    @IBAction func btnPauseAction(_ sender: Any) {
        if !isStop {
            self.isStop = true
            self.spinnerImage.layer.removeAllAnimations()
            self.player.pause()
        }
        
        animateGradient(animate: false)
        
        self.xibCall()
    }
    
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





extension WWMGuidedMeditationTimerVC: CAAnimationDelegate {
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

//extension WWMGuidedMeditationTimerVC: WWMWisdomFeedbackDelegate{
//    func videoURl(url: String) {
//
//    }
//
//    func refreshView() {
//        self.isStop = false
//         self.ismove = false
//        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
//        self.downloadFileFromURL(url: URL.init(string: self.audioData.audio_Url)!)
//       self.lblTimer.text = self.secondsToMinutesSeconds(second: self.seconds)
//    }
//}

    

