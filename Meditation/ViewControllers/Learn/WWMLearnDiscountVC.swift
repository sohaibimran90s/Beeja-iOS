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
        self.intro_completed = self.appPreference.get30IntroCompleted()
    }
    
    @IBAction func btnProceedClicked(_ sender: UIButton) {
        
        print(self.intro_completed)
        if self.intro_url == ""{
            self.callHomeVC1()
        }else{
            if self.intro_completed{
                self.appPreference.set21ChallengeName(value: "30 Day Challenge")
                self.callHomeVC1()
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

                vc.emotionKey = "30days"
                vc.challenge_type = "30days"
                vc.value = "30days"
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
}
