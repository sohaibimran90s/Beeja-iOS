//
//  OnBoardingModel.swift
//  Meditation
//
//  Created by Prema Negi on 21/04/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import Foundation


struct OnBoardingModel: Codable {
    var data: [OnBoardingDataModel]?
}

struct OnBoardingDataModel: Codable {
    var title: String?
    var description: String?
    var imageName: String?
}
