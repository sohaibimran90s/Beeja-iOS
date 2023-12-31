//
//  WWMVedioPlayerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/05/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVKit

class WWMVedioPlayerVC: AVPlayerViewController,AVPlayerViewControllerDelegate {

    let appPreference = WWMAppPreference()
    var btnFavourite = UIButton()
    var rating = 0
    var isFavourite = false
    var vote = false
    var video_id: String = ""
    var cat_Id: String = ""
    var video_Name: String = ""
    var timer = Timer()
    var timerInterval = 10
    var notificationCenter = NotificationCenter.default
    var playerStatus: String = "Playing"
    
    var playerAudio:  AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBarForWisdomVideo(title: "")
        
        self.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCustomTap(sender:)))
         tapGestureRecognizer.numberOfTapsRequired = 1;
         tapGestureRecognizer.delegate = self
         self.view.addGestureRecognizer(tapGestureRecognizer)
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.timerNavigation()
        
        self.playSound(name: "AMBIENTADAPTATIONLOOP")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.playerAudio?.stop()
        self.timer.invalidate()
    }
    
    @objc func automaticHiddenNavigation(){
        print("automaticHiddenNavigation.........")
        if self.playerStatus == "Playing"{
            self.navigationController?.navigationBar.isHidden = true
        }else{
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    
    func timerNavigation(){
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timerInterval), target: self, selector: #selector(automaticHiddenNavigation), userInfo: nil, repeats: false)
    }
    
    @objc func onCustomTap(sender: UITapGestureRecognizer) {
    
        print("onCustomTap.........\(self.playerStatus)")

        if self.playerStatus == "Playing"{
            self.navigationController?.navigationBar.isHidden = false
            self.timerInterval = Int(5)
            self.timerNavigation()
        }else{
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if self.player?.rate == 1  {
                print("Playing")
                self.playerStatus = "Playing"
                self.playerAudio?.play()
                self.navigationController?.navigationBar.isHidden = false
                self.timerInterval = Int(4.6)
                self.timerNavigation()
            }else{
                print("Stop")
                self.playerStatus = "Stop"
                self.playerAudio?.pause()
                self.navigationController?.navigationBar.isHidden = false
            }
        }
    }
    
    @objc func appMovedToBackground() {
        self.finishVideo()
    }

    @objc func updateTimer() {
        
        if self.isReadyForDisplay {
            let remainingTime = Int(self.player?.currentTime().seconds ?? -1)
            if remainingTime == 0 {
                self.finishVideo()
            }
        }
    }
    
    func setUpNavigationBarForWisdomVideo(title:String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.title = title
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
         btnFavourite = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        btnFavourite.setImage(UIImage.init(named: "fav_small_off"), for: .normal)
        btnFavourite.addTarget(self, action: #selector(btnFavouriteAction(_:)), for: .touchUpInside)
        btnFavourite.contentMode = .scaleAspectFit
        if vote {
            self.btnFavourite.setImage(UIImage.init(named: "fav_small_on"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }

        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage.init(named: "close_small"), for: .normal)
        backButton.addTarget(self, action: #selector(btnBackAction(_:)), for: .touchUpInside)
        backButton.contentMode = .scaleAspectFit

        let leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        let rightBarButtonItem = UIBarButtonItem.init(customView: btnFavourite)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.finishVideo()
    }
    
    func finishVideo() {
        
        let wisdomVideoDataDB = WWMHelperClass.fetchDB(dbName: "DBWisdomVideoData") as! [DBWisdomVideoData]

        for dict1 in wisdomVideoDataDB{
            if dict1.video_id == self.video_id{
                if self.rating == 1{
                    dict1.video_vote = true
                }else{
                    dict1.video_vote = false
                }
                
                WWMHelperClass.saveDb()
            }
        }
        
        self.notificationCenter.removeObserver(self)
        self.player?.pause()
        self.playerAudio?.pause()
        let watchDuration = self.player?.currentTime().seconds ?? 0
        let param = [
            "user_id": self.appPreference.getUserID(),
            "category_id": self.cat_Id,
            "video_id": self.video_id,
            "watched_duration": Int(watchDuration),
            "rating" : self.rating
            ] as [String : Any]
        
        print(param)
        self.navigationController?.navigationBar.isHidden = false
        
        DispatchQueue.global(qos: .background).async {
            self.wisdomFeedback(param: param as Dictionary<String, Any>)
        }
        // Analytics
        var analyticItemId = self.video_Name.uppercased()
        analyticItemId = analyticItemId.replacingOccurrences(of: " ", with: "_")
        if self.rating == 1 {
            WWMHelperClass.sendEventAnalytics(contentType: "WISDOM", itemId: analyticItemId, itemName: "LIKE")
        }
        
        WWMHelperClass.sendEventAnalytics(contentType: "WISDOM", itemId: analyticItemId, itemName: self.convertDurationIntoPercentage(duration: Int(watchDuration)))
        self.navigationController?.popViewController(animated: true)
    }
    func convertDurationIntoPercentage(duration:Int) -> String  {
        if ((self.player?.currentItem?.duration) != nil) {
            let totalTime = CMTimeGetSeconds((self.player?.currentItem!.duration)!)
            var per = (Double(duration)/totalTime)*100
            per = per/10
            per = per.rounded()
            per = per*10
            guard !(per.isNaN || per.isInfinite) else {
                return "0%" // or do some error handling
            }
            return "\(Int(per))%"
        }
        return "0%"
    }
    func wisdomFeedback(param: [String: Any]) {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_WISHDOMFEEDBACK, context: "WWMVedioPlayerVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                   // WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                }
            }else{
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    
    @IBAction func btnFavouriteAction(_ sender: UIButton) {
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
}

extension WWMVedioPlayerVC: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let _touchView = touch.view {
            
            let screenRect:CGRect = UIScreen.main.bounds
            let screenWidth :CGFloat = screenRect.size.width;
            let screenHeight:CGFloat  = screenRect.size.height;
            
            if _touchView.bounds.height == screenHeight && _touchView.bounds.width == screenWidth{
                return true
            }
            
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension WWMVedioPlayerVC: AVAudioPlayerDelegate{
    func playSound(name: String ) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            playerAudio = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            playerAudio?.delegate = self
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            playerAudio?.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    
        print("finished")//It is working now! printed "finished"!
        self.playerAudio?.play()
    }
}

