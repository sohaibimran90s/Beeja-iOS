//
//  WWMSignupNameVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Lottie

class WWMSignupNameVC: WWMBaseViewController,UITextFieldDelegate{

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var imgViewLogo: UIImageView!
    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var viewLottieAnimation: UIView!
    var tap = UITapGestureRecognizer()
    
    var animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgViewLogo.isHidden = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = KNEXT
        self.setupView()
    }

    func setupView(){
        self.setNavigationBar(isShow: false, title: "")
        self.btnNext.layer.borderWidth = 2.0
        self.btnNext.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        animationView = AnimationView(name: "register")
        animationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        viewLottieAnimation.addSubview(animationView)
        view.addSubview(viewLottieAnimation)
        
        
        animationView.play()
    }
    
    @objc func KeyPadTap() -> Void {
        self.view.endEditing(true)
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
        if txtViewName.text! == ""{
            self.viewName.layer.borderColor = UIColor.clear.cgColor
            self.btnNext.setTitleColor(UIColor.white, for: .normal)
            self.btnNext.backgroundColor = UIColor.clear
        }
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_NAME", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        if self.txtViewName.text == "" {
            vc.name = "You"
        }else {
            vc.name = self.txtViewName.text!
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = txtViewName.text! + string
        if string == "" {
            return true
        }
        let strRegEx = "[A-Z a-z]"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", strRegEx)
        if !emailTest.evaluate(with: string) {
            return false
        }
        if  textField == txtViewName {
            
            let str = txtViewName.text! + string
            if string == "" {
                return true
            }
            let strRegEx = "[A-Z a-z]"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", strRegEx)
            if !emailTest.evaluate(with: string) {
                return false
            }
            
            if str.count > 0 {
                self.viewName.layer.borderWidth = 1.0
                self.viewName.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                self.btnNext.setTitleColor(UIColor.black, for: .normal)
                self.btnNext.backgroundColor = UIColor.init(hexString: "#00eba9")!
            }
            if str.count > 50 {
                return false
            }
        }
        return true
    }
    
    
    // MARK: - UIButton Action
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_UP", itemId: "WHATS_YOUR_NAME", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        if self.txtViewName.text == "" {
            vc.name = "You"
        }else {
            vc.name = self.txtViewName.text!
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
