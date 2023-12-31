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
    var alertPopupView = WWMAlertController()
    var title1: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUserDataFromPreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.setUserDataFromPreference()
    }
    
    func setUserDataFromPreference() {
        if self.appPreference.isLogout() {
            userData = WWMUserData.init(json: self.appPreference.getUserData())
        }
    }
    
    func setNavigationBar(isShow:Bool,title:String){
        self.navigationItem.title = title
        self.navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "#292178")
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white

        if isShow {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    func setUpNavigationBarForDashboard(title:String) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        
        self.title1 = title
        if title == "Settings"{
            sideMenuBtn.setImage(UIImage.init(named: "Close_Icon"), for: .normal)
        }else{
            sideMenuBtn.setImage(UIImage.init(named: "menu_44"), for: .normal)
        }
        
        sideMenuBtn.addTarget(self, action: #selector(btnSideMenuAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let leftTitle = UIButton.init()
        let barButtonPracticalSpiritual = UIButton.init()
        let barButtonPracticalSpiritualImage = UIButton.init()
        
        if title == "Timer" {
            leftTitle.setTitle("  Toggle Flight Mode", for: .normal)
            leftTitle.setTitleColor(UIColor.init(displayP3Red: 0/255, green: 18/255, blue: 82/255, alpha: 0.45), for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax", size: 14)
            leftTitle.setImage(UIImage.init(named: "FlightMode_Icon"), for: .normal)
            leftTitle.addTarget(self, action: #selector(btnFlightModeAction(_:)), for: .touchUpInside)
            
            let leftBarButtonItem = UIBarButtonItem.init(customView: leftTitle)
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }else if title == "Practical Guidance" {

            barButtonPracticalSpiritual.setTitle(title, for: .normal)
            barButtonPracticalSpiritual.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
            
            barButtonPracticalSpiritualImage.setImage(UIImage(named: "dropDown"), for: .normal)
            barButtonPracticalSpiritualImage.contentMode = .scaleAspectFit
            barButtonPracticalSpiritualImage.clipsToBounds = true
            
            let leftBarButtonItem = UIBarButtonItem.init(customView: barButtonPracticalSpiritual)
            let leftBarButtonItem1 = UIBarButtonItem.init(customView: barButtonPracticalSpiritualImage)
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem, leftBarButtonItem1]
            
        }else if title == "Spiritual Guidance" {
            
            barButtonPracticalSpiritual.setTitle(title, for: .normal)
            barButtonPracticalSpiritual.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
            
            
            barButtonPracticalSpiritualImage.setImage(UIImage(named: "dropDown"), for: .normal)
            barButtonPracticalSpiritualImage.contentMode = .scaleAspectFit
            barButtonPracticalSpiritualImage.clipsToBounds = true
            
            
            let leftBarButtonItem = UIBarButtonItem.init(customView: barButtonPracticalSpiritual)
            let leftBarButtonItem1 = UIBarButtonItem.init(customView: barButtonPracticalSpiritualImage)
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem, leftBarButtonItem1]
            
        }else{
            
            leftTitle.setTitle(title, for: .normal)
            leftTitle.setTitleColor(UIColor.white, for: .normal)
            leftTitle.titleLabel?.font = UIFont.init(name: "Maax-Bold", size: 24)
           
            let leftBarButtonItem = UIBarButtonItem.init(customView: leftTitle)
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
        
        
        barButtonPracticalSpiritual.addTarget(self, action: #selector(dropDownClicked), for: .touchUpInside)
        barButtonPracticalSpiritualImage.addTarget(self, action: #selector(dropDownClicked1), for: .touchUpInside)
        
        let rightBarButtonItem = UIBarButtonItem.init(customView: sideMenuBtn)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func dropDownClicked(){
        KNOTIFICATIONCENTER.post(name: Notification.Name("guidedDropDownClicked"), object: nil)
    }
    
    @objc func dropDownClicked1(){
        
         KNOTIFICATIONCENTER.post(name: Notification.Name("guidedDropDownClicked"), object: nil)
    }
    
    func setUpNavigationBarForAudioGuided(title:String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        self.title = title
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        
        let sideMenuBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        sideMenuBtn.setImage(UIImage.init(named: "sideMenu_Icon"), for: .normal)
        sideMenuBtn.addTarget(self, action: #selector(btnSideMenuAction(_:)), for: .touchUpInside)
        sideMenuBtn.contentMode = .scaleAspectFit
        
        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage.init(named: "Back_Arrow_Icon"), for: .normal)
        backButton.addTarget(self, action: #selector(btnBackAction(_:)), for: .touchUpInside)
        backButton.contentMode = .scaleAspectFit
        
        let leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
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

        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = title
        alertPopupView.lblSubtitle.text = message
        alertPopupView.btnClose.isHidden = true
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    // MARK: Button Action
    
    @IBAction func btnSideMenuAction(_ sender: UIButton) {
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count < 1 {
            return
        }
        
        if self.title1 == "Settings"{
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSideMenuVC") as! WWMSideMenuVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func btnFlightModeAction(_ sender: UIButton) {
        xibCall1()
    }
    
    func xibCall1(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.lblTitle.text = "Toggle Airplane mode"
        alertPopupView.lblSubtitle.text = "Go to Settings app main page and toggle the airplane mode."
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction1(_:)), for: .touchUpInside)
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction1(_ sender: Any) {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func secondToMinuteSecond(second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    func convertToDictionary1(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

