//
//  WWMSupportVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSupportVC: WWMBaseViewController {

    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var txtViewQuery: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.txtViewName.text = self.userData.name
        self.txtViewEmail.text = self.userData.email
    }
    // MARK: Button Action
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if  txtViewName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_NameMessage, title: kAlertTitle)
        }else if  txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailMessage, title: kAlertTitle)
        }else if  txtViewQuery.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_QueryMessage, title: kAlertTitle)
        }else {
            self.submitQueryAPI()
        }
    }

    
    func submitQueryAPI() {
        WWMHelperClass.showSVHud()
        let param = [
                      "user_id" : self.appPreference.getUserID(),
                      "name" : txtViewName.text!,
                      "email" : txtViewEmail.text!,
                      "queryText" : txtViewQuery.text!
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_SUPPORT, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.navigationController?.popViewController(animated: true)
                WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message:error?.localizedDescription ?? "" , title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
        
    }

}
