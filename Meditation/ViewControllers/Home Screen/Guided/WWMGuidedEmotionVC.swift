//
//  WWMWisdomVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMGuidedEmotionVC: WWMBaseViewController,IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var itemInfo: IndicatorInfo = "View"
    var guidedData = WWMGuidedData()
    var type = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(guidedData.cat_EmotionList.count)
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
        if data.tile_type == "1" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMCommunityCollectionViewCell
            cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        }else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! WWMCommunityCollectionViewCell
        }
        cell.lblTitle.text = data.emotion_Name
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedAudioListVC") as! WWMGuidedAudioListVC
        vc.emotionData = data
        vc.type = self.type
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
        if data.tile_type == "1" {
            
        let width = (self.view.frame.size.width-19)/2
        return CGSize.init(width: width, height: width)
        }else {
            let width = (self.view.frame.size.width-16)
            return CGSize.init(width: width, height: 160)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            return headerView
            
        }
        let footerView =
            collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        
        return footerView
        
    }
}
