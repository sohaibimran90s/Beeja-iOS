//
//  WWMMoodJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodJournalVC: WWMBaseViewController {

    @IBOutlet weak var txtViewLog: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lblTextCount: UILabel!
    
    
    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var meditationID = ""
    var levelID = ""
    var moodData = WWMMoodMeterData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        
        self.txtViewLog.delegate = self
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.txtViewLog.layer.borderColor = UIColor.lightGray.cgColor
        self.txtViewLog.layer.borderWidth = 1.0
        self.txtViewLog.layer.cornerRadius = 2.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewLog.isEditable = true
        self.txtViewLog.becomeFirstResponder()
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        self.txtViewLog.text = ""
        self.completeMeditationAPI()
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
        }else {
            self.completeMeditationAPI()
        }
    }

    
    func completeMeditationAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_id":self.appPreference.getUserID(),
            "meditation_type":type,
            "date_time":"\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why":txtViewLog.text,
            "prep_time":prepTime,
            "meditation_time":meditationTime,
            "rest_time":restTime,
            "meditation_id": self.meditationID,
            "level_id":self.levelID,
            "mood_id":self.moodData.id == -1 ? "" : self.moodData.id,
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.logExperience()
                }else {
                    self.saveToDB(param: param)
                }
                
            }else {
                self.saveToDB(param: param)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        self.logExperience()
    }
    
    func logExperience() {
        
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 3
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 3 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
        
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

extension WWMMoodJournalVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.lblTextCount.text = "\(self.txtViewLog.text.count)/1500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtViewLog.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1500
    }
}

