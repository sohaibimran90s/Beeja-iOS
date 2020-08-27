//
//  WWMSlider.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSlider: UISlider {
    
    fileprivate func updateSlider() {
        
        if !ascending {
            self.transform = CGAffineTransform(rotationAngle:CGFloat(-Double.pi/2))
        } else {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        }
        self.setThumbImage(UIImage.init(named: "Slider_Icon"), for: .normal)
        
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = self.bounds
        rect.size.height = 8
        rect.origin.y = rect.origin.y + 15
        return rect
    }
    
   // - (CGRect)trackRectForBounds:(CGRect)bounds{
   // CGRect customBounds = ...
   // return customBounds;/
   // }
    @IBInspectable open var ascending: Bool = false {
        didSet {
            updateSlider()
        }
    }
}
