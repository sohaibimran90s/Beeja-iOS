//
//  WWMTabBarItem.swift
//  Meditation
//
//  Created by Roshan Kumawat on 27/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMTabBarItem: UITabBarItem {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    func setup() {
        
        if let image = image {
            self.image = image.withRenderingMode(.alwaysOriginal)
            
        }
        if let image = selectedImage {
            selectedImage = image.withRenderingMode(.alwaysOriginal)
            
        }
        
    }
    
}
