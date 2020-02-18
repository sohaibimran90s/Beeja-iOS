//
//  WWM21DaySetReminderVC.swift
//  Meditation
//
//  Created by Prema Negi on 18/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWM21DaySetReminderVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnReminder: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC

        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func setupView(){
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                            attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        
        self.btnReminder.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
}
