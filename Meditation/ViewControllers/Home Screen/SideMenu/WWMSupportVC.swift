//
//  WWMSupportVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class WWMSupportVC: WWMBaseViewController {

    @IBOutlet weak var txtViewName: UITextField!
    @IBOutlet weak var txtViewEmail: UITextField!
    @IBOutlet weak var txtViewQuery: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.txtViewQuery.delegate = self
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if self.userData.name == "You"{
            self.txtViewName.text = ""
        }else{
            self.txtViewName.text = self.userData.name
        }
        
        self.txtViewEmail.text = self.userData.email
    }
    // MARK: Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewQuery.isEditable = true
        self.txtViewQuery.becomeFirstResponder()
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        
        if txtViewName.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailName, title: kAlertTitle)
        }else if txtViewName.text == "You" || txtViewName.text == "you"{
            WWMHelperClass.showPopupAlertController(sender: self, message: KVALIDATIONNAME, title: kAlertTitle)
        }else if txtViewEmail.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_EmailName, title: kAlertTitle)
        }else if !(self.isValidEmail(strEmail: txtViewEmail.text!)){
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_invalidEmailMessage, title: kAlertTitle)
        }else if txtViewQuery.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_QueryMessage, title: kAlertTitle)
        }else{
            self.submitQueryAPI()
        }
    }
    
    func submitQueryAPI() {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
                      "user_id" : self.appPreference.getUserID(),
                      "name" : txtViewName.text!,
                      "email" : txtViewEmail.text!,
                      "body" : txtViewQuery.text!
            ] as [String : Any]
        
        print("contact param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param as [String : Any], urlString: URL_SUPPORT, context: "WWMSupportVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //self.navigationController?.popViewController(animated: true)
                //WWMHelperClass.showPopupAlertController(sender: self, message:result["message"] as! String , title: kAlertTitle)
                
                self.xibCall()
            }else {
                self.saveToDB(param: param)
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = ""
        alertPopupView.lblSubtitle.text = KSUPPORTMSG
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

extension WWMSupportVC: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewQuery.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1501
    }
}
