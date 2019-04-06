//
//  WWMSupportVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSupportVC: WWMBaseViewController {

    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var txtViewQuery: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.txtViewName.text = self.userData.name
        self.txtViewEmail.text = self.userData.email
    }
    // MARK: Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewQuery.isEditable = true
        self.txtViewQuery.becomeFirstResponder()
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if  txtViewName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_NameMessage, title: kAlertTitle)
        }else if  txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailMessage, title: kAlertTitle)
        }else if  txtViewQuery.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_QueryMessage, title: kAlertTitle)
        }else {
            self.submitQueryAPI()
        }
    }

    
    func submitQueryAPI() {
        WWMHelperClass.showSVHud()
        let param = [
                      "user_id" : self.appPreference.getUserID(),
                      "name" : txtViewName.text!,
                      "email" : txtViewEmail.text!,
                      "queryText" : txtViewQuery.text!
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_SUPPORT, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //self.navigationController?.popViewController(animated: true)
                //WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
                
                self.xibCall()
            }else {
                self.saveToDB(param: param)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = "Thank You!"
        alertPopupView.lblSubtitle.text = "Your query has been submitted. Our team will contact you soon."
        alertPopupView.btnClose.isHidden = true
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    
    func saveToDB(param:[String:Any]) {
        let dbContact = WWMHelperClass.fetchEntity(dbName: "DBContactUs") as! DBContactUs
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        dbContact.data = myString
        WWMHelperClass.saveDb()
        self.xibCall()
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.alertPopupView.removeFromSuperview()
    }

}
