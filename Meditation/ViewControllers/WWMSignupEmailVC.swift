//
//  WWMSignupEmailVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSignupEmailVC: WWMBaseViewController {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtViewEmail: UITextField!
    var name = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        self.btnNext.layer.borderWidth = 2.0
        self.btnNext.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    // MARK: - UIButton Action
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message:Validation_EmailMessage , title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else {
            self.appPreference.setIsLogin(value: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }


    func signUpApi() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMOODMETERDATA, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
        }

    }
}
