//
//  WWMLearnDiscountVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnDiscountVC: WWMBaseViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnProceedClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
}
