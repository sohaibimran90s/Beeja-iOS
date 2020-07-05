//
//  UIImage+Resize.swift
//  MeditationDemo
//
//  Created by Ehsan on 25/6/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    func jpeg(_ quality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
