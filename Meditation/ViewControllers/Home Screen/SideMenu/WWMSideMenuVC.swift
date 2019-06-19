//
//  WWMSideMenuVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSideMenuVC: WWMBaseViewController {

    @IBOutlet weak var btnLearn: UIButton!
    @IBOutlet weak var btnGuided: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    var guideStart = WWMGuidedStart()
    var guided_type = ""
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.userData.type == "timer" {
            self.btnTimer.setTitleColor(UIColor.init(hexString: "#00eba9")!, for: .normal)
        }else if self.userData.type == "guided" {
            self.btnGuided.setTitleColor(UIColor.init(hexString: "#00eba9")!, for: .normal)
        }else if self.userData.type == "learn" {
            self.btnLearn.setTitleColor(UIColor.init(hexString: "#00eba9")!, for: .normal)
        }
        self.lblName.text = self.appPreference.getUserName()
        if self.userData.city != ""  && self.userData.country != "" {
            self.lblLocation.text = "\(self.userData.city), \(self.userData.country)"
        }else {
            self.lblLocation.text = "\(self.userData.city) \(self.userData.country)"
        }
        print(WWMHelperClass.getVersion())
        self.lblVersion.text = WWMHelperClass.getVersion()
        
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.title = ""
    }
    
    // MARK:- Button Action
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnOurStoryAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_OurStory
        vc.strType = "Our Story"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSupportAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSupportVC") as! WWMSupportVC
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    @IBAction func btnFAQAction(_ sender: Any) {
        self.openWebView(index: 7)
    }
    @IBAction func btnFindCourseAction(_ sender: Any) {
        self.openWebView(index: 8)
    }
    
    @IBAction func btnLearnAction(_ sender: Any) {
        self.openWebView(index: 9)
    }
    
    @IBAction func btnGuidedAction(_ sender: Any) {
       // self.openWebView(index: 10)
        
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
        self.type = "guided"
        self.meditationApi()
        
    }
    @IBAction func btnSpritualAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        guided_type = "spiritual"
        self.type = "guided"
        self.meditationApi()
    }
    
    
    @IBAction func btnTimerAction(_ sender: Any) {
        self.type = "timer"
        self.guided_type = ""
        self.meditationApi()
    }
    
    @IBAction func btnUpgradeBeejaAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnFacebookPageAction(_ sender: Any) {
        let url = URL.init(string: URL_Facebook)
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            self.openWebView(index: 2)
        }
        
    }
    @IBAction func btnTwitterPageAction(_ sender: Any) {
        let url = URL.init(string: URL_Twitter)
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            self.openWebView(index: 4)
        }
    }
    @IBAction func btnLinkedInPageAction(_ sender: Any) {
        let url = URL.init(string: URL_LinkedIn)
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            self.openWebView(index: 5)
        }
    }
    @IBAction func btnInstaPageAction(_ sender: Any) {
        let url = URL.init(string: URL_Insta)
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            self.openWebView(index: 1)
        }
        
    }
    @IBAction func btnYoutubePageAction(_ sender: Any) {
        let url = URL.init(string: URL_YouTube)
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            self.openWebView(index: 3)
        }
        
    }
    @IBAction func btnWebPageAction(_ sender: Any) {
        self.openWebView(index: 6)
    }
    
    
    func openWebView(index:Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        switch index {
        case 1:
            vc.strUrl = URL_Insta
            vc.strType = "Instagram"
        case 2:
            vc.strUrl = URL_Facebook
            vc.strType = "Facebook"
        case 3:
            vc.strUrl = URL_YouTube
            vc.strType = "You Tube"
        case 4:
            vc.strUrl = URL_Twitter
            vc.strType = "Twitter"
        case 5:
            vc.strUrl = URL_LinkedIn
            vc.strType = "LinkedIn"
        case 6:
            vc.strUrl = URL_WebSite
            vc.strType = "Beeja"
        case 7:
            vc.strUrl = URL_FAQ
            vc.strType = "FAQ"
        case 8:
            vc.strUrl = URL_FINDCOURSE
            vc.strType = "Find a Course"
        case 9:
            vc.strUrl = URL_LEARN
            vc.strType = "Learn"
        case 10:
            vc.strUrl = URL_GUIDED
            vc.strType = "Guided"
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Calling API
    
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
}
