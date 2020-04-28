//
//  WWMProgressNavViewController.swift
//  Meditation
//
//  Created by Prashant Tayal on 17/04/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMProgressNavVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    
    var arrWisdomList = [WWMWisdomData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMyProgressDashboardViewController") as! WWMyProgressDashboardViewController
        self.addChild(vc)
        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview((vc.view)!)
        vc.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "My Progress")
    }
}
