//
//  WWMListenMantraVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMListenMantraVC: WWMBaseViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnPlayPauseClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMChooseMantraListVC") as! WWMChooseMantraListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
