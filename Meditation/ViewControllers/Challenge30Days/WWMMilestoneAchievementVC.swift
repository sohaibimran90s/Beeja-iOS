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
    let name = "Abc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        self.lblName.text = "You’re such a star,\n\(self.name)!"
    }
    
    func setUpView(){
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
