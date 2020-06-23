//
//  WWMUpgradeBeejaVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import StoreKit

class WWMUpgradeBeejaVC: WWMBaseViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    @IBOutlet weak var viewLifeTime: UIView!
    @IBOutlet weak var viewAnnually: UIView!
    @IBOutlet weak var viewMonthly: UIView!
    @IBOutlet weak var lblBilledText: UILabel!

    //aply coupon outlets
    @IBOutlet weak var viewACoupon: UIView!
    @IBOutlet weak var viewRedeemCoupon: UIView!
    @IBOutlet weak var viewACouponHC: NSLayoutConstraint!
    @IBOutlet weak var btnACoupon: UIButton!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    
    var tap = UITapGestureRecognizer()
    var selectedProductIndex = 2
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    var productIDs = ["get_108_gbp_lifetime_sub","get_42_gbp_annual_sub","get_6_gbp_monthly_sub","get_240_gbp_lifetime_sub"]
    
    let reachable = Reachabilities()
    var subscriptionAmount: String = "41.99"
    var subscriptionPlan: String = "annual"
    
    var responseArray: [[String: Any]] = []
    var buttonIndex = 1
    
    //var alertPopupView = WWMAlertController()
    var alertPopup = WWMAlertPopUp()
    var popupTitle: String = ""
    var continueRestoreValue: String = ""
    var boolGetIndex = false
    var restoreBool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tap = UITapGestureRecognizer(target: self, action:  #selector(self.checkTapAction))
        self.view.addGestureRecognizer(self.tap)
        self.boolGetIndex = true
        self.setNavigationBar(isShow: false, title: "")
        self.setupView()
        
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)
        
        self.getSubscriptionPlanId()
    }
    
    func setupView(){
        
        self.viewAnnually.isHidden = false
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = true
        
        self.viewMonthly.layer.borderWidth = 2.0
        self.viewLifeTime.layer.borderWidth = 2.0
        self.viewAnnually.layer.borderWidth = 2.0
        
        self.viewMonthly.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.viewLifeTime.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.viewAnnually.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.viewRedeemCoupon.isHidden = true
        self.viewACoupon.isHidden = false
        
        if WWMHelperClass.hasTopNotch{
            self.viewACouponHC.constant = 66
            self.viewACoupon.layer.cornerRadius = 33
        }else{
            self.viewACoupon.layer.cornerRadius = 28
            self.viewACouponHC.constant = 56
        }
    }
    
    @objc func checkTapAction(sender : UITapGestureRecognizer) {
        self.viewRedeemCoupon.isHidden = true
        self.viewACoupon.isHidden = false
    }
    
    //MARK: Apply Coupon code
    @IBAction func btnACouponAction(_ sender: UIButton){
        self.viewRedeemCoupon.isHidden = false
        self.viewACoupon.isHidden = true
    }
    
    @IBAction func btnRCouponAction(_ sender: UIButton){
        let redeemCode = "\(self.textField1.text ?? "")\(self.textField2.text ?? "")\(self.textField3.text ?? "")\(self.textField4.text ?? "")\(self.textField5.text ?? "")\(self.textField6.text ?? "")"

        if redeemCode.count == 6{
            self.getRedeemCodeAPI(redeemCode: redeemCode)
        }else{
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter correct coupon code", title: "")
        }
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
    
    // MARK:- UIButton Action
    
    
    @IBAction func btnMonthlyAction(sender: AnyObject) {
        self.boolGetIndex = false
        self.buttonIndex = 0
        self.subscriptionPlan = "Monthly"
        self.subscriptionAmount = "5.99"
        self.lblBilledText.text = ""
        self.viewAnnually.isHidden = true
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = false
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_6_gbp_monthly_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_6_gbp_monthly_sub... \(self.selectedProductIndex)")
            }
            //print(product.productIdentifier)
        }
        
    }
    
    @IBAction func btnAnnuallyAction(sender: AnyObject) {
        self.boolGetIndex = false
        self.buttonIndex = 1
        self.subscriptionPlan = "annual"
        self.subscriptionAmount = "41.99"
        self.lblBilledText.text = KBILLEDTEXT
        self.viewAnnually.isHidden = false
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = true
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
    
    @IBAction func btnLifeTimeAction(sender: AnyObject) {
        self.boolGetIndex = false
        self.buttonIndex = 3
        self.subscriptionPlan = "Lifetime"
        self.subscriptionAmount = "239.99"
        self.lblBilledText.text = ""
        self.viewAnnually.isHidden = true
        self.viewLifeTime.isHidden = false
        self.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_240_gbp_lifetime_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_240_gbp_lifetime_sub... \(self.selectedProductIndex)")
            }
            //print(product.productIdentifier)
        }
        
    }
    
    @IBAction func btnContinuePaymentAction(sender: AnyObject) {
        
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
    
    @IBAction func btnRestoreAction(_ sender: UIButton) {
        self.continueRestoreValue = "1"
        if (SKPaymentQueue.canMakePayments()){
            SKPaymentQueue.default().restoreCompletedTransactions()
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
}

extension WWMUpgradeBeejaVC{
    
    func getRedeemCodeAPI(redeemCode: String) {
        
        let param = ["user_id": self.appPreference.getUserID(), "code": redeemCode] as [String : Any]
        print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_REDEEMCOUPONCODE, context: "WWMShareLoveVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                self.callHomeVC(index: 2)
            }else{
                WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: "")
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
