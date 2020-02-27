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
        var cell = WWMGuidedEmotionCVC()
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
        print("data.tile_type... \(data.tile_type)")
        
        if data.tile_type == "1" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMGuidedEmotionCVC
            
            cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            cell.lblTitle.text = data.emotion_Name
        }else if data.tile_type == "3" {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell3", for: indexPath) as! WWMGuidedEmotion21DaysCVC
            
            cell.lblTitle.text = data.emotion_Name
            
            cell.lblSubTitle.numberOfLines = 3
            cell.lblSubTitle.sizeToFit()
            cell.lblSubTitle.text = data.emotion_body
            return cell
            
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! WWMGuidedEmotionCVC
            cell.lblTitle.text = data.emotion_Name
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        if data.tile_type == "1" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedAudioListVC") as! WWMGuidedAudioListVC
            vc.emotionData = data
            vc.cat_Id = "\(self.guidedData.cat_Id)"
            vc.cat_Name = self.guidedData.cat_Name
            vc.type = self.type
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
            
            print("emotionKey... \(data.emotion_key) emotionId... \(data.emotion_Id) user_id... \(self.appPreference.getUserID())")
            vc.value = "curatedCards"
            vc.emotionId = data.emotion_Id
            vc.emotionKey = data.emotion_key
            vc.user_id = Int(self.appPreference.getUserID()) ?? 0
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
        if data.tile_type == "1" {
            
        let width = (self.view.frame.size.width-19)/2
            return CGSize.init(width: width, height: width)
        }else if data.tile_type == "3" {
            let width = (self.view.frame.size.width-16)
            return CGSize.init(width: width, height: 190)
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
