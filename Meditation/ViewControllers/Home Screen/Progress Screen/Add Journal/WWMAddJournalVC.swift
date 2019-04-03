//
//  WWMAddJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMAddJournalVC: WWMBaseViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var txtViewJournal: UITextView!
    @IBOutlet weak var lblTextCount: UILabel!
    
   //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }

    func setupView(){
        self.txtViewJournal.delegate = self
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSubmitJournalAction(_ sender: Any) {
        if txtViewJournal.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter your journal.", title: kAlertTitle)
        }else {
            self.addJournalAPI()
        }
    }
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewJournal.isEditable = true
        self.txtViewJournal.becomeFirstResponder()
    }
    
    func addJournalAPI() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        let param = [
            "mood_color":"",
            "mood_text":"",
            "tell_us_why":txtViewJournal.text!,
            "user_id":"11",
            "date_time":"\(Int(Date().timeIntervalSince1970))",
            "mood_id":""
            ]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.dismiss(animated: true, completion: nil)
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }

    func showPopUpOnPresentView(title: String, message: String) {
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = title
        alertPopupView.lblSubtitle.text = message
        alertPopupView.btnClose.isHidden = true
        
        window.rootViewController?.view.addSubview(alertPopupView)
        
        
        
//        let alert = UIAlertController(title: title as String,
//                                      message: message as String,
//                                      preferredStyle: UIAlertController.Style.alert)
//
//
//        let OKAction = UIAlertAction(title: "OK",
//                                     style: .default, handler: nil)
//
//        alert.addAction(OKAction)
//        self.presentedViewController?.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension WWMAddJournalVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.lblTextCount.text = "\(self.txtViewJournal.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewJournal.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1500
    }
}

