//
//  LoggerView.swift
//  Meditation
//
//  Created by Prema Negi on 02/09/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class LoggerView: UIView {

    @IBOutlet weak var btnSendLogs: UIButton!
    @IBOutlet weak var btnDeleteLogs: UIButton!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var txtFDateFrom: UITextField!
    @IBOutlet weak var txtFDateTo: UITextField!
    @IBOutlet weak var btnCloseTrailC: NSLayoutConstraint!
    @IBOutlet weak var btnCloseTopC: NSLayoutConstraint!
    
    @IBAction func btnClose(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
