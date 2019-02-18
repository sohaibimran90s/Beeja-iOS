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
        }else if txtViewConfirmPassword.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_ConfirmPasswordMessage, title: kAlertTitle)
        }else if txtViewNewPassword.text != txtViewConfirmPassword.text {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_PasswordMatchMessage, title: kAlertTitle)
        }else {
            self.resetPassword()
        }
    }

    func resetPassword() {
        let param = [
            "user_id" : 1,
            "oldPassword" : txtViewOldPassword.text ?? "",
            "newPassword" : txtViewNewPassword.text ?? ""
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_RESETPASSWORD, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.navigationController?.popViewController(animated: true)
                WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message:error?.localizedDescription ?? "" , title: kAlertTitle)
                }
            }
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
