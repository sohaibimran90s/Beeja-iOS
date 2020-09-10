//
//  GuidedUpgradeBeejaPopUp.swift
//  Meditation
//
//  Created by Prema Negi on 06/01/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedUpgradeBeejaPopUp: UIView, UITextFieldDelegate {
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
     
    @IBAction func btnClose(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
