//
//  WWMGuidedNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedNavVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    
    var arrGuidedList = [WWMGuidedData]()
    var type = "practical"
    var typeTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if type == "practical" {
            self.typeTitle = "Practical Guidance"
            self.setUpNavigationBarForDashboard(title: "Practical Guidance")
        }else {
            self.typeTitle = "Spiritual Guidance"
            self.setUpNavigationBarForDashboard(title: "Spiritual Guidance")
        }
        
        self.getGuidedListAPI()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK : API Calling
    
    func getGuidedListAPI() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        
        let param = ["guided_type":"practical"]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    if let wisdomList = result["result"] as? [[String:Any]] {
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
                    WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
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
