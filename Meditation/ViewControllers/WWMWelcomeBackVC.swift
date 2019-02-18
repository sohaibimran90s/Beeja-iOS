//
//  WWMWelcomeBackVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWelcomeBackVC: WWMBaseViewController {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserLoginType: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var btnUseAnother: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBar(isShow: false, title: "")
    }
    func setupView(){
        self.btnUseAnother.layer.borderWidth = 2.0
        self.btnUseAnother.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }

    
    // MARK: Button Action
    
    @IBAction func btnContinueAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
        vc.isFromWelcomeBack = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @IBAction func btnAnotherAccountAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
        vc.isFromWelcomeBack = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnPrivacyPolicyAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_PrivacyPolicy
        vc.strType = "Privacy Policy"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTermsOfUseAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_TermsnCondition
        vc.strType = "Terms & Conditions"
        self.navigationController?.pushViewController(vc, animated: true)
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
