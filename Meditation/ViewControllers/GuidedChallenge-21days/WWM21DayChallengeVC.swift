//
//  WWM21DayChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreData
import StoreKit

class WWM21DayChallengeVC: WWMBaseViewController,IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var introBtn: UIButton!
    
    var selectedIndex = 0
    var itemInfo: IndicatorInfo = "View"
    var guidedData = WWMGuidedData()
    var type = ""
    var cat_name: String = ""
    var cat_id: Int = 0
    
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
    
    var alertPopupView1 = WWMAlertController()
    let reachable = Reachabilities()
    var alertUpgradePopupView = WWMGuidedUpgradeBeejaPopUp()
    //var alertPopup = WWMAlertPopUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func introBtnAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminderVC") as! WWM21DaySetReminderVC

        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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

extension WWM21DayChallengeVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWM21DayChallengeTVC") as! WWM21DayChallengeTVC
        
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
        if indexPath.row == 0{
            cell.upperLineLbl.isHidden = true
        }else{
            cell.upperLineLbl.isHidden = false
        }
        
        cell.stepLbl.layer.cornerRadius = 12
        cell.daysLbl.text = "Day \(indexPath.row + 1)"
        cell.stepLbl.text = "\(indexPath.row + 1)"
        cell.titleLbl.text = data.emotion_Name
        cell.authorLbl.text = "Guided by \(data.author_name)"

        if selectedIndex == indexPath.row{
            cell.descLbl.isHidden = false
            
            cell.backImg1.backgroundColor = UIColor(red: 14.0/255.0, green: 31.0/255.0, blue: 104.0/255.0, alpha: 0.7)
            cell.backImg2.isHidden = false
            cell.backImg1.isHidden = true
            cell.arrowImg.image = UIImage(named: "upArrow")
            cell.collectionView.isHidden = false
        }else{
            cell.descLbl.isHidden = true
            cell.backImg1.isHidden = false
            cell.backImg2.isHidden = true
            cell.arrowImg.image = UIImage(named: "downArrow")
            cell.collectionView.isHidden = true
            
        }
        
        cell.collectionView.tag = indexPath.row
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        self.tableView.reloadData()
    }
}

extension WWM21DayChallengeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList[collectionView.tag].audio_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WWM21DayChallengeCVC", for: indexPath) as! WWM21DayChallengeCVC
        
        let data = self.guidedData.cat_EmotionList[collectionView.tag]
        
        DispatchQueue.main.async {
            cell.backImg.sd_setImage(with: URL.init(string: "\(data.audio_list[indexPath.item].audio_Image)"), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            cell.lblAudioTime.text = "\(self.secondToMinuteSecond(second: data.audio_list[indexPath.item].audio_Duration))"
            
            if self.appPreference.getIsSubscribedBool(){
                cell.lockImg.image = UIImage(named: "")
                cell.lockImg.isHidden = true
            }else{
                print("data.audio_list[indexPath.item].audio_Duration... \(data.audio_list[indexPath.item].audio_Duration)")
                if data.audio_list[indexPath.item].audio_Duration <= 900{
                    cell.lockImg.image = UIImage(named: "")
                    cell.lockImg.isHidden = true
                }else{
                    cell.lockImg.image = UIImage(named: "lock1")
                    cell.lockImg.isHidden = false
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        let data = self.guidedData.cat_EmotionList[collectionView.tag]
        
        if self.appPreference.getIsSubscribedBool(){
            
            self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
//            vc.audioData = data.audio_list[indexPath.item]
//            vc.cat_id = "\(self.cat_id)"
//            vc.cat_Name = self.cat_name
//            vc.emotion_Id = "\(data.emotion_Id)"
//            vc.emotion_Name = data.emotion_Name
//            vc.seconds = data.audio_list[indexPath.item].audio_Duration
//
//            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if data.audio_list[indexPath.item].audio_Duration <= 900{
                self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
//
//                vc.audioData = data.audio_list[indexPath.item]
//                vc.cat_id = "\(self.cat_id)"
//                vc.cat_Name = self.cat_name
//                vc.emotion_Id = "\(data.emotion_Id)"
//                vc.emotion_Name = data.emotion_Name
//                vc.seconds = data.audio_list[indexPath.item].audio_Duration
//
//                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                xibCall()
            }
        }
    }
    
    func pushViewController(table_cell_tag: Int, collection_cell_tag: Int){
        
        var flag = 0
        var position = 0
        
        let data = self.guidedData.cat_EmotionList[table_cell_tag]
        if data.completed{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
            vc.audioData = data.audio_list[collection_cell_tag]
            vc.cat_id = "\(self.cat_id)"
            vc.cat_Name = self.cat_name
            vc.emotion_Id = "\(data.emotion_Id)"
            vc.emotion_Name = data.emotion_Name
            vc.seconds = data.audio_list[collection_cell_tag].audio_Duration
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            return
        }else{
            for i in 0..<table_cell_tag{
                let date_completed = self.guidedData.cat_EmotionList[i].completed_date
                if date_completed != ""{
                    let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                    if dateCompare.0 == 1{
                        flag = 1
                        break
                    }
                }
            }
        }
        
        if flag == 1{
            self.xibCall1(title1: KLEARNONESTEP)
            return
        }
        
        for i in 0..<table_cell_tag{
            if !self.guidedData.cat_EmotionList[i].completed{
                flag = 2
                position = i
                break
            }
        }
        
        if flag == 2{
            
            print("first play the \(self.guidedData.cat_EmotionList[position].emotion_Name)")
            
            self.xibCall1(title1: "\(KLEARNJUMPSTEP) \(self.guidedData.cat_EmotionList[position].emotion_Name) \(KLEARNJUMPSTEP1)")
        }else{
            WWMHelperClass.selectedType = "guided"
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
            vc.audioData = data.audio_list[collection_cell_tag]
            vc.cat_id = "\(self.cat_id)"
            vc.cat_Name = self.cat_name
            vc.emotion_Id = "\(data.emotion_Id)"
            vc.emotion_Name = data.emotion_Name
            vc.seconds = data.audio_list[collection_cell_tag].audio_Duration
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func xibCall1(title1: String){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertPopup.lblTitle.text = title1
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
            }
        }
    }
}


extension WWM21DayChallengeVC: SKProductsRequestDelegate,SKPaymentTransactionObserver{
    
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
                print("selectedProductIndex get_42_gbp_annual_sub... \(self.selectedProductIndex)")
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
                print("selectedProductIndex get_6_gbp_monthly_sub... \(self.selectedProductIndex)")
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
                print("selectedProductIndex get_240_gbp_lifetime_sub... \(self.selectedProductIndex)")
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
            print("Cannot perform In App Purchases.")
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
            
            print("self.productsArray[self.selectedProductIndex]... \(self.productsArray[self.selectedProductIndex])")
            
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
            print("There are no products.")
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
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                print(transaction.transactionIdentifier as Any)
                
                var plan_id: Int = 2
                var subscriptionPlan: String = "annual"
                
                print("responseArray.count..... \(responseArray.count) \(responseArray)")
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
                
                print("param,,,,... \(param)")
                
                if !self.restoreBool{
                    self.subscriptionSucessAPI(param: param)
                }
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
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
                    print("result.... \(result)")
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
        
        print("param.....###### \(param)")
        
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
