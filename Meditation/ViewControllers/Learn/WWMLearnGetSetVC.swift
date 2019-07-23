//
//  WWMLearnGetSetVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnGetSetVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnPlayPauseAudioVC") as! WWMLearnPlayPauseAudioVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
