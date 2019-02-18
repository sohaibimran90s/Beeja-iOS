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
    

    var selectedProductIndex = 1
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    var productIDs = ["get_6_gbp_monthly_sub","get_42_gbp_annual_sub","get_108_gbp_lifetime_sub"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let actionSheetController = UIAlertController(title: kAlertTitle, message: "What do you want to do?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let buyAction = UIAlertAction(title: "Buy", style: UIAlertAction.Style.default) { (action) -> Void in
            let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] )
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) -> Void in
            
        }
        
        actionSheetController.addAction(buyAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK:- UIButton Action
    
    
    @IBAction func btnMonthlyAction(sender: AnyObject) {
        self.viewAnnually.isHidden = true
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = false
        self.selectedProductIndex = 0
    }
    
    @IBAction func btnAnnuallyAction(sender: AnyObject) {
        self.viewAnnually.isHidden = false
        self.viewLifeTime.isHidden = true
        self.viewMonthly.isHidden = true
        self.selectedProductIndex = 1
        
    }
    
    @IBAction func btnLifeTimeAction(sender: AnyObject) {
        self.viewAnnually.isHidden = true
        self.viewLifeTime.isHidden = false
        self.viewMonthly.isHidden = true
        self.selectedProductIndex = 2
        
    }
    
    @IBAction func btnContinuePaymentAction(sender: AnyObject) {
        
        self.showActions()
    }
    
    
    // MARK:- Payment Delegate Methods
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product )
            }
        }
        else {
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    
}
