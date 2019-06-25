//
//  WWMGuidedNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedNavVC: WWMBaseViewController {

    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Dropdown Outlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var lblPractical: UILabel!
    @IBOutlet weak var lblSpritual: UILabel!
    @IBOutlet weak var imgPractical: UIImageView!
    @IBOutlet weak var imgSpritual: UIImageView!
    
    var arrGuidedList = [WWMGuidedData]()
    var type = "practical"
    var typeTitle = ""
    var guided_type = ""
    
    var containertapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dropDownView.isHidden = true
        
        containertapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDropDownTap(_:)))
        containertapGesture.delegate = self as? UIGestureRecognizerDelegate
        
        KNOTIFICATIONCENTER.addObserver(self, selector: #selector(self.methodOfGuidedDropDown(notification:)), name: Notification.Name("guidedDropDownClicked"), object: nil)

        if self.appPreference.getGuideType() == "practical"{
            self.typeTitle = "Practical Guidance"
            self.setUpNavigationBarForDashboard(title: "Practical Guidance")
            self.type = "practical"
            
            self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.imgSpritual.isHidden = true
            self.imgPractical.isHidden = false
        }else {
            self.typeTitle = "Spiritual Guidance"
            self.setUpNavigationBarForDashboard(title: "Spiritual Guidance")
            self.type = "spiritual"
            
            self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.imgSpritual.isHidden = false
            self.imgPractical.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
    }
    
    @objc func handleDropDownTap(_ sender: UITapGestureRecognizer) {
        self.dropDownView.isHidden = true
        containerView.removeGestureRecognizer(containertapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getGuidedListAPI()
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
    }
    
    @objc func methodOfGuidedDropDown(notification: Notification){
        containerView.addGestureRecognizer(containertapGesture)
        self.dropDownView.isHidden = false
        if self.appPreference.getGuideType() == "practical"{
            self.type = "guided"
            guided_type = "practical"
            self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.imgSpritual.isHidden = true
            self.imgPractical.isHidden = false
        }else{
            self.type = "guided"
            guided_type = "spiritual"
            self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.imgSpritual.isHidden = false
            self.imgPractical.isHidden = true
        }
    }
    
    @IBAction func btnPracticalClicked(_ sender: UIButton) {
        guided_type = "practical"
        self.type = "guided"
        self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
        self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
        self.imgSpritual.isHidden = true
        self.imgPractical.isHidden = false
        
        self.meditationApi()
    }
    
    @IBAction func btnSpritualClicked(_ sender: UIButton) {
        guided_type = "spiritual"
        self.type = "guided"
        self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
        self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
        self.imgSpritual.isHidden = false
        self.imgPractical.isHidden = true
        
        self.meditationApi()
    }
    
    func meditationApi() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"         : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : type,
            "guided_type" : guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsProfileCompleted(value: true)
                self.appPreference.setType(value: self.type)
                self.appPreference.setGuideType(value: self.guided_type)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else {
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
    
    
    func setAnimationForExpressMood() {
        
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutExpressMoodViewWidth.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func btnExpressMoodAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
        vc.type = "Pre"
        vc.meditationID = "0"
        vc.levelID = "0"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK : API Calling
    
    func getGuidedListAPI() {
        
        self.dropDownView.isHidden = true
        self.view.endEditing(true)
        
        if arrGuidedList.count > 0 {
            //WWMHelperClass.showSVHud()
            WWMHelperClass.showLoaderAnimate(on: self.view)
        }
        
        
        let param = ["guided_type":self.type]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    if let wisdomList = result["result"] as? [[String:Any]] {
                        self.arrGuidedList.removeAll()
                        for data in wisdomList {
                            let wisdomData = WWMGuidedData.init(json: data)
                            self.arrGuidedList.append(wisdomData)
                        }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedDashboardVC") as! WWMGuidedDashboardVC
                        vc.arrGuidedList = self.arrGuidedList
                        vc.type = self.typeTitle
                        self.addChild(vc)
                        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                        self.containerView.addSubview((vc.view)!)
                        vc.didMove(toParent: self)
                    }
                    
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as! String, title: kAlertTitle)
                }
                
            }else {
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
}
