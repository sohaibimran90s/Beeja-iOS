//
//  WWM21DayChallengeTVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWM21DayChallengeTVC: UITableViewCell {

    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var upperLineLbl: UILabel!
    @IBOutlet weak var belowLineLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var backImg1: UIImageView!
    @IBOutlet weak var backImg2: UIImageView!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
