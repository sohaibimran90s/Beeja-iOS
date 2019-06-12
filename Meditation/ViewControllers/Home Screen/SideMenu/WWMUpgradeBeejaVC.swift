//
//  WWMUpgradeBeejaVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class WWMUpgradeBeejaVC: WWMBaseViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    @IBOutlet weak var viewLifeTime: UIView!
    @IBOutlet weak var viewAnnually: UIView!
    @IBOutlet weak var viewMonthly: UIView!
    
    @IBOutlet weak var lblBilledText: UILabel!
    var selectedProductIndex = 1
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    var productIDs = ["get_108_gbp_lifetime_sub","get_42_gbp_annual_sub","get_6_gbp_monthly_sub"]
    
    let reachable = Reachabilities()
    var subscriptionAmount: String = "41.99"
    var subscriptionPlan: String = "Annually"
    
    //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

       // WWMHelperClass.showSVHud()
        self.setNavigationBar(isShow: false, title: "")
        self.viewAnnually.isHidden = false
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = true
        
        self.viewMonthly.layer.borderWidth = 2.0
        self.viewLifeTime.layer.borderWidth = 2.0
        self.viewAnnually.layer.borderWidth = 2.0
        
        self.viewMonthly.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.viewLifeTime.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.viewAnnually.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)
        // Do any additional setup after loading the view.
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
        alertPopupView.lblSubtitle.text = "What do you want to do?"
        alertPopupView.btnOK.setTitle("Buy", for: .normal)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
        
        
        
        //let actionSheetController = UIAlertController(title: kAlertTitle, message: "What do you want to do?", preferredStyle: UIAlertController.Style.actionSheet)
        
//        let buyAction = UIAlertAction(title: "Buy", style: UIAlertAction.Style.default) { (action) -> Void in
//            let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] )
//            SKPaymentQueue.default().add(payment)
//            self.transactionInProgress = true
//            WWMHelperClass.showSVHud()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) -> Void in
//
//        }
//
//        actionSheetController.addAction(buyAction)
//        actionSheetController.addAction(cancelAction)
//
//        present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if  self.productsArray.count > 0 {
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
            }
            print(product.productIdentifier)
        }
        
    }
    
    @IBAction func btnAnnuallyAction(sender: AnyObject) {
        self.subscriptionPlan = "Annually"
        self.subscriptionAmount = "41.99"
        self.lblBilledText.text = "*Billed as one payment of £41.99"
        self.viewAnnually.isHidden = false
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_42_gbp_annual_sub" {
                self.selectedProductIndex = index
            }
            print(product.productIdentifier)
        }
    }
    
    @IBAction func btnLifeTimeAction(sender: AnyObject) {
        self.subscriptionPlan = "Lifetime"
        self.subscriptionAmount = "108"
        self.lblBilledText.text = ""
        self.viewAnnually.isHidden = true
        self.viewLifeTime.isHidden = false
        self.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_108_gbp_lifetime_sub" {
                self.selectedProductIndex = index
            }
            print(product.productIdentifier)
        }
        
    }
    
    @IBAction func btnContinuePaymentAction(sender: AnyObject) {
         if reachable.isConnectedToNetwork() {
            self.showActions()
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
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
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                print(transaction.transactionIdentifier as Any)
                let param = [
                    "plan_id" : transaction.payment.productIdentifier,
                    "user_id" : self.appPreference.getUserID(),
                    "subscription_plan" : self.subscriptionPlan,
                    "date_time" : transaction.transactionDate as Any,
                    "transaction_id" : transaction.transactionIdentifier as Any,
                    "amount" : self.subscriptionAmount
                    ] as [String : Any]
                
                self.subscriptionSucessAPI(param: param)
                
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
    
    func subscriptionSucessAPI(param : [String : Any]) {
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SUBSCRIPTIONPURCHASE, headerType: kPOSTHeader, isUserToken: true) { (response, error, sucess) in
            if sucess {
                WWMHelperClass.showPopupAlertController(sender: self, message: response["message"] as! String, title: kAlertTitle)
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
    
}
