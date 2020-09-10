//
//  WWM21DaySetReminderVC.swift
//  Meditation
//
//  Created by Prema Negi on 18/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWM21DaySetReminderVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnReminder: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        self.callHomeController()
    }
    
    @IBAction func btnReminderClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC
        
        vc.type = "21_days"
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
    
    func setupView(){
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                            attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        
        self.btnReminder.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
}
