//
//  WWMWisdomNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWisdomNavVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    
    var arrWisdomList = [WWMWisdomData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Wisdom")
        self.getWisdomAPI()
    }
    
    // MARK : API Calling
    
    func getWisdomAPI() {
        self.view.endEditing(true)
        if arrWisdomList.count == 0 {
            //WWMHelperClass.showSVHud()
            WWMHelperClass.showLoaderAnimate(on: self.view)
        }
        
        let param = ["user_id":self.appPreference.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETWISDOM, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    if let wisdomList = result["result"] as? [[String:Any]] {
                        self.arrWisdomList.removeAll()
                        for data in wisdomList {
                            let wisdomData = WWMWisdomData.init(json: data)
                            self.arrWisdomList.append(wisdomData)
                        }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomDashboardVC") as! WWMWisdomDashboardVC
                        vc.arrWisdomList = self.arrWisdomList
                        self.addChild(vc)
                        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                        self.containerView.addSubview((vc.view)!)
                        vc.didMove(toParent: self)
                    }
                    
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
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
