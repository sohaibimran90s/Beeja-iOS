//
//  WWMLearnFlightModeVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnFlightModeVC: WWMBaseViewController {
    
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnFlightMode: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        self.setupView()
    }
    
    func setupView(){
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnFlightMode.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func btnFlightModeClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnPlayPauseAudioVC") as! WWMLearnPlayPauseAudioVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
