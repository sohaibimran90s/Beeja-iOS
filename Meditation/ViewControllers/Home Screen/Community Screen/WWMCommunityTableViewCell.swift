//
//  WWMCommunityTableViewCell.swift
//  Meditation
//
//  Created by Roshan Kumawat on 16/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import WebKit

class WWMCommunityTableViewCell: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var layoutCollectionviewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewCommunity: UICollectionView!
    @IBOutlet weak var btnSpotifyPlayList: UIButton!
    @IBOutlet weak var btnConnectSpotify: UIButton!
    @IBOutlet weak var viewConnectSpotify: UIView!
    @IBOutlet weak var viewUnderLine: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblMAW: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}


