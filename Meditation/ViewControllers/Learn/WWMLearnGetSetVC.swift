//
//  WWMLearnGetSetVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnGetSetVC: WWMBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnPlayPauseAudioVC") as! WWMLearnPlayPauseAudioVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
