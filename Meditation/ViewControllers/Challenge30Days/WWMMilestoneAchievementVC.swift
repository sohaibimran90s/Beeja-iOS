//
//  WWMMilestoneAchievementVC.swift
//  Meditation
//
//  Created by Prema Negi on 12/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMMilestoneAchievementVC: WWMBaseViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnProgress: UIButton!
    @IBOutlet weak var btnCrossTrailC: NSLayoutConstraint!
    @IBOutlet weak var btnCrossTopC: NSLayoutConstraint!
    let name = "Abc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        self.lblName.text = "You’re such a star,\n\(self.name)!"
    }
    
    func setUpView(){
        
        if WWMHelperClass.hasTopNotch{
            self.btnCrossTrailC.constant = 20
            self.btnCrossTopC.constant = 8
        }else{
            self.btnCrossTrailC.constant = 16
            self.btnCrossTopC.constant = 8
        }
        self.btnProgress.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnProgress.layer.borderWidth = 1.0
    }
    
    @IBAction func btnHomeAction(_ sender: UIButton){
        self.callHomeVC(index: 2)
    }
    
    @IBAction func btnProgressAction(_ sender: UIButton){
        self.callHomeVC(index: 4)
    }
}
