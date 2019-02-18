//
//  WWMProgressMoodPieTVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import GaugeKit

class WWMProgressMoodPieTVC: UITableViewCell {

    @IBOutlet weak var lblPercentage1: UILabel!
    @IBOutlet weak var lblPercentage2: UILabel!
    @IBOutlet weak var lblPercentage3: UILabel!
    @IBOutlet weak var lblPercentage4: UILabel!
    
    @IBOutlet weak var viewCircle1: Gauge!
    @IBOutlet weak var viewCircle2: Gauge!
    @IBOutlet weak var viewCircle3: Gauge!
    @IBOutlet weak var viewCircle4: Gauge!
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var btnMeditationType: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
