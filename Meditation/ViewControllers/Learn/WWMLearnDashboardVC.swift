//
//  WWMLearnDashboardVC.swift
//  Meditation
//
//  Created by Prema Negi on 08/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol WWMLearnDashboardDelegate {
    func reloadTab(isTrue: Bool, vcName: String)
}

class WWMLearnDashboardVC: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var tabBarView: ButtonBarView!
    var arrLearnList = [WWMLearnData]()
    var name = ""
    let appPreference = WWMAppPreference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
        let name = self.appPreference.get21ChallengeName()
        if name != ""{
            self.reloadTab(isTrue: true, vcName: "30 Day Challenge")
        }
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
        
        for data in self.arrLearnList {
            //print("data.step_list--- \(data.step_list.count)")
            
            if data.name == "12 Steps"{
                //WWM21DayChallengeVC
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnStepListVC") as! WWMLearnStepListVC
                
                vc.delegate = self
                vc.itemInfo = IndicatorInfo.init(title: data.name)
                vc.learnStepsListData = data.step_list
                arrVC.add(vc)
            }else if data.name == "30 Day Challenge"{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM30DaysChallengeVC") as! WWM30DaysChallengeVC
                
                print(data.thirty_day_list)
                vc.delegate = self
                vc.itemInfo = IndicatorInfo.init(title: data.name)
                vc.daysListData = data.thirty_day_list
                arrVC.add(vc)
            }
        }
        
        return arrVC as! [UIViewController]
    }
}

extension WWMLearnDashboardVC: WWMLearnDashboardDelegate{
    func reloadTab(isTrue: Bool, vcName: String) {
        //print("vcnamce.... \(vcName)")
        if (vcName == "30 Day Challenge") && isTrue{
            
            var index = 0
            let name = self.appPreference.get21ChallengeName()
            for dic in self.arrLearnList{

                if name == dic.name{
                    break
                }
                index = index + 1
            }
            
            self.moveToViewController(at: index, animated: false)
            appPreference.set21ChallengeName(value: "")
        }
    }
}
