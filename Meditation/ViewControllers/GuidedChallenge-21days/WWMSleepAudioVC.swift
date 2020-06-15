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
        
        let guidedAudioDataDB = WWMHelperClass.fetchGuidedAudioFilterDB(emotion_id: "\(emotionData.emotion_Id)", dbName: "DBGuidedAudioData")
        if guidedAudioDataDB.count > 0{
            //print("guidedAudioDataDB count... \(guidedAudioDataDB.count)")
            
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
                
                
                var isSaveAudioData = 0
                if self.arrAudioList.count > 0{
                    for i in 0..<self.arrAudioList.count{
                        let id = self.arrAudioList[i].audio_Id
                        //print("audion_id \((dict as AnyObject).audio_id) id \(id)")
                        if Int((dict as AnyObject).audio_id ?? "0") == id{
                            isSaveAudioData = 1
                        }
                    }
                }
                
                if isSaveAudioData == 0{
                    let audioData = WWMGuidedAudioData.init(json: jsonString)
                    self.arrAudioList.append(audioData)
                }
            }
            
            self.tableView.reloadData()
        }
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
        
        if self.appPreffrence.getExpiryDate(){
            cell.imgLock.isHidden = true
        }else{
            if data.audio_Duration > 900{
                cell.imgLock.isHidden = false
            }else{
                cell.imgLock.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
            
            if self.appPreference.getGuidedSleep() == "Guided" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
                
                let data = self.arrAudioList[indexPath.row]
                vc.audioData = data
                vc.cat_id = "\(self.cat_Id)"
                vc.cat_Name = self.cat_Name
                vc.emotion_Id = "\(self.emotionData.emotion_Id)"
                vc.emotion_Name = self.emotionData.emotion_Name
                vc.min_limit = self.min_limit
                vc.max_limit = self.max_limit
                vc.meditation_key = self.meditation_key
                
                if self.appPreffrence.getExpiryDate(){
                    vc.seconds = data.audio_Duration
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    if data.audio_Duration > 900{
                        xibCall()
                    }else{
                        vc.seconds = 900
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepTimerVC") as! WWMSleepTimerVC
                
                let data = self.arrAudioList[indexPath.row]
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
                            
                if self.appPreffrence.getExpiryDate(){
                    vc.seconds = data.audio_Duration
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    if data.audio_Duration > 900{
                        xibCall()
                    }else{
                        vc.seconds = 900
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


extension WWMSleepAudioVC: SKProductsRequestDelegate,SKPaymentTransactionObserver{
    
    func xibCall(){
        alertUpgradePopupView = UINib(nibName: "WWMGuidedUpgradeBeejaPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMGuidedUpgradeBeejaPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertUpgradePopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.boolGetIndex = true
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)
        
        self.getSubscriptionPlanId()
        
        alertUpgradePopupView.viewAnnually.isHidden = false
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = true
        
        alertUpgradePopupView.viewMonthly.layer.borderWidth = 2.0
        alertUpgradePopupView.viewLifeTime.layer.borderWidth = 2.0
        alertUpgradePopupView.viewAnnually.layer.borderWidth = 2.0
        
        alertUpgradePopupView.viewMonthly.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertUpgradePopupView.viewLifeTime.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertUpgradePopupView.viewAnnually.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertUpgradePopupView.btnAnnually.addTarget(self, action: #selector(btnAnnuallyAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnMontly.addTarget(self, action: #selector(btnMontlyAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnLifeTime.addTarget(self, action: #selector(btnLifeTimeAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnRestore.addTarget(self, action: #selector(btnRestoreAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnContinue.addTarget(self, action: #selector(btnContinueAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertUpgradePopupView)
    }
    
    @objc func btnAnnuallyAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 1
        self.subscriptionPlan = "annual"
        self.subscriptionAmount = "41.99"
        alertUpgradePopupView.lblBilledText.text = KBILLEDTEXT
        alertUpgradePopupView.viewAnnually.isHidden = false
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_42_gbp_annual_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_42_gbp_annual_sub... \(self.selectedProductIndex)")
            }
            print(product.productIdentifier)
        }
    }
    
    @objc func btnMontlyAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 0
        self.subscriptionPlan = "Monthly"
        self.subscriptionAmount = "5.99"
        alertUpgradePopupView.lblBilledText.text = ""
        alertUpgradePopupView.viewAnnually.isHidden = true
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = false
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_6_gbp_monthly_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_6_gbp_monthly_sub... \(self.selectedProductIndex)")
            }
            print(product.productIdentifier)
        }
    }
    
    @objc func btnLifeTimeAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 3
        self.subscriptionPlan = "Lifetime"
        self.subscriptionAmount = "239.99"
        alertUpgradePopupView.lblBilledText.text = ""
        alertUpgradePopupView.viewAnnually.isHidden = true
        alertUpgradePopupView.viewLifeTime.isHidden = false
        alertUpgradePopupView.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_240_gbp_lifetime_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_240_gbp_lifetime_sub... \(self.selectedProductIndex)")
            }
            print(product.productIdentifier)
        }
    }
    
    @objc func btnRestoreAction(_ sender: Any){
        self.continueRestoreValue = "1"
        if (SKPaymentQueue.canMakePayments()){
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    @objc func btnContinueAction(_ sender: Any){
        if self.boolGetIndex{
            if self.selectedProductIndex == 3 {
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "MONTHLY")
            }else if self.selectedProductIndex == 2 {
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "ANNUAL")
            }else if self.selectedProductIndex == 1{
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "LIFETIME")
            }
            
            self.continueRestoreValue = "0"
            if reachable.isConnectedToNetwork() {
                self.showActions()
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
            }
        }
    }
    
    @objc func btnCloseAction(_ sender: Any){
        
    }
    
    // MARK:- Get Product Data from Itunes
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs as [Any])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as Set<NSObject> as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            //print("Cannot perform In App Purchases.")
        }
    }
    
    func showActions() {
        if transactionInProgress {
            return
        }
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = kAlertTitle
        alertPopupView.lblSubtitle.text = KBUYBOOKTITLE
        alertPopupView.btnOK.setTitle(KBUY, for: .normal)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if  self.productsArray.count > 0 {
            
            //print("self.productsArray[self.selectedProductIndex]... \(self.productsArray[self.selectedProductIndex])")
            
            let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] )
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
            //WWMHelperClass.showSVHud()
            WWMHelperClass.showLoaderAnimate(on: self.view)
        }else {
            self.requestProductInfo()
        }
    }
    
    // MARK:- Payment Delegate Methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product )
                print(product.localizedTitle)
                print(product.productIdentifier)
            }
        }
        else {
            //print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
       // WWMHelperClass.dismissSVHud()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased, .restored:
                //print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                print(transaction.transactionIdentifier as Any)
                
                var plan_id: Int = 2
                var subscriptionPlan: String = "annual"
                
                //print("responseArray.count..... \(responseArray.count) \(responseArray)")
                if responseArray.count > buttonIndex{
                    if let dict = self.responseArray[buttonIndex] as? [String: Any]{
                        if let id = dict["id"] as? Int{
                            plan_id = id
                        }
                        if let name = dict["name"] as? String{
                            subscriptionPlan = name
                        }
                    }
                }
                //"plan_id" : transaction.payment.productIdentifier
                //"subscription_plan" : self.subscriptionPlan
                
                
                let param = [
                    "plan_id" : plan_id,
                    "user_id" : self.appPreference.getUserID(),
                    "subscription_plan" : subscriptionPlan,
                    "date_time" : transaction.transactionDate!.timeIntervalSince1970 * 1000,
                    "transaction_id" : transaction.transactionIdentifier! as Any,
                    "amount" : self.subscriptionAmount
                    ] as [String : Any]
                
                //print("param,,,,... \(param)")
                
                if !self.restoreBool{
                    self.subscriptionSucessAPI(param: param)
                }
                
            case SKPaymentTransactionState.failed:
                //print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                //WWMHelperClass.dismissSVHud()
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func getSubscriptionPlanId(){
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETSUBSCRIPTIONPPLANS, context: "WWMUpgradeBeejaVC", headerType: kGETHeader, isUserToken: false) { (response, error, sucess) in
            if sucess {
                if let result = response["result"] as? [[String: Any]]{
                    self.responseArray = result
                   //print("result.... \(result)")
                }
            }else {
                
                //The Internet connection appears to be offline.
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func subscriptionSucessAPI(param : [String : Any]) {
        
        //print("param.....###### \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SUBSCRIPTIONPURCHASE, context: "WWMUpgradeBeejaVC", headerType: kPOSTHeader, isUserToken: true) { (response, error, sucess) in
            if sucess {
                if self.continueRestoreValue == "1"{
                    
                    if !self.restoreBool{
                        KUSERDEFAULTS.set("1", forKey: "restore")
                        self.restoreBool = true
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        
                        return
                    }
                }else{
                    
                    if !self.restoreBool{
                        KUSERDEFAULTS.set("0", forKey: "restore")
                        self.restoreBool = true
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        
                        return
                    }
                }
            }else {
                
                //The Internet connection appears to be offline.
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                        return
                    }else{
                        
                        if self.continueRestoreValue == "1"{
                            WWMHelperClass.showPopupAlertController(sender: self, message: KRESTOREPROBTITLE, title: KRESTOREPROBSUBTITLE)
                        }else{
                            WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                        }
                        
                        return
                    }
                }
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}
