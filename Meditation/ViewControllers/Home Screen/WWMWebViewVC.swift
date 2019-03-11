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
        self.loadWebView()
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
        WWMHelperClass.dismissSVHud()
        print("Finished navigating to url \(String(describing: webView.url))");
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        WWMHelperClass.hideActivity(fromView: self.view)
        
    }
    
    

}
