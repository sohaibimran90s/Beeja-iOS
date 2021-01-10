//
//  WWMWisdomDashboardVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMWisdomDashboardVC: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var tabBarView: ButtonBarView!
    var arrWisdomList = [WWMWisdomData]()
    let appPreference = WWMAppPreference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 25)!
        }
        settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size: 23)!
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemLeftRightMargin = 5
        
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
        
        for data in self.arrWisdomList {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomVC") as! WWMWisdomVC
            vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
            vc.wisdomData = data
            vc.subTabName = data.cat_Name
            arrVC.add(vc)
        }
        
        //to jump in particular index
        let name = self.appPreference.getWisdomName()
        if name != ""{
            var index = 0
            let name = self.appPreference.getWisdomName()
            for dic in self.arrWisdomList{
                if name == dic.cat_Name{
                    break
                }
                index = index + 1
            }
            
            if index > self.arrWisdomList.count - 1{
                index = 0
            }
            
            pagerTabStripController.moveToViewController(at: index, animated: false)
            //appPreference.set21ChallengeName(value: "")
        }//end*
        
        
        return arrVC as! [UIViewController]
    }
}
