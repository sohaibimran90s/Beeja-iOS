//
//  PaymentVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 12/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import StoreKit

class PaymentVC: WWMBaseViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    

    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var annualView: UIView!
    @IBOutlet weak var lifetimeView: UIView!
    @IBOutlet weak var updateNowBtn: UIButton!

    var productsArray = [SKProduct]()
    let reachable = Reachabilities()
    var alertPopup = WWMAlertPopUp()
    var responseArray: [[String: Any]] = []
    var productIDs = ["get_108_gbp_lifetime_sub","get_42_gbp_annual_sub","get_6_gbp_monthly_sub","get_240_gbp_lifetime_sub"]
    var transactionInProgress = false
    var buttonIndex = 1
    var subscriptionAmount: String = "41.99"
    var restoreBool = false
    var continueRestoreValue: String = ""
    var selectedProductIndex = 2
    var boolGetIndex = false
    let kDataManager = DataManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        view.insetsLayoutMarginsFromSafeArea = false

        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = Constant.Light_Green.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
        self.updateNowBtn.layer.borderColor = Constant.Light_Green.cgColor

        
        self.boolGetIndex = true
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)        
        self.getSubscriptionPlanId()
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        //kDataManager.isPaidAc = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func monthlyAction(sender: UIButton) {
        self.buttonIndex = 0
        self.boolGetIndex = false
        self.monthlyView.layer.borderColor = Constant.Light_Green.cgColor
        self.annualView.layer.borderColor = UIColor.clear.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
        
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

    @IBAction func anualAction(sender: UIButton) {
        self.buttonIndex = 1
        self.boolGetIndex = false
        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = Constant.Light_Green.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
        
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

    @IBAction func lifetimeAction(sender: UIButton) {
        self.buttonIndex = 3
        self.boolGetIndex = false
        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = UIColor.clear.cgColor
        self.lifetimeView.layer.borderColor = Constant.Light_Green.cgColor
        
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

    @IBAction func upgradeNowAction(sender: UIButton) {
        
        if self.boolGetIndex {
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
        //window.rootViewController?.view.addSubview(alertPopupView)
        self.view.addSubview(alertPopupView)
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
                self.appPreference.setExpiryDate(value: true)

                if self.continueRestoreValue == "1"{
                  
                    if !self.restoreBool{
                        
                        KUSERDEFAULTS.set("1", forKey: "restore")
                        self.restoreBool = true
                        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        //UIApplication.shared.keyWindow?.rootViewController = vc
                        self.dismiss(animated: true, completion: nil)
                        
                        return
                    }
                }else{
                                        
                    if !self.restoreBool{
                        
                        KUSERDEFAULTS.set("0", forKey: "restore")
                        self.restoreBool = true
                        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        //UIApplication.shared.keyWindow?.rootViewController = vc
                        self.dismiss(animated: true, completion: nil)
                        
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

    //MARK: In App Purchase Delegate

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
