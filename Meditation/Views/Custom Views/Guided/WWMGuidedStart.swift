//
//  WWMGuidedStart.swift
//  Meditation
//
//  Created by Prema Negi on 25/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedStart: UIView {
    
    
    @IBOutlet weak var btnPractical: UIButton!
    @IBOutlet weak var btnSpritual: UIButton!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnMoreInformation: UIButton!

    override func draw(_ rect: CGRect) {
        self.btnPractical.layer.borderWidth = 2
        self.btnPractical.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.btnSpritual.layer.borderWidth = 2
        self.btnSpritual.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
    }
}
