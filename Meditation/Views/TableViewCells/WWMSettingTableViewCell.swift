//
//  WWMSettingTableViewCell.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var btnPicker: WWMCustomButton!
    @IBOutlet weak var txtView: UITextField!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var imgViewDropDown: UIImageView!
    @IBOutlet weak var lblDropDown: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
