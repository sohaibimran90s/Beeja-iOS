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
    
    var arrGuidedList = [WWMGuidedData]()
    var type = "practical"
    var typeTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.appPreference.getGuideType() == "practical"{
            self.typeTitle = "Practical Guidance"
            self.setUpNavigationBarForDashboard(title: "Practical Guidance")
            self.type = "practical"
        }else {
            self.typeTitle = "Spiritual Guidance"
            self.setUpNavigationBarForDashboard(title: "Spiritual Guidance")
            self.type = "spiritual"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getGuidedListAPI()
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
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
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        
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
            WWMHelperClass.dismissSVHud()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
