//
//  WWMTabBarVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import Lottie

class WWMTabBarVC: UITabBarController,UITabBarControllerDelegate {

    let layerGradient = CAGradientLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupView()
        
        self.setDataToDb()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        
        layerGradient.colors = [UIColor.init(hexString: "#5732a3")!.cgColor, UIColor.init(hexString: "#001252")!.cgColor]
        layerGradient.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 84)
       self.tabBar.layer.insertSublayer(layerGradient, at: 0)
        for index in 0..<4 {
            let item = self.tabBar.items?[index]
            item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if index == 2 {
                
                item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
        self.selectedIndex = 2
    }
    

    
    func setDataToDb() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            WWMHelperClass.deletefromDb(dbName: "DBSettings")
        }
        
        let settingDB = WWMHelperClass.fetchEntity(dbName: "DBSettings") as! DBSettings
        settingDB.afterNoonReminderTime = "14:15"
        settingDB.ambientChime = kAmbient_WAVES_CHIMES
        settingDB.endChime = kChimes_HIMALAYAN_BELL
        settingDB.finishChime = kChimes_SUN_KOSHI
        settingDB.intervalChime = kChimes_BURMESE_BELL
        settingDB.isAfterNoonReminder = false
        settingDB.isMorningReminder = false
        settingDB.moodMeterEnable = true
        settingDB.morningReminderTime = "06:30"
        settingDB.startChime = kChimes_CHIME
        settingDB.prepTime = "10"
        settingDB.meditationTime = "90"
        settingDB.restTime = "20"
        
        WWMHelperClass.saveDb()
    }

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        for itemTab in  self.tabBar.items!{
            
            itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if itemTab == item {
                
                itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
    }
    
    func getUserProfileData() {
        
    }
    
}
