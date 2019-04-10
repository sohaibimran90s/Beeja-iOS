//
//  WWMCommunityTableViewCell.swift
//  Meditation
//
//  Created by Roshan Kumawat on 16/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMCommunityTableViewCell: UITableViewCell {

    @IBOutlet weak var layoutCollectionviewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewCommunity: UICollectionView!
    @IBOutlet weak var btnSpotifyPlayList: UIButton!
    @IBOutlet weak var btnConnectSpotify: UIButton!
    @IBOutlet weak var viewUnderLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
