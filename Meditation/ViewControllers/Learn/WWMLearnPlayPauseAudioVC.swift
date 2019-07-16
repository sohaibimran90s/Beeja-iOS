//
//  WWMLearnPlayPauseAudioVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnPlayPauseAudioVC: WWMBaseViewController {

    @IBOutlet weak var btnStart: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    func setupView(){
        self.btnStart.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    
    @IBAction func btnBeginClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMChooseMantraVC") as! WWMChooseMantraVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
