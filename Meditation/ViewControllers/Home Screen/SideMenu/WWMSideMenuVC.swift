//
//  WWMSideMenuVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import Reachability

class WWMSideMenuVC: WWMBaseViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var freeView: UIView!
    @IBOutlet weak var lblFreeAccount: UILabel!
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var lblPremium: UILabel!
    @IBOutlet weak var btnCloseTrailC: NSLayoutConstraint!

    var guideStart = WWMGuidedStart()
    var guided_type = ""
    var type = ""
    let appPreffrence = WWMAppPreference()
    var city = ""
    var country = ""
    var lat = ""
    var long = ""
    let reachable = Reachabilities()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if WWMHelperClass.hasTopNotch{
            self.btnCloseTrailC.constant = 20
        }else{
            self.btnCloseTrailC.constant = 16
        }
        self.lblVersion.text = WWMHelperClass.getVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.title = ""
        
        DispatchQueue.global(qos: .background).async {
            self.getProfileApiCalled()
        }
        
        if self.appPreffrence.getExpiryDate(){
             self.freeView.isHidden = true
             self.premiumView.isHidden = false
             
             let daysLeft = WWMHelperClass.daysLeft(expiryDate: self.appPreffrence.getExpireDateBackend())
             if daysLeft != -1{
                 self.lblPremium.text = "PREMIUM MEMBER | \(self.appPreffrence.getSubscriptionPlan().uppercased())"
                 if daysLeft > 30{
                     self.lblDaysLeft.text = ""
                 }else{
                     self.lblDaysLeft.text = "\(daysLeft) days left"
                 }
             }
             //print("self.appPreffrence.getExpireDateBackend()... \(self.appPreffrence.getExpireDateBackend())")
         }else{
             self.freeView.isHidden = false
             self.premiumView.isHidden = true
         }
        
         self.lblName.text = self.appPreference.getUserName()
    }
    
    func getProfileApiCalled(){
        if reachable.isConnectedToNetwork() {
                
                var userData = WWMUserData()
                userData = WWMUserData.init(json: self.appPreffrence.getUserData())
                print(userData)
                
                let userData1 = self.appPreffrence.getUserData()
            
                self.lat = userData1["latitude"] as? String ?? ""
                self.long = userData1["longitude"] as? String ?? ""
                self.city = userData1["city"] as? String ?? ""
                self.country = userData1["country"] as? String ?? ""
            
                //print("self.lat+++ \(self.lat) self.long+++ \(self.long) self.city+++ \(self.city) self.country+++ \(self.country)")
                
                self.getProfileDataInBackground(lat: self.lat, long: self.long)
        }
    }
    
        func getProfileDataInBackground(lat: String, long: String){
            let param = [
                "user_id":self.appPreffrence.getUserID(),
                "email":self.appPreffrence.getEmail(),
                "lat": lat,
                "long": long,
                "city":city,
                "country":country
                ] as [String : Any]
                
                //print("param... \(param)")
                
                WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETPROFILE, context: "WWMSideMenuVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                    
                if sucess {
                    if let success = result["success"] as? Bool {
                        if success {
                            if let userProfile = result["user_profile"] as? [String : Any]{
                                //setEmail
                                
                                //print("userProfile+++### \(userProfile)")
                                self.appPreffrence.setEmail(value: userProfile["email"] as? String ?? "")
                                self.appPreffrence.setUserName(value: userProfile["name"] as? String ?? "")
                                self.appPreffrence.setProfileImgURL(value: userProfile["profile_image"] as? String ?? "")
                                self.appPreffrence.setGender(value: userProfile["gender"] as? String ?? "")
                                self.appPreffrence.setDob(value: userProfile["dob"] as? String ?? "")
                                self.appPreffrence.setUserID(value:"\(userProfile["id"] as? Int ?? 0)")

                                //this is for hide or unhide setting for paid and unpaid user
                                self.appPreffrence.setIsSubscribedBool(value: userProfile["is_subscribed"] as? Bool ?? false)
                            }
                        }
                    }
                }
            }
        }
    
    // MARK:- Button Action
    
    @IBAction func btnProfileAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMEditProfileVC") as! WWMEditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPremiumAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        if self.appPreference.get21ChallengeName() == "30 Day Challenge" || self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
            self.callHomeVC1()
        }else{
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func btnOurStoryAction(_ sender: Any) {
        WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "OUR_STORY", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_OurStory
        vc.strType = KOURSTORY
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSupportAction(_ sender: Any) {
        WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "CONTACT_US", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSupportVC") as! WWMSupportVC
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    @IBAction func btnFAQAction(_ sender: Any) {
        WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "FAQ", itemName: "")
        self.openWebView(index: 7)
    }
    @IBAction func btnFindCourseAction(_ sender: Any) {
        WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "FIND_A_COURSE", itemName: "")
        self.openWebView(index: 8)
    }
    
    
    @IBAction func btnUpgradeBeejaAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSettingBeejaAction(_ sender: Any) {
        WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "SETTINGS", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSettingsVC") as! WWMSettingsVC
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
            vc.strType = KINSTAGRAM
        case 2:
            vc.strUrl = URL_Facebook
            vc.strType = KFACEBOOK
        case 3:
            vc.strUrl = URL_YouTube
            vc.strType = KYOUTUBE
        case 4:
            vc.strUrl = URL_Twitter
            vc.strType = KTWITTER
        case 5:
            vc.strUrl = URL_LinkedIn
            vc.strType = KLINKEDIN
        case 6:
            vc.strUrl = URL_WebSite
            vc.strType = KBEEJA
        case 7:
            vc.strUrl = URL_FAQ
            vc.strType = KFAQ
        case 8:
            vc.strUrl = URL_FINDCOURSE
            vc.strType = KFINDCOURSE
        case 9:
            vc.strUrl = URL_LEARN
            vc.strType = KLEARN
        case 10:
            vc.strUrl = URL_GUIDED
            vc.strType = KGUIDED
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
