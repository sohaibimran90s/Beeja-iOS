//
//  WWMLearnDiscountVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnDiscountVC: WWMBaseViewController {

    @IBOutlet weak var lblCompMsg: UILabel!
    var intro_url = ""
    var intro_completed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblCompMsg.text = "Yay \(self.appPreference.getUserName()), you’ve completed the 12 steps Learn to meditate course successfully."
        self.intro_url = self.appPreference.get30DaysURL()
        self.intro_completed = self.appPreference.get30IntroCompleted()
    }
    
    @IBAction func btnProceedClicked(_ sender: UIButton) {
        
        print(self.intro_completed)
        if self.intro_url == ""{
            self.navigateToDashboard()
        }else{
            if self.intro_completed{
                self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                self.navigateToDashboard()
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

                vc.videoURL = self.intro_url
                vc.value = "30days"
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    func navigateToDashboard() {
        
        
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 4 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
}
