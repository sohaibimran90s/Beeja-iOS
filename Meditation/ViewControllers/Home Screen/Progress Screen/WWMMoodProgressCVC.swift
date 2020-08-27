//
//  WWMMoodProgressCVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import GaugeKit
import EFCountingLabel

class WWMMoodProgressCVC: UICollectionViewCell {
    @IBOutlet weak var lblPercentage1: EFCountingLabel!
    @IBOutlet weak var lblPercentage2: EFCountingLabel!
    @IBOutlet weak var lblPercentage3: EFCountingLabel!
    @IBOutlet weak var lblPercentage4: EFCountingLabel!
    
    @IBOutlet weak var viewCircle1: Gauge!
    @IBOutlet weak var viewCircle2: Gauge!
    @IBOutlet weak var viewCircle3: Gauge!
    @IBOutlet weak var viewCircle4: Gauge!
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var btnMeditationType: UIButton!
}
