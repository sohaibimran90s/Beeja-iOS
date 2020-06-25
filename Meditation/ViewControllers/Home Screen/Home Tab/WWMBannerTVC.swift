//
//  WWMBannerTVC.swift
//  Meditation
//
//  Created by Prema Negi on 23/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMBannerTVC: UITableViewCell {

    @IBOutlet weak var lblChallTitle: UILabel!
    @IBOutlet weak var lblChallSubTitle: UILabel!
    @IBOutlet weak var lblChallDes: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
