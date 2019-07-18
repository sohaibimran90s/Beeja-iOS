//
//  WWMLearnStepListTVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnStepListTVC: UITableViewCell {
    
    @IBOutlet weak var lblStepDescription: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var imgLock: UIImageView!
    @IBOutlet weak var imgArraow: UIImageView!
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var lblNoOfSteps: UILabel!
    @IBOutlet weak var lblUprLine: UILabel!
    @IBOutlet weak var lblBelowLine: UILabel!
    @IBOutlet weak var backCellView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
