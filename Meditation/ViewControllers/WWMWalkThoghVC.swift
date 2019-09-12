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
    
    var value: String = "help"
    var videoCompleted = 0
    var watched_duration = ""
    let reachable = Reachabilities()
    let appPreffrence = WWMAppPreference()
    
    var lat = ""
    var long = ""
    
    var player1: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("watched walk... \(self.watched_duration)")
        
        let videoFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewVideo.frame = videoFrame
        
        setNavigationBar(isShow:false,title:"")
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.btnCrossSkip.isHidden = false
        
        if (value == "help" || value == "learnStepList"){
            self.btnCrossSkip.setBackgroundImage(UIImage(named: "close_small"), for: .normal)
            btnCrossSkip.setTitle("", for: .normal)
        }else if value == "SignupLetsStart"{
            self.btnCrossSkip.isHidden = true
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
        
        UIApplication.shared.isStatusBarHidden = true
       // player1?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
        btnCrossSkip.setTitle("", for: .normal)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
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
            guard let path = Bundle.main.path(forResource: "app_walkthrough", ofType:"mp4") else {
                debugPrint("video.mp4 not found")
                return
            }
            
            
            viewVideo.configure(url: "\(path)")
            
            player1 = AVPlayer(url: URL(fileURLWithPath: path))
            player1?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
            let playerLayer = AVPlayerLayer(player: player1)
            playerLayer.frame = self.view.frame
            playerLayer.videoGravity = AVLayerVideoGravity.resize
            playerLayer.goFullscreen()
            self.view.layer.addSublayer(playerLayer)
            player1?.seek(to: CMTime.zero)
            
           // NotificationCenter.default.addObserver(self, selector:#selector(reachTheEndOfTheVideo1(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player1?.currentItem)
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
            let playerLayer = AVPlayerLayer(player: player1)
            playerLayer.frame = self.view.frame
            playerLayer.videoGravity = AVLayerVideoGravity.resize
            self.viewVideo.layer.addSublayer(playerLayer)
            player1?.seek(to: CMTime.zero)
            
            player1?.play()
            self.videoCompleted = 1
            return
            
        
        }else if value == "learnStepList"{
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
    
    @IBAction func btnSkipCrossClicked(_ sender: UIButton) {
        self.viewVideo.stop()
        if (value == "help" || value == "learnStepList"){
            self.navigationController?.popViewController(animated: true)
        }else{
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
        if self.videoCompleted == 1{
            if !reachable.isConnectedToNetwork() {
                self.navigationController?.popViewController(animated: true)
                return
            }
            if value == "help"{
                self.navigationController?.popViewController(animated: true)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                self.navigationController?.pushViewController(vc, animated: true)
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
