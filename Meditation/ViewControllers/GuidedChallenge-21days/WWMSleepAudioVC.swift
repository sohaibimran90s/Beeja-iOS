//
//  WWMSleepAudioVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import CoreData

class WWMSleepAudioVC: WWMBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    //variables
    var emotionData = WWMGuidedEmotionData()
    var cat_Id = "0"
    var cat_Name = ""
    var type = ""
    var imgURL = ""
    var subTitle = ""
    
    var arrAudioList = [WWMGuidedAudioData]()
    var alertPopupView1 = WWMAlertController()
    let appPreffrence = WWMAppPreference()
    
    let reachable = Reachabilities()
    var alertUpgradePopupView = WWMGuidedUpgradeBeejaPopUp()
    
    //upgrade beeja
    var selectedProductIndex = 2
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    var productIDs = ["get_108_gbp_lifetime_sub","get_42_gbp_annual_sub","get_6_gbp_monthly_sub","get_240_gbp_lifetime_sub"]
    var alertPopup = WWMAlertPopUp()
    var subscriptionAmount: String = "41.99"
    var subscriptionPlan: String = "annual"
    var responseArray: [[String: Any]] = []
    var buttonIndex = 1
    var continueRestoreValue: String = ""
    var boolGetIndex = false
    var restoreBool = false
    
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar(isShow: false, title: "")
        self.lblTitle.text = self.type
        self.lblSubTitle.text = "\(subTitle) audio track"
        
        if self.imgURL != ""{
            self.imgView.sd_setImage(with: URL.init(string: self.imgURL), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        }
        self.fetchGuidedAudioDataFromDB()
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func getFreeMoodMeterAlert(title: String, subTitle: String){
        self.alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        self.alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.alertPopupView1.lblTitle.numberOfLines = 0
        self.alertPopupView1.btnOK.layer.borderWidth = 2.0
        self.alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.alertPopupView1.lblTitle.text = title
        self.alertPopupView1.lblSubtitle.text = subTitle
        self.alertPopupView1.btnClose.isHidden = true
        
        self.alertPopupView1.btnOK.addTarget(self, action: #selector(btnAlertDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @objc func btnAlertDoneAction(_ sender: Any){
        self.alertPopupView1.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) sec"
        }else {
            return String.init(format: "%d:%02d min", second/60,second%60)
        }
    }
    
    //MARK: Fetch Guided Audio Data From DB
    
    func fetchGuidedAudioDataFromDB() {
        
        let guidedAudioDataDB = self.fetchGuidedAudioFilterDB(emotion_id: "\(emotionData.emotion_Id)", dbName: "DBGuidedAudioData")
        if guidedAudioDataDB.count > 0{
            print("guidedAudioDataDB count... \(guidedAudioDataDB.count)")
            
            self.arrAudioList.removeAll()
            
            var jsonString: [String: Any] = [:]
            for dict in guidedAudioDataDB {
                
                jsonString["id"] = Int((dict as AnyObject).audio_id ?? "0")
                jsonString["duration"] = Int((dict as AnyObject).duration ?? "0")
                jsonString["audio_name"] = (dict as AnyObject).audio_name as? String
                jsonString["audio_image"] = (dict as AnyObject).audio_image as? String
                jsonString["audio_url"] = (dict as AnyObject).audio_url as? String
                jsonString["author_name"] = (dict as AnyObject).author_name as? String
                jsonString["vote"] = (dict as AnyObject).vote
                jsonString["paid"] = (dict as AnyObject).paid
                
                let audioData = WWMGuidedAudioData.init(json: jsonString)
                self.arrAudioList.append(audioData)
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    func fetchGuidedAudioFilterDB(emotion_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "emotion_id == %@", emotion_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!
        
    }
    
}

extension WWMSleepAudioVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tableViewHeightConstraint.constant = CGFloat(50 * (self.arrAudioList.count))
        return self.arrAudioList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMSleepAudioTVC") as! WWMSleepAudioTVC
        
        cell.viewBack.layer.cornerRadius = 20
        cell.viewBack.layer.borderWidth = 1.0
        cell.viewBack.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        let data = self.arrAudioList[indexPath.row]
        cell.lblDuration.text = "\(self.secondsToMinutesSeconds(second: data.audio_Duration))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
            let data = self.arrAudioList[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepTimerVC") as! WWMSleepTimerVC
            
            vc.audioData = self.arrAudioList[indexPath.row]
            vc.cat_id = self.cat_Id
            vc.cat_Name = self.cat_Name
            vc.emotion_Id = "\(self.emotionData.emotion_Id)"
            vc.emotion_Name = self.emotionData.emotion_Name
            vc.category = self.type
            vc.subCategory = "\(subTitle) audio track"
            vc.min_limit = self.min_limit
            vc.max_limit = self.max_limit
            vc.meditation_key = self.meditation_key
            
            vc.seconds = data.audio_Duration
            self.navigationController?.pushViewController(vc, animated: true)
            
//            if self.appPreffrence.getExpiryDate(){
//                vc.seconds = data.audio_Duration
//                self.navigationController?.pushViewController(vc, animated: true)
//            }else{
//                if data.audio_Duration > 900{
//                    xibCall()
//                }else{
//                    vc.seconds = 900
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
            
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
