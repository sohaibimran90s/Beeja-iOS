//
//  WWMWisdomFeedbackVC.swift
//  Meditation
//
//  Created by Prema Negi on 22/04/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

protocol WWMWisdomFeedbackDelegate{
    func videoURl(url: String)
    func refreshView()
}

class WWMWisdomFeedbackVC: WWMBaseViewController {

    @IBOutlet weak var lblFlowType: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var lblSession: UILabel!
    
    var completionTimeVideo: Double = 0.0
    var isLiked: Bool = false
    var cat_id: String = "0"
    var video_id: String = "0"
    var rating = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var isGuided = false
    var videoURL: String = ""
    var meditationType = ""
    var flowType = ""
    var delegate: WWMWisdomFeedbackDelegate?
    
    let gradient = CAGradientLayer()
    let gradient1 = CAGradientLayer()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
    }
    
    func setUpView(){
        
        self.setNavigationBar(isShow: false, title: "")
        lblSession.text = "Did you like the\nsession?"
        self.lblFlowType.text = self.flowType
        self.lblMeditationType.text = self.meditationType
        self.btnYes.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnYes.layer.borderWidth = 1.0
        
        self.btnNo.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnNo.layer.borderWidth = 1.0
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0).cgColor, UIColor(red: 87.0/255.0, green: 50.0/255.0, blue: 163.0/255.0, alpha: 1.0).cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
        
        self.lblRemainingTime.text = "\(self.secondsToMinutesSeconds(second: Int(self.completionTimeVideo)))"
    }

    func secondsToMinutesSeconds (second : Int) -> String {
        
        return String.init(format: "%d:%02d min", second/60,second%60)
    }
    

    func wisdomFeedback(param: [String: Any]) {
        if isGuided {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
            vc.type = "Post"
            vc.meditationID = "0"
            vc.levelID = "0"
            vc.category_Id = self.cat_id
            vc.emotion_Id = self.emotion_Id
            vc.audio_Id = self.audio_Id
            vc.rating = self.rating
            vc.watched_duration = "\(Int(self.completionTimeVideo))"
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            WWMHelperClass.showSVHud()
            WWMWebServices.requestAPIWithBody(param:param , urlString: URL_WISHDOMFEEDBACK, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
                if sucess {
                    if let success = result["success"] as? Bool {
                        print(success)
                        self.navigationController?.popToRootViewController(animated: true)
                    }else {
                        WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                    }
                }else{
                    if error != nil {
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
                WWMHelperClass.dismissSVHud()
            }
        }
        
    }
    
    
    @IBAction func btnYesAction(_ sender: Any) {
        self.rating = "1"
        
        let param = [
            "user_id": self.appPreference.getUserID(),
            "category_id": self.cat_id,
            "video_id": self.video_id,
            "watched_duration": Int(self.completionTimeVideo),
            "rating" : self.rating
            ] as [String : Any]
        
        print(param)
        self.wisdomFeedback(param: param as Dictionary<String, Any>)
    }
    
    @IBAction func btnNoAction(_ sender: Any) {
        self.rating = "-1"
        let param = [
            "user_id": self.appPreference.getUserID(),
            "category_id": self.cat_id,
            "video_id": self.video_id,
            "watched_duration": Int(self.completionTimeVideo),
            "rating" : self.rating
            ] as [String : Any]
        
        print(param)
        self.wisdomFeedback(param: param as Dictionary<String, Any>)
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        self.rating = "0"
        
        let param = [
            "user_id": self.appPreference.getUserID(),
            "category_id": self.cat_id,
            "video_id": self.video_id,
            "watched_duration": Int(self.completionTimeVideo),
            "rating" : self.rating
            ] as [String : Any]
        
        print(param)
        self.wisdomFeedback(param: param as Dictionary<String, Any>)
    }
    
    @IBAction func btnRefreshAction(_ sender: Any) {
        if isGuided {
            delegate?.refreshView()
        }else {
        delegate?.videoURl(url: self.videoURL)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
