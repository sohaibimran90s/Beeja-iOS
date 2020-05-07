//
//  WWM21DayChallengeTabVC.swift
//  Meditation
//
//  Created by Prema Negi on 06/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM21DayChallengeTabVC: WWMBaseViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "View"
    
    @IBOutlet weak var lblPracticalSessionCount: UILabel!
    @IBOutlet weak var lblSpiritualSessionCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func layout(){
        self.lblPracticalSessionCount.layer.cornerRadius = 16
        self.lblPracticalSessionCount.layer.borderWidth = 1.0
        self.lblPracticalSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        self.lblSpiritualSessionCount.layer.cornerRadius = 16
        self.lblSpiritualSessionCount.layer.borderWidth = 1.0
        self.lblSpiritualSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btnPracticalAction(_ sender: UIButton){
        
    }
    
    @IBAction func btnSpiritualAction(_ sender: UIButton){
        
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
