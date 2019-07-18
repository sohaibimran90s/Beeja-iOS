//
//  WWMHomePodcastTVC.swift
//  Meditation
//
//  Created by Prema Negi on 12/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMHomePodcastTVC: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var playPauseImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
