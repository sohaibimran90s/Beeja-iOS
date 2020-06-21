//
//  WWM8WeeksGridsViewController.swift
//  Meditation
//
//  Created by Prashant Tayal on 19/06/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM8WeeksGridsViewController: WWMBaseViewController, IndicatorInfoProvider, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var collectionBoxes: UICollectionView!
    
    var itemInfo: IndicatorInfo = "View"
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UISettings
    func UISetup() {
        btnContinue.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        btnContinue.layer.borderWidth = 2.0
    }

    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        itemInfo
    }
    
    //MARK:- CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        63
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell8Weeks", for: indexPath) as! Cell8Weeks
        
        //1. static unrevieled boxes
        if (indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 24 || indexPath.item == 61 || indexPath.item == 58 || indexPath.item == 55 || indexPath.item == 54) {
            cell.contentView.isHidden = true
            cell.isUserInteractionEnabled = false
        } else {
            cell.contentView.isHidden = false
            cell.isUserInteractionEnabled = true
        }
        
        //2. set selected
        cell.viewSquare.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        if indexPath.item == selectedIndex {
            cell.viewSquare.layer.borderWidth = 2
        } else {
            cell.viewSquare.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 45, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        btnContinue.alpha = 1.0
        btnContinue.isEnabled = true
        collectionBoxes.reloadData()
    }
}
