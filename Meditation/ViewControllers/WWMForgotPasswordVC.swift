//
//  WWMForgotPasswordVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMForgotPasswordVC: WWMBaseViewController,UITextFieldDelegate {

    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnEmailMagicLink: UIButton!
    
    @IBOutlet weak var viewEmail: UIView!
    var tap = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnEmailMagicLink.layer.borderWidth = 2.0
        self.btnEmailMagicLink.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }

    
    
    @objc func KeyPadTap() -> Void {
        self.view .endEditing(true)
    }
    
    //MARK:- UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tap = UITapGestureRecognizer(target: self, action: #selector(self.KeyPadTap))
        view.addGestureRecognizer(tap)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view .removeGestureRecognizer(tap)
        if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            self.viewEmail.layer.borderColor = UIColor.clear.cgColor
            self.btnEmailMagicLink.setTitleColor(UIColor.white, for: .normal)
            self.btnEmailMagicLink.backgroundColor = UIColor.clear
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = txtViewEmail.text! + string
        
        if (self.isValidEmail(strEmail: str)) {
            self.viewEmail.layer.borderWidth = 1.0
            self.viewEmail.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            self.btnEmailMagicLink.setTitleColor(UIColor.black, for: .normal)
            self.btnEmailMagicLink.backgroundColor = UIColor.init(hexString: "#00eba9")!
        }
        
        return true
        
    }
    
    // MARK: Button Action
    
    @IBAction func btnEmailMagicLinkAction(_ sender: UIButton) {
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: "Oops, don't forget to enter your email", title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else {
           self.forgotPasswordAPI()
        }
    }
    
    
    func forgotPasswordAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "email": txtViewEmail.text!
        ]
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_FORGOTPASSWORD, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                print(result)
                self.navigationController?.popViewController(animated: true)
                WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as! String, title: kAlertTitle)
                
                //"Success Message: We've sent you a magic link to reset your password. Please check your inbox.
               // Error Message: Oops, this email isn't registered with the Beeja App / Oops, looks like this email has been registered using Facebook or Google. Try logging in again via one of them."""
                
            }else {
                if error?.localizedDescription == "The Internet connection appears to be offline."{
                    WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                }else{
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
