//
//  WWMWisdomVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol WWMGuidedDashboardDelegate {
    func guidedEmotionReload(isTrue: Bool, vcName: String)
}

class WWMGuidedEmotionVC: WWMBaseViewController,IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var itemInfo: IndicatorInfo = "View"
    var guidedData = WWMGuidedData()
    var type = ""
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    var name = ""
    
    var delegate: WWMGuidedDashboardDelegate?
    
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
        var myMutableString = NSMutableAttributedString()
        
        if data.tile_type == "1" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMGuidedEmotionCVC
            
            cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            cell.lblTitle.text = data.emotion_Name
        }else if data.tile_type == "3" {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell3", for: indexPath) as! WWMGuidedEmotion21DaysCVC
            
            let lblText = "21 Day Challenge: " + data.emotion_Name
            
            myMutableString = NSMutableAttributedString(string: lblText, attributes: [NSAttributedString.Key.font:UIFont(name: "Maax-Bold", size: 18.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "#00eba9")!, range: NSRange(location:0,length:17))
            // set label Attribute
            cell.lblTitle.attributedText = myMutableString
            //cell.lblTitle.text = data.emotion_Name
            
            //cell.lblSubTitle.numberOfLines = 3
            //cell.lblSubTitle.sizeToFit()
            //cell.lblSubTitle.text = data.emotion_body
            return cell
            
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! WWMGuidedEmotionCVC
            
            cell.layer.cornerRadius = 5
            let lblText = "7 Day Challenge: " + data.emotion_Name
            myMutableString = NSMutableAttributedString(string: lblText, attributes: [NSAttributedString.Key.font:UIFont(name: "Maax-Bold", size: 18.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "#00eba9")!, range: NSRange(location:0,length:16))
            // set label Attribute
            cell.lblTitle.attributedText = myMutableString
            //cell.lblTitle.text = data.emotion_Name
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
            
            vc.min_limit = self.min_limit
            vc.max_limit = self.max_limit
            vc.meditation_key = self.meditation_key
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
            if !data.intro_completed{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

                print("emotionKey... \(data.emotion_key) emotionId... \(data.emotion_Id) user_id... \(self.appPreference.getUserID())")
                vc.value = "curatedCards"
                vc.emotionId = data.emotion_Id
                vc.id = "\(self.guidedData.cat_Id)"
                if data.tile_type == "2" {
                    vc.category = "7 Days challenge"
                    vc.subCategory = self.name.lowercased()
                }else{
                    vc.category = "21 Days challenge"
                    vc.subCategory = self.name.lowercased()
                }
                
                vc.emotionKey = data.emotion_key
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                print("data.tile_type*** \(data.tile_type)")
                if data.tile_type == "2" {
                    //7_days
                    appPreference.set21ChallengeName(value: "7 Days challenge")
                    delegate?.guidedEmotionReload(isTrue: true, vcName: "WWMGuidedEmotionVC")
                    self.reloadTabs21DaysController()

                }else{
                    appPreference.set21ChallengeName(value: "21 Days challenge")
                    delegate?.guidedEmotionReload(isTrue: true, vcName: "WWMGuidedEmotionVC")
                    self.reloadTabs21DaysController()

                }
            }
        }
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
        
        //else if data.tile_type == "3" {
          //  let width = (self.view.frame.size.width-16)
            //return CGSize.init(width: width, height: 190)
        //}
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
    
    func reloadTabs21DaysController(){
        self.navigationController?.isNavigationBarHidden = false
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationReloadGuidedTabs"), object: nil)
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 2 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
}
