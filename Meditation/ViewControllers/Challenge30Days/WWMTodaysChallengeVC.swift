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
    
    var daysListData = ThirtyDaysListData()
    var week8Data = EightWeekModel()
    var type = ""
    var dayNo = 1
    var isTwoTimePlay = false
    var twoTimeDay = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.type == ""{
            self.lblDayNo.text = "Day \(daysListData.day_name)"
            self.lblDescription.text = "\(daysListData.Description)"
            self.lblAuthor.text = "\(daysListData.auther_name)"
        }else{
            
            if week8Data.date_completed != ""{
                self.lblDayNo.text = "Day \(week8Data.day_name)"
            }else{
                if isTwoTimePlay{
                    self.lblDayNo.text = "Day \(dayNo)/\(self.twoTimeDay)"
                }else{
                    self.lblDayNo.text = "Day \(dayNo)"
                }
            }
            self.lblDescription.text = "\(week8Data.Description)"
            self.lblAuthor.text = "\(week8Data.auther_name)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func btnCrossAction(_ sender: UIButton){
        if type == ""{
            self.appPreference.set21ChallengeName(value: "30 Day Challenge")
        }else{
            self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChallengeAction(_ sender: UIButton){
        if type == ""{
            self.appPreference.set21ChallengeName(value: "30 Day Challenge")
        }else{
            self.appPreference.set21ChallengeName(value: "8 Weeks Challenge")
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTimerHomeVC") as! WWMTimerHomeVC

        vc.daysListData = daysListData
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func callHomeController(){
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 4
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
