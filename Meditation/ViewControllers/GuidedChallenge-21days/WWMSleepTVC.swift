//
//  WWMTableViewCell.swift
//  Meditation
//
//  Created by Prema Negi on 08/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMSleepTVC: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
