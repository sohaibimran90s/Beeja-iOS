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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: strType)
        self.lblTitle.text = self.strType
        webView.navigationDelegate = self
        let reachable = Reachability()
        if !reachable.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Alert",
                                          message: "The Internet connection appears to be offline.",
                                          preferredStyle: UIAlertController.Style.alert)
            
            
            let OKAction = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true,completion: nil)
        }else {
            self.loadWebView()
        }
        
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
