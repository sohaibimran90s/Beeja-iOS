//
//  WWMGuidedDashboardVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMGuidedDashboardVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var tabBarView: ButtonBarView!
    var arrGuidedList = [WWMGuidedData]()
    var type = ""
    let appPreference = WWMAppPreference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuidedListCount"), object: nil, userInfo: ["guidedCount": self.arrGuidedList.count])
        self.setUpUI()
    }
    
    
    func setUpUI() {
        
        buttonBarView.frame.origin.y = -4
        
        buttonBarView.selectedBar.backgroundColor = UIColor.init(hexString: "#00eba9")
        buttonBarView.backgroundColor = UIColor.clear
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 24)!
        }
        settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 26)!
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarMinimumInteritemSpacing = 1.0
        settings.style.buttonBarItemLeftRightMargin = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.init(white: 1.0, alpha: 1.0)
            newCell?.label.textColor = UIColor.init(white: 1.0, alpha: 1.0)
            
            newCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            oldCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
    
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let arrVC = NSMutableArray()
        
        print("arrGuidedList.count... \(arrGuidedList.count)")
        var isIntroCompleted: Bool?
        var emotionId = 0
        var emotionKey = ""
        var tile_type = ""
        
        for data in self.arrGuidedList {
            
            for i in 0..<data.cat_EmotionList.count{
                print("intro_completed...+++ \(data.cat_EmotionList[i].intro_completed) tile_type+++ \(data.cat_EmotionList[i].tile_type)")
                if data.cat_EmotionList[i].intro_completed{
                    isIntroCompleted = true
                    tile_type = data.cat_EmotionList[i].tile_type
                    print("title_type.... \(data.cat_EmotionList[i].tile_type)")
                }
                
                if data.cat_EmotionList[i].tile_type == "3"{
                    print("emotionId+++ \(data.cat_EmotionList[i].emotion_Id) emotionKey+++ \(data.cat_EmotionList[i].emotion_key)")
                    emotionId = data.cat_EmotionList[i].emotion_Id
                    emotionKey = data.cat_EmotionList[i].emotion_key
                    
                }
            }
            
            if data.cat_mode == "challenge"{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
            
                WWMHelperClass.xlpager = "challenge"
                print("data.cat_name... \(data.cat_Name)")
                if data.cat_Name.contains("21"){
                    if isIntroCompleted ?? false{
                        
                        if arrGuidedList.count > 3{
                            vc.itemInfo = IndicatorInfo.init(title: data.cat_Name, image: UIImage(named: "21_day_challenge_off"))
                        }else{
                            vc.itemInfo = IndicatorInfo.init(title: data.cat_Name, image: UIImage(named: "21_day_icon"))
                        }
                         
                    }else{
                         vc.itemInfo = IndicatorInfo.init(title: data.cat_Name, image: UIImage(named: "21_day_challenge_off"))
                    }
                }else{
                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                }
                
                vc.tile_type = tile_type
                vc.emotionId = emotionId
                vc.emotionKey = emotionKey
                vc.isIntroCompleted = isIntroCompleted ?? false
                vc.guidedData = data
                vc.type = self.type
                vc.cat_name = data.cat_Name
                vc.cat_id = data.cat_Id
                vc.guideTitleCount = arrGuidedList.count
                
                vc.min_limit = data.min_limit
                vc.max_limit = data.max_limit
                vc.meditation_key = data.meditation_key
                
                arrVC.add(vc)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedEmotionVC") as! WWMGuidedEmotionVC
                            
                print("data.cat_name... \(data.cat_Name)")
                vc.delegate = self
                vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                vc.guidedData = data
                vc.type = self.type
                vc.min_limit = data.min_limit
                vc.max_limit = data.max_limit
                vc.meditation_key = data.meditation_key
                        
                arrVC.add(vc)
            }
        }
        return arrVC as! [UIViewController]
        // return [UIViewController]
    }
}

extension WWMGuidedDashboardVC: WWMGuidedDashboardDelegate{
    func guidedEmotionReload(isTrue: Bool, vcName: String, tile_type: Int) {
        print("vcnamce.... \(vcName)")
        if (vcName == "WWMGuidedEmotionVC") && isTrue && tile_type == 2{
            appPreference.set21ChallengeName(value: "7_days")
            self.moveToViewController(at: 3, animated: true)
        }else if (vcName == "WWMGuidedEmotionVC") && isTrue && tile_type == 3{
            appPreference.set21ChallengeName(value: "")
            self.moveToViewController(at: 2, animated: true)
        }
    }
}
