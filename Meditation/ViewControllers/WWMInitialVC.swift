//
//  WWMInitialVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 03/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMInitialVC: WWMBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUIsetUp()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBar(isShow: false, title:"")
    }
    
    func initialUIsetUp() {
       
    }
    
    // MARK: Button Action
    
    @IBAction func btnPrivacyPolicyAction(_ sender: Any) {
    }
    @IBAction func btnTermsOfUseAction(_ sender: Any) {
    }
    @IBAction func btnLoginAction(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnStartBe(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
