//
//  WWMMomentsTVC.swift
//  Meditation
//
//  Created by Prema Negi on 22/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMMomentsTVC: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewSection: UIView!
    @IBOutlet weak var lblSectionTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
