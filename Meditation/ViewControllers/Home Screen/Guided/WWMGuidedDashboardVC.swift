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
    var arrGuidedList1 = [WWMGuidedData]()
    var type = ""
    var name = ""
    let appPreference = WWMAppPreference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuidedListCount"), object: nil, userInfo: ["guidedCount": self.arrGuidedList.count])
        self.setUpUI()
        
//        let name = self.appPreference.get21ChallengeName()
//        if name != ""{
//            self.guidedEmotionReload(isTrue: true, vcName: "WWMGuidedEmotionVC")
//        }
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
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 28)!
        }
        settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 26)!
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
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
        
        //print("arrGuidedList.count... \(arrGuidedList.count)")
        self.getUniqueChallenge()
        if self.type == "Guided"{
            for data in self.arrGuidedList1 {
                
                //print(data.cat_mode)
                if data.cat_mode == "challenge"{
                    //WWM21DayChallengeVC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeTabVC") as! WWM21DayChallengeTabVC

                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name.capitalized)
                    vc.name = data.cat_Name
                    vc.meditationType = data.cat_meditation_type
                    arrVC.add(vc)
                }else if data.cat_mode == "playlist"{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMPlayListVC") as! WWMPlayListVC
                                
                    //print("data.cat_name... \(data.cat_Name)")
                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                    vc.guidedData = data
                    vc.type = self.type
                    vc.min_limit = data.min_limit
                    vc.max_limit = data.max_limit
                    vc.meditation_key = data.meditation_key
                            
                    arrVC.add(vc)
                }else if data.cat_mode == "moments"{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMomentsVC") as! WWMMomentsVC
                                
                    //print("data.cat_name... \(data.cat_Name)")
                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                    vc.guidedData = data
                    vc.type = self.type
                    vc.min_limit = data.min_limit
                    vc.max_limit = data.max_limit
                    vc.meditation_key = data.meditation_key
                            
                    arrVC.add(vc)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedEmotionVC") as! WWMGuidedEmotionVC
                                
                    //print("data.cat_name... \(data.cat_Name)")
                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                    vc.name = data.cat_Name
                    vc.guidedData = data
                    vc.type = self.type
                    vc.min_limit = data.min_limit
                    vc.max_limit = data.max_limit
                    vc.meditation_key = data.meditation_key
                            
                    arrVC.add(vc)
                }
            }
        }else{
            for data in self.arrGuidedList1 {
                
                if data.cat_mode == "challenge"{
                    //WWM21DayChallengeVC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeTabVC") as! WWM21DayChallengeTabVC

                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name.capitalized)
                    vc.name = data.cat_Name
                    vc.meditationType = data.cat_meditation_type
                    arrVC.add(vc)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepVC") as! WWMSleepVC
                                
                    //print("data.cat_name... \(data.cat_Name)")
                    vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
                    vc.guidedData = data
                    vc.type = self.type
                    vc.subType = data.cat_Name
                    vc.min_limit = data.min_limit
                    vc.max_limit = data.max_limit
                    vc.meditation_key = data.meditation_key
                            
                    arrVC.add(vc)
                }
            }
        }
        
        //to jump in particular index
        let name = self.appPreference.get21ChallengeName()
        if name != ""{
            var index = 0
            let name = self.appPreference.get21ChallengeName()
            for dic in self.arrGuidedList1{

                if name == dic.cat_Name{
                    break
                }
                index = index + 1
            }
            
            pagerTabStripController.moveToViewController(at: index, animated: false)
            appPreference.set21ChallengeName(value: "")
        }//end*
        
        return arrVC as! [UIViewController]
    }
    
    func getUniqueChallenge(){
        if self.arrGuidedList.count > 0{
            arrGuidedList1.removeAll()
            for dict in self.arrGuidedList{
                var flag = 0
                if arrGuidedList1.count > 0{
                    
                    for dict1 in arrGuidedList1{
                        if dict1.cat_Name.contains(dict.cat_Name){
                            flag = 1
                        }
                    }
                    if flag == 0{
                        self.arrGuidedList1.append(dict)
                    }
                    
                }else{
                    self.arrGuidedList1.append(dict)
                }
            }
        }
    }
}

extension WWMGuidedDashboardVC: WWMGuidedDashboardDelegate{
    func guidedEmotionReload(isTrue: Bool, vcName: String) {
        //print("vcnamce.... \(vcName)")
        if (vcName == "WWMGuidedEmotionVC") && isTrue{
            
            var index = 0
            let name = self.appPreference.get21ChallengeName()
            for dic in self.arrGuidedList1{
                
                //print("\(name) \(index) cat_name*** \(dic.cat_Name) self.arrGuidedList1.count*** \(self.arrGuidedList1.count) ")
                if name == dic.cat_Name{
                    break
                }
                index = index + 1
                //print("index \(index) self.arrGuidedList1.c0unt*** \(self.arrGuidedList1.count) cat_name*** \(dic.cat_Name)")
            }
            
            self.moveToViewController(at: index, animated: false)
            appPreference.set21ChallengeName(value: "")
        }
    }
}
