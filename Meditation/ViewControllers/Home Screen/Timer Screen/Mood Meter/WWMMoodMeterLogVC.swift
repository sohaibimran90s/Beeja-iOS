//
//  WWMMoodMeterLogVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation

class WWMMoodMeterLogVC: WWMBaseViewController {

    var moodData = WWMMoodMeterData()
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var btnBurnMood: UIButton!
    @IBOutlet weak var btnLogExperience: UIButton!
    @IBOutlet weak var txtViewLog: UITextView!
    
    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var backgroundvedioView = WWMBackgroundVedioView()
     var player: AVPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }

    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.btnBurnMood.layer.borderWidth = 2.0
        self.btnBurnMood.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLogExperience.layer.borderWidth = 2.0
        self.btnLogExperience.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.lblExpressMood.text = moodData.name
        if !moodData.show_burn {
            btnBurnMood.isHidden = true
        }
        if moodData.name != "" {
            self.txtViewLog.text = "I am feeling \(moodData.name) because"
        }
        
        self.txtViewLog.layer.borderColor = UIColor.lightGray.cgColor
        self.txtViewLog.layer.borderWidth = 1.0
        self.txtViewLog.layer.cornerRadius = 2.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnSkipAction(_ sender: Any) {
        self.completeMeditationAPI()
    }
    
    @IBAction func btnBurnMoodAction(_ sender: Any) {
        if self.type == "Pre" {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            self.createBackground(name: "Burn", type: "mp4")
            

        }
       
    }
    func createBackground(name: String, type: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else { return }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        player?.seek(to: CMTime.zero)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodJournalVC") as! WWMMoodJournalVC
        vc.type = self.type
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        vc.meditationID = self.meditationID
        vc.levelID = self.levelID
        vc.moodData = self.moodData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnLogExperienceAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
        }else {
            self.completeMeditationAPI()
        }
    }
    
//    "meditation_type":"Post",
//    "date_time":1551179906846,
//    "tell_us_why":"I am feeling Blissful because bjkj",
//    "prep_time":20,
//    "meditation_time":0,
//    "rest_time":0,
//    "meditation_id":1,
//    "level_id":1,
//    "user_id":"7",
//    "mood_id":18
    
    func completeMeditationAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_id":self.appPreference.getUserID(),
            "meditation_type":type,
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why":txtViewLog.text,
            "prep_time":prepTime,
            "meditation_time":meditationTime,
            "rest_time":restTime,
            "meditation_id": self.meditationID,
            "level_id":self.levelID,
            "mood_id":self.moodData.id == -1 ? "" : self.moodData.id,
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.logExperience()
                }else {
                    self.saveToDB(param: param)
                }
                
            }else {
                self.saveToDB(param: param)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        self.logExperience()
    }
    
    
    
    
    
    func logExperience() {
        let alert = UIAlertController.init(title: "Your Meditation experienced has been logged", message: nil, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: {
                if self.type == "Pre" {
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.popToRootViewController(animated: false)
                }else {
                    
                    if !self.moodData.show_burn && self.moodData.id != -1 {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodShareVC") as! WWMMoodShareVC
                        vc.moodData = self.moodData
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        self.navigationController?.isNavigationBarHidden = false
                        
                        if let tabController = self.tabBarController as? WWMTabBarVC {
                            tabController.selectedIndex = 3
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    
                }
            })
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
