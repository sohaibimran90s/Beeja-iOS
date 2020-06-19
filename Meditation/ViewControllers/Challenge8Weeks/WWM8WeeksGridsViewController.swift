//
//  WWM8WeeksGridsViewController.swift
//  Meditation
//
//  Created by Prashant Tayal on 19/06/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM8WeeksGridsViewController: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var btnContinue: UIButton!
    var itemInfo: IndicatorInfo = "View"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UISettings
    func UISetup() {
        btnContinue.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        btnContinue.layer.borderWidth = 2.0
    }

    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
}
