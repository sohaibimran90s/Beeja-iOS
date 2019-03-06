//
//  WWMSetMyOwnVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 01/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSetMyOwnVC: WWMBaseViewController {

    @IBOutlet weak var txtViewMeditationName: UITextField!
    @IBOutlet weak var layoutSliderPrepTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var sliderPrepTime: WWMSlider!
    @IBOutlet weak var layoutSliderMeditationTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblMeditationTime: UILabel!
    @IBOutlet weak var sliderMeditationTime: WWMSlider!
    @IBOutlet weak var layoutSliderRestTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var sliderRestTime: WWMSlider!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var userName: UILabel!
    
    var selectedMeditation_Id = ""
    var selectedLevel_Id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
    }
    
    func setUpView() {
        self.userName.text = "Ok You"
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.setUpSliderTimesAccordingToLevels()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderRestTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderMeditationTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
    }
    
    func setUpSliderTimesAccordingToLevels() {
        self.sliderPrepTime.minimumValue = 0
        self.sliderPrepTime.maximumValue = 3600
        self.sliderPrepTime.value = 0
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        
        self.sliderMeditationTime.minimumValue = 0
        self.sliderMeditationTime.maximumValue = 7200
        self.sliderMeditationTime.value = 0
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        
        self.sliderRestTime.minimumValue = 0
        self.sliderRestTime.maximumValue = 3600
        self.sliderRestTime.value = 0
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) secs"
        }else {
            return String.init(format: "%d:%d mins", second/60,second%60)
        }
        
    }
    // MARK: - UIButton Action
    
    
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
    }
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
    }
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    
    @IBAction func btnSaveSettingAction(_ sender: Any) {

        if txtViewMeditationName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter meditation name", title: kAlertTitle)
        }else {
            self.setMyOwnAPI()
        }
    }

    func setMyOwnAPI() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        let param = [
            "user_id":self.appPreference.getUserID(),
            "meditation_name":txtViewMeditationName.text ?? "",
            "prep_time":"\(Int(self.sliderPrepTime.value))",
            "meditation_time":"\(Int(self.sliderMeditationTime.value))",
            "rest_time":"\(Int(self.sliderRestTime.value))",
            "setmyown": 1,
            "level_name": "Beginner",
            "prep_min": "0",
            "prep_max": "3600",
            "rest_min": "0",
            "rest_max": "3600",
            "med_min": "0",
            "med_max": "7200"
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_SETMYOWN, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let result1 = result["result"] as? [String:Any] {
                    self.selectedMeditation_Id = "\(result1["meditation_id"] as! Int)"
                    self.selectedLevel_Id = "\(result1["level_id"] as! Int)"
                    self.meditationApi()
                }else {
                     WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as! String, title: kAlertTitle)
                }

            }else {
                if error != nil {
                     WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
               
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    func meditationApi() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        let param = [
            "meditation_id" : self.selectedMeditation_Id,
            "level_id"         : self.selectedLevel_Id,
            "user_id"       : self.appPreference.getUserID()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let sucessAPI = result["success"] as? Bool {
                    if sucessAPI {
                        self.appPreference.setIsProfileCompleted(value: true)
                        UIView.transition(with: self.welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                            self.welcomeView.isHidden = false
                        }) { (Bool) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                                UIApplication.shared.keyWindow?.rootViewController = vc
                            }
                        }
                    }else {
                        WWMHelperClass.showPopupAlertController(sender: self, message:  result["message"] as! String, title: kAlertTitle)
                    }
                
            }else {
                    if error != nil {
                        WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                    }
                 
            }
            WWMHelperClass.dismissSVHud()
        }
    }

}

}
