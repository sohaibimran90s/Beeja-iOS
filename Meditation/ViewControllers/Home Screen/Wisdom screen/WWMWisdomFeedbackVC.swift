//
//  WWMWisdomFeedbackVC.swift
//  Meditation
//
//  Created by Prema Negi on 22/04/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWisdomFeedbackVC: WWMBaseViewController {

    @IBOutlet weak var btnLikeDislike: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var lblMinCompletion: UILabel!
    
    var completionTimeVideo: Double = 0.0
    var isLiked: Bool = false
    var cat_id: String = ""
    var video_id: String = ""
    var rating = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
    }
    
    func setUpView(){
        self.btnLikeDislike.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnLikeDislike.layer.borderWidth = 1.0
        
        
        self.lblRemainingTime.text = "Completion Time: \(self.secondsToMinutesSeconds(second: Int(self.completionTimeVideo)))"
        
        if self.completionTimeVideo < 1.0{
            self.lblMinCompletion.text = "YES"
        }else{
            self.lblMinCompletion.text = "NO"
        }
    }

    func secondsToMinutesSeconds (second : Int) -> String {
        
        return String.init(format: "%d:%02d min", second/60,second%60)
    }
    
    func likeDislike(){
        if isLiked{
            self.rating = "0"
            self.btnLikeDislike.backgroundColor = UIColor.white
            self.btnLikeDislike.setTitle("Dislike", for: .normal)
            self.isLiked = false
        }else{
            self.rating = "1"
            self.btnLikeDislike.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            self.btnLikeDislike.setTitle("Like", for: .normal)
            self.isLiked = true
        }
    }
    
    @IBAction func btnLikeAction(_ sender: Any) {
        self.likeDislike()
    }
    
    func wisdomFeedback(param: [String: Any]) {
        
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
    
    @IBAction func btnDoneAction(_ sender: Any) {
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
}
