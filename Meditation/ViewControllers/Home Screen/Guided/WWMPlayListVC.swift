//
//  WWMPlayListVC.swift
//  Meditation
//
//  Created by Prema Negi on 19/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMPlayListVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLearn: UIButton!
    @IBOutlet weak var btnGuided: UIButton!

    var itemInfo: IndicatorInfo = "View"
    var type = ""
    var subType = ""
    var guidedData = WWMGuidedData()
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    var guided_type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnLearn.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnLearn.layer.borderWidth = 1.0
        self.btnLearn.layer.cornerRadius = 20
        
        self.btnGuided.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnGuided.layer.borderWidth = 1.0
        self.btnGuided.layer.cornerRadius = 20
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @IBAction func btnLearnClicked(_ sender: UIButton){
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PLAYLIST_PAGE", itemId: "LIKE_TO_LEARN", itemName: "")
        guided_type = ""
        WWMHelperClass.selectedType = "learn"
        self.meditationApi(type: "learn")
    }
    
    @IBAction func btnGuidedClicked(_ sender: UIButton){
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PLAYLIST_PAGE", itemId: "GUIDE_ME", itemName: "")

        guided_type = ""
        WWMHelperClass.selectedType = "guided"
        self.meditationApi(type: "guided")
    }
    
    // Calling API
    func meditationApi(type: String) {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : 1,
            "level_id"      : 1,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : type,
            "guided_type"   : guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMSignupLetsStartVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                print("result signupletsstartvc meditation data... \(result)")
                
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                    }
                }
                
                self.appPreference.setIsProfileCompleted(value: true)
                self.appPreference.setType(value: type)
                self.appPreference.setGuideType(value: self.guided_type)
                self.appPreference.setGuideTypeFor3DTouch(value: self.guided_type)
                
                self.appPreference.setGetProfile(value: true)
                
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

extension WWMPlayListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMSleepTVC") as! WWMSleepTVC
        
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.emotion_Name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepAudioVC") as! WWMSleepAudioVC
            
            vc.vcType = "WWMPlayListVC"
            vc.emotionData = data
            vc.subTitle = self.subType
            vc.cat_Id = "\(self.guidedData.cat_Id)"
            vc.cat_Name = self.guidedData.cat_Name
            vc.type = data.emotion_Name
            vc.imgURL = data.emotion_Image
            vc.min_limit = self.min_limit
            vc.max_limit = self.max_limit
            vc.meditation_key = self.meditation_key
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
