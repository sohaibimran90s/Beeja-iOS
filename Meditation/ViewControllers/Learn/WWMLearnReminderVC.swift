//
//  WWMLearnReminderVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnReminderVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }

    func setupView(){
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
    }
    
    @IBAction func btnSetReminderClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnDiscountVC") as! WWMLearnDiscountVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
