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
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func btnCrossAction(_ sender: UIButton){
        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnChallengeAction(_ sender: UIButton){
        
    }
}
