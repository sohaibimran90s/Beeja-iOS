//
//  WWMProgressMoodPieTVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 08/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import WebKit


class WWMProgressMoodPieTVC: UITableViewCell {

    //CellCiruclarGraph
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //graph
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var chartView: CustomChart!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var overViewBtn: UIButton!
    @IBOutlet weak var preLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var overviewLeading: NSLayoutConstraint!
    @IBOutlet weak var leadingMonth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
