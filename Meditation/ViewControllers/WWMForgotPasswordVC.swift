//
//  WWMForgotPasswordVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMForgotPasswordVC: WWMBaseViewController {

    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var btnEmailMagicLink: UIButton!
    
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

    
    // MARK: Button Action
    
    @IBAction func btnEmailMagicLinkAction(_ sender: UIButton) {
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailMessage, title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else {
           self.forgotPasswordAPI()
        }
    }
    
    
    func forgotPasswordAPI() {
        let param = [
            "email": "naushad.ali@iris-worldwide.com"
        ]
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_FORGOTPASSWORD, headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                print(result)
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                
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
