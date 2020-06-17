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
    let name = "Abc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblName.text = "You’re such a star, \(self.name)!"
    }
}
