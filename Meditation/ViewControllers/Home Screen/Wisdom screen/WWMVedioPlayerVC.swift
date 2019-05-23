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
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBarForWisdomVideo(title: "")
//        btnFavourite = UIButton.init(frame: CGRect.init(x: (self.view.frame.size.width/2)-50, y: 24, width: 48, height: 44))
//        btnFavourite.layer.cornerRadius = 10
//        btnFavourite.clipsToBounds = true
//        btnFavourite.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 0.25)
//        btnFavourite.contentMode = .scaleAspectFit
//        btnFavourite.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
//        btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
//
//        btnFavourite.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
//        let controller = AVPlayerViewController()
//        controller.player = self.player
//        let yourView = controller.view
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCustomTap(sender:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1;
//        tapGestureRecognizer.delegate = self
//        yourView?.addGestureRecognizer(tapGestureRecognizer)
//
//        controller.view.addSubview(btnFavourite)
//        parent?.modalPresentationStyle = .fullScreen
//        self.parent?.present(controller, animated: false, completion: nil)
//       // parentViewController.presentViewController(controller, animated: false, completion: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
       // timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    @objc func appMovedToBackground() {
        self.finishVideo()
        
    }
    var notificationCenter = NotificationCenter.default
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
        btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
        btnFavourite.addTarget(self, action: #selector(btnFavouriteAction(_:)), for: .touchUpInside)
        btnFavourite.contentMode = .scaleAspectFit
        if vote {
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }

        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage.init(named: "Close_Icon"), for: .normal)
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
        self.notificationCenter.removeObserver(self)
        self.player?.pause()
        let watchDuration = self.player?.currentTime().seconds ?? 0
        let param = [
            "user_id": self.appPreference.getUserID(),
            "category_id": self.cat_Id,
            "video_id": self.video_id,
            "watched_duration": Int(watchDuration),
            "rating" : self.rating
            ] as [String : Any]
        
        print(param)
        self.wisdomFeedback(param: param as Dictionary<String, Any>)
        self.navigationController?.popViewController(animated: true)
    }
    
    func wisdomFeedback(param: [String: Any]) {
        WWMHelperClass.showSVHud()
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_WISHDOMFEEDBACK, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
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
            WWMHelperClass.dismissSVHud()
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
    @objc func onCustomTap(sender: UITapGestureRecognizer) {
        
        if btnFavourite.alpha > 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.btnFavourite.alpha = 0;
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.btnFavourite.alpha = 1;
            })
        }
    }
    
    
    
}

