//
//  WWMMoodMeterLogVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation
import IQKeyboardManagerSwift

class WWMMoodMeterLogVC: WWMBaseViewController {

    var moodData = WWMMoodMeterData()
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var btnBurnMood: UIButton!
    @IBOutlet weak var btnLogExperience: UIButton!
    @IBOutlet weak var txtViewLog: UITextView!
    @IBOutlet weak var lblTextCount: UILabel!

    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var backgroundvedioView = WWMBackgroundVedioView()
    var player: AVPlayer?
    var popupTitle: String = ""
    var hidShowMoodMeter = "Show"
    
    var category_Id = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var watched_duration = "0"
    var rating = "0"
    
    var alertPopup = WWMAlertPopUp()
    
    var tap = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Next"
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.view.addGestureRecognizer(gesture)

        self.setUpUI()
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.txtViewLog.resignFirstResponder()
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
    }

    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnBurnMood.layer.borderWidth = 2.0
        self.btnBurnMood.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLogExperience.layer.borderWidth = 2.0
        self.btnLogExperience.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.txtViewLog.delegate = self
        
        if moodData.name != ""{
            self.lblExpressMood.text = "\(moodData.name)."
        }else{
            self.lblExpressMood.text = ""
        }
        if !moodData.show_burn {
            btnBurnMood.isHidden = true
        }
        if moodData.name != "" {
            self.txtViewLog.text = "I am feeling \(moodData.name) because"
            self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
        }
        
        //self.txtViewLog.layer.borderColor = UIColor.lightGray.cgColor
        //self.txtViewLog.layer.borderWidth = 1.0
        self.txtViewLog.layer.cornerRadius = 5.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewLog.isEditable = true
        self.txtViewLog.becomeFirstResponder()
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        self.txtViewLog.text = ""
        self.completeMeditationAPI()
    }
    
    @IBAction func btnBurnMoodAction(_ sender: Any) {
        self.createBackground(name: "Burn", type: "mp4")
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
        if self.type == "Pre" {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodJournalVC") as! WWMMoodJournalVC
            vc.type = self.type
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            vc.moodData = self.moodData
            vc.category_Id = self.category_Id
            vc.emotion_Id = self.emotion_Id
            vc.audio_Id = self.audio_Id
            vc.rating = self.rating
            vc.watched_duration = self.watched_duration
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLogExperienceAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
        }else {
            self.completeMeditationAPI()
        }
    }
    
    func xibCall(){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        //2. If user has not selected mood and skipped but has entered journal inputs. E.g., Thanks, your journal entry has been recorded
        alertPopup.lblTitle.text = self.popupTitle
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
                self.navigateToDashboard()
            }
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
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "type":self.userData.type,
            "category_id" : self.category_Id,
            "emotion_id" : self.emotion_Id,
            "audio_id" : self.audio_Id,
            "guided_type" : self.userData.guided_type,
            "watched_duration" : self.watched_duration,
            "rating" : self.rating,
            "user_id":self.appPreference.getUserID(),
            "meditation_type":type,
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why":txtViewLog.text,
            "prep_time":prepTime,
            "meditation_time":meditationTime,
            "rest_time":restTime,
            "meditation_id": self.meditationID,
            "level_id":self.levelID,
            "mood_id":self.moodData.id == -1 ? "0" : self.moodData.id,
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
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
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
        
        if self.txtViewLog.text != "" {
            
            self.popupTitle = "Great job! Your journal has been updated."
            self.xibCall()
            
            
//            let alert = UIAlertController.init(title: "Your Meditation experienced has been logged", message: nil, preferredStyle: .alert)
//
//            self.present(alert, animated: true, completion: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.dismiss(animated: true, completion: {
//                    self.navigateToDashboard()
//                })
//            }
        }else {
            
           if self.hidShowMoodMeter == "Show"{
                self.popupTitle = "Thanks! Your mood tracker has been updated."
                self.xibCall()
            }else{
                self.navigateToDashboard()
            }
        }
    }

    func navigateToDashboard() {
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
                    tabController.selectedIndex = 4
                    for index in 0..<tabController.tabBar.items!.count {
                        let item = tabController.tabBar.items![index]
                        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                        if index == 4 {
                            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                        }
                    }
                }
                self.navigationController?.popToRootViewController(animated: false)
            }
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

extension WWMMoodMeterLogVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewLog.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //self.view.removeGestureRecognizer(tap)
//        if  txtViewLog.text == "" {
//            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
//        }else {
//            self.completeMeditationAPI()
//        }
    }
}
