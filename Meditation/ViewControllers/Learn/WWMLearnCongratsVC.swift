//
//  WWMLearnCongratsVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnCongratsVC: WWMBaseViewController {

    var watched_duration = ""
    var alertPrompt = WWMPromptMsg()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("wathced duration.... \(String(describing: Int(watched_duration)))")
        
    }
    
    @IBAction func btnCrossClicked(_ sender: UIButton) {
        self.xibCall()
    }
    
    func xibCall(){
        alertPrompt = UINib(nibName: "WWMPromptMsg", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMPromptMsg
        let window = UIApplication.shared.keyWindow!
        
        alertPrompt.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPrompt, duration: 0.8, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPrompt)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.alertPrompt.removeFromSuperview()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
                vc.meditationID = "0"
                vc.levelID = "0"
                vc.category_Id = ""
                vc.emotion_Id = ""
                vc.audio_Id = ""
                vc.rating = ""
                vc.type = "post"
                vc.watched_duration = self.watched_duration
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func navigateToDashboard() {
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
