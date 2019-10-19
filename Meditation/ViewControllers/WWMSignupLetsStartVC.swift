//
//  WWMSignupLetsStartVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSignupLetsStartVC: WWMBaseViewController {

    
    @IBOutlet weak var btnKnowMeditation: UIButton!
    @IBOutlet weak var btnGuide: UIButton!
    @IBOutlet weak var btnLearn: UIButton!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var userName: UILabel!
    
    var guideStart = WWMGuidedStart()
    
    var guided_type = ""
     override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        let userName: String = self.appPreference.getUserName()
        if userName != ""{
            if userName.contains(" "){
                let userNameArr = userName.components(separatedBy: " ")
                self.userName.text = "Ok \(userNameArr[0]),"
            }else{
                self.userName.text = "Ok \(self.appPreference.getUserName()),"
            }
        }else{
            self.userName.text = "Ok You,"
        }
        
        self.setNavigationBar(isShow: false, title: "")
        
        self.btnGuide.layer.borderWidth = 2.0
        self.btnGuide.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLearn.layer.borderWidth = 2.0
        self.btnLearn.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnKnowMeditation.layer.borderWidth = 2.0
        self.btnKnowMeditation.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }

    @IBAction func btnKnowMeditationAction(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SPLASH_PAGE", itemId: "I_KNOW_HOW", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMeditationListVC") as! WWMMeditationListVC
        vc.type = "timer"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnGuideAction(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SPLASH_PAGE", itemId: "GUIDE_ME", itemName: "")
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
//        vc.strUrl = URL_GUIDED
//        vc.strType = "Guided"
//        self.navigationController?.pushViewController(vc, animated: true)
        guideStart = UINib(nibName: "WWMGuidedStart", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMGuidedStart
        let window = UIApplication.shared.keyWindow!
        
        guideStart.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        guideStart.btnClose.addTarget(self, action: #selector(btnGuideCloseAction(_:)), for: .touchUpInside)
        guideStart.btnMoreInformation.addTarget(self, action: #selector(btnMoreInformationActions(_:)), for: .touchUpInside)
        guideStart.btnSpritual.addTarget(self, action: #selector(btnSpritualAction(_:)), for: .touchUpInside)
        guideStart.btnPractical.addTarget(self, action: #selector(btnPracticalAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(guideStart)
    }
    
    
    @IBAction func btnGuideCloseAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
    }
    
    @IBAction func btnMoreInformationActions(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_MOREINFO
        vc.strType = "More Information"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPracticalAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        guided_type = "practical"
        self.meditationApi(type: "guided")
        
    }
    @IBAction func btnSpritualAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        guided_type = "spiritual"
        self.meditationApi(type: "guided")
    }
    
    @IBAction func btnLearnAction(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SPLASH_PAGE", itemId: "LIKE_TO_LEARN", itemName: "")
        guided_type = ""
        self.meditationApi(type: "learn")
    }
    
  // Calling API
    func meditationApi(type: String) {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : 1,
            "level_id"         : 1,
            "user_id"       : self.appPreference.getUserID(),
            "type" : type,
            "guided_type" : guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMSignupLetsStartVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsProfileCompleted(value: true)
                
                self.appPreference.setType(value: type)
                self.appPreference.setGuideType(value: self.guided_type)
                
                UIView.transition(with: self.welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.welcomeView.isHidden = false
                }) { (Bool) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        self.appPreference.setGetProfile(value: true)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
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
