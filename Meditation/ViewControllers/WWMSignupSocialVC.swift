//
//  WWMSignupSocialVC.swift
//  Meditation
//
//  Created by Prashant Tayal on 25/08/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import Lottie

class WWMSignupSocialVC: UIViewController {
    
    @IBOutlet weak var viewStartBeeja: UIView!
    @IBOutlet weak var lblSignup: UILabel!
    @IBOutlet weak var imgSignup: UIImageView!
    @IBOutlet weak var viewLottieAnimation: UIView!
    
    var animationView = AnimationView()
    
    var pushToLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblSignup.textColor = UIColor.white
        self.imgSignup.image = UIImage.init(named: "startBeeja_Icon")
        self.viewStartBeeja.backgroundColor = UIColor.clear
        viewStartBeeja.layer.borderWidth = 2.0
        viewStartBeeja.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @IBAction func clickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickLogin() {
        if pushToLogin {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
                   self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnSignupTouchDown(_ sender: Any) {
        animationView.stop()
        self.viewLottieAnimation.isHidden = true
        self.imgSignup.isHidden = false
        self.viewStartBeeja.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        viewStartBeeja.layer.borderColor = UIColor.clear.cgColor
        self.lblSignup.textColor = UIColor.black
        self.imgSignup.image = UIImage.init(named: "iconToAnimateCopy2")
    }
    
    @IBAction func btnSignupTouchupInside() {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "START_BEEJA", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        WWMHelperClass.loginSignupBool = false
    }
    
    //MARK: Animate View
    @objc func animateView(){
        animationView.stop()
    }
}
