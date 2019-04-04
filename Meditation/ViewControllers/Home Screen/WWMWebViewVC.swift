//
//  WWMWebViewVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import WebKit

class WWMWebViewVC: WWMBaseViewController,WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    var strType = ""
    var strUrl = ""
    
    //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: strType)
        self.lblTitle.text = self.strType
        webView.navigationDelegate = self
        let reachable = Reachabilities()
        if !reachable.isConnectedToNetwork(){
            
            
            let alertPopupView: WWMAlertController = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
            let window = UIApplication.shared.keyWindow!
            
            alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
            alertPopupView.btnOK.layer.borderWidth = 2.0
            alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            
            alertPopupView.lblTitle.text = "Alert"
            alertPopupView.lblSubtitle.text = "The Internet connection appears to be offline."
            alertPopupView.btnClose.isHidden = true
            
            alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
            window.rootViewController?.view.addSubview(alertPopupView)
            
            
//            let alert = UIAlertController(title: "Alert",
//                                          message: "The Internet connection appears to be offline.",
//                                          preferredStyle: UIAlertController.Style.alert)
//            
//            
//            let OKAction = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
//                self.navigationController?.popViewController(animated: true)
//            }
//            alert.addAction(OKAction)
//            self.present(alert, animated: true,completion: nil)
        }else {
            self.loadWebView()
        }
        
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
         self.webView.stopLoading()
    }
    func loadWebView() {
        let url = URL.init(string: strUrl)
        let request = URLRequest.init(url: url!)
        WWMHelperClass.showActivity(on: self.view, with: UIColor.init(hexString: "#00eba9")!)
        self.webView.load(request)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        WWMHelperClass.hideActivity(fromView: self.view)
        print("Finished navigating to url \(String(describing: webView.url))");
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        WWMHelperClass.hideActivity(fromView: self.view)
        
    }
    
    

}
