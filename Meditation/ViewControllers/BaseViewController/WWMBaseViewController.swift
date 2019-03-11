//
//  WWMBaseViewController.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMBaseViewController: UIViewController {

    let appPreference = WWMAppPreference()
    var userData = WWMUserData.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUserDataFromPreference()
        
        // Do any additional setup after loading the view.
    }
    
    func setUserDataFromPreference() {
        if self.appPreference.isLogout() {
            userData = WWMUserData.init(json: self.appPreference.getUserData())
        }
    }
    

    func setNavigationBar(isShow:Bool,title:String){
        self.title = title
        self.navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "#292178")
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()

        if isShow {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    func setUpNavigationBarForDashboard(title:String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
        sideMenuBtn.setImage(UIImage.init(named: "sideMenu_Icon"), for: .normal)
        sideMenuBtn.addTarget(self, action: #selector(btnSideMenuAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let leftTitle = UIButton.init()
        if title == "Timer" {
            leftTitle.setTitle("  Enable Flight Mode", for: .normal)
            leftTitle.setTitleColor(UIColor.init(displayP3Red: 0, green: 18, blue: 82, alpha: 0.45), for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax", size: 14)
            leftTitle.setImage(UIImage.init(named: "FlightMode_Icon"), for: .normal)
            leftTitle.addTarget(self, action: #selector(btnFlightModeAction(_:)), for: .touchUpInside)
        }else {
            leftTitle.setTitle(title, for: .normal)
            leftTitle.setTitleColor(UIColor.white, for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
        }
        
        
        
        
        
        let leftBarButtonItem = UIBarButtonItem.init(customView: leftTitle)
        let rightBarButtonItem = UIBarButtonItem.init(customView: sideMenuBtn)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func isValidEmail(strEmail:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: strEmail)
    }
    
    func showPopUp(title:String, message:String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(btnOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Button Action
    
    @IBAction func btnSideMenuAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSideMenuVC") as! WWMSideMenuVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @IBAction func btnFlightModeAction(_ sender: UIButton) {
        let settingsUrl = URL.init(string: UIApplication.openSettingsURLString)
        //App-prefs:root=AIRPLANE_MODE
        let url1 = URL.init(string: "App-prefs:root=AIRPLANE_MODE")
        if let url = url1 {
            if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (Bool) in
                print("Sucess")
            }
            }else {
                if let setUrl = settingsUrl {
                    UIApplication.shared.open(setUrl, options: [:]) { (Bool) in
                        print("Sucess")
                    }
                }
                
            }
        }else {
            if let setUrl = settingsUrl {
                UIApplication.shared.open(setUrl, options: [:]) { (Bool) in
                    print("Sucess")
                }
            }
            
        }
    }
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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

