//
//  WWMTodaysChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 12/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMTodaysChallengeVC: WWMBaseViewController {
    
    @IBOutlet weak var lblDayNo: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigateToDashboard()
    }
    
    @IBAction func btnCrossAction(_ sender: UIButton){
        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
        self.navigateToDashboard()
    }
    
    @IBAction func btnChallengeAction(_ sender: UIButton){
        
    }
    
    func navigateToDashboard() {
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 2 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
}
