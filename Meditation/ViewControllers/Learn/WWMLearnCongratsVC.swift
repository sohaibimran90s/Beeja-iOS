//
//  WWMLearnCongratsVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnCongratsVC: WWMBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnCrossClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }

}
