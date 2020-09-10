//
//  WWMAlertController.swift
//  Meditation
//
//  Created by Prema Negi on 26/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMAlertController: UIView {

    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    var isRemove = true
    
    @IBAction func btnOK(_ sender: UIButton) {
        if isRemove {
                self.removeFromSuperview()
        }
        
    }
    
    @IBAction func btnClose(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
