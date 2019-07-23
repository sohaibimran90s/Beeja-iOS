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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewVideo.frame = videoFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setNavigationBar(isShow:false,title:"")
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if (value == "help" || value == "learnStepList"){
            self.btnCrossSkip.setBackgroundImage(UIImage(named: "close_small"), for: .normal)
            btnCrossSkip.setTitle("", for: .normal)
        }else{
            self.btnCrossSkip.setBackgroundImage(UIImage(named: ""), for: .normal)
            
            let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            let attributeString = NSMutableAttributedString(string: "Skip",
                                                            attributes: attributes)
            btnCrossSkip.setAttributedTitle(attributeString, for: .normal)
        }
        
        self.playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        btnCrossSkip.setTitle("", for: .normal)
    }
    
    //MARK:- video function
    func playVideo() {
        
        let videoURL = Bundle.main.url(forResource: "walkthough", withExtension: "mp4")
        if let videoURL = videoURL {
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
        }else if value == "learnCongrats"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
            
            WWMHelperClass.selectedType = "learn"
            vc.watched_duration = self.watched_duration
            self.navigationController?.pushViewController(vc, animated: false)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        print("abc....***** \(self.videoCompleted )")
        if self.videoCompleted == 1{
            if value == "help"{
                self.navigationController?.popViewController(animated: true)
            }else if value == "learnCongrats"{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
                
                WWMHelperClass.selectedType = "learn"
                vc.watched_duration = self.watched_duration
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}
