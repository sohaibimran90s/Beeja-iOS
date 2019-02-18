//
//  WWMSideMenuVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSideMenuVC: UIViewController {

    @IBOutlet weak var btnLearn: UIButton!
    @IBOutlet weak var btnGuided: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnTimer.setTitleColor(UIColor.init(hexString: "#00eba9")!, for: .normal)
        
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
        
    }
    
    @IBAction func btnGuidedAction(_ sender: Any) {
        
    }
    
    @IBAction func btnTimerAction(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func btnUpgradeBeejaAction(_ sender: Any) {
        
        
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
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
