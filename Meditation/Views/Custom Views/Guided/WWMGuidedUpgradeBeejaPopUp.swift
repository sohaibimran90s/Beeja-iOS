//
//  GuidedUpgradeBeejaPopUp.swift
//  Meditation
//
//  Created by Prema Negi on 06/01/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedUpgradeBeejaPopUp: UIView {
    @IBOutlet weak var viewLifeTime: UIView!
    @IBOutlet weak var viewAnnually: UIView!
    @IBOutlet weak var viewMonthly: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblBilledText: UILabel!
    @IBOutlet weak var btnMontly: UIButton!
    @IBOutlet weak var btnAnnually: UIButton!
    @IBOutlet weak var btnLifeTime: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    
    //aply coupon outlets
    @IBOutlet weak var viewACoupon: UIView!
    @IBOutlet weak var viewRedeemCoupon: UIView!
    @IBOutlet weak var btnACoupon: UIButton!
    @IBOutlet weak var btnRCoupon: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
 
    @IBAction func btnClose(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
