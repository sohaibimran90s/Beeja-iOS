//
//  WWMResetPasswordVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMResetPasswordVC: WWMBaseViewController {

    @IBOutlet weak var txtViewOldPassword: UITextField!
    @IBOutlet weak var txtViewNewPassword: UITextField!
    @IBOutlet weak var txtViewConfirmPassword: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        self.setNavigationBar(isShow: false, title: "Reset Password")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    // MARK: Button Action
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if txtViewOldPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_OldPasswordMessage, title: kAlertTitle)
        }else if txtViewNewPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_NewPasswordMessage, title: kAlertTitle)
        }else if txtViewNewPassword.text == txtViewOldPassword.text {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_OldNewSamePassword, title: kAlertTitle)
        }else if txtViewConfirmPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_ConfirmPasswordMessage, title: kAlertTitle)
        }else if txtViewNewPassword.text != txtViewConfirmPassword.text {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_PasswordMatchMessage, title: kAlertTitle)
        }else {
            self.resetPassword()
        }
    }

    func resetPassword() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_id" : self.appPreference.getUserID(),
            "oldPassword" : txtViewOldPassword.text ?? "",
            "newPassword" : txtViewNewPassword.text ?? ""
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_RESETPASSWORD, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.navigationController?.popViewController(animated: true)
                WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
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
}
