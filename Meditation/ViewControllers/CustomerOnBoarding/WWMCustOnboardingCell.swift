//
//  WWMCustOnboardingCell.swift
//  Meditation
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

class WWMCustOnboardingCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            //contentView.backgroundColor = UIColor(red: 0/255, green: 235/255, blue: 169/255, alpha: 1.0)
            self.textLabel?.textColor = UIColor(red: 0/255, green: 23/255, blue: 108/255, alpha: 1.0) // new
        } else {
            self.textLabel?.textColor = UIColor.white
        }
    }

    func setCellData(options: OptionsData) {
        
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        self.textLabel?.textColor = UIColor.white
        self.textLabel?.text = options.option_name
    }

}
