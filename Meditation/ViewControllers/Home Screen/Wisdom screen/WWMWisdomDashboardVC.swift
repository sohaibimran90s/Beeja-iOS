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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
    }
    
    func setUpUI() {
        
        print("frame width.... \(self.view.frame.size.width/2)")
        buttonBarView.frame.origin.y = -18
        if arrWisdomList.count == 1{
            buttonBarView.frame.origin.x = self.view.frame.size.width/2 - 51
            //60
        }
    
        
        buttonBarView.selectedBar.backgroundColor = UIColor.init(hexString: "#00eba9")
        buttonBarView.backgroundColor = UIColor.clear
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Regular", size:  18)!
        }
       
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 18)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        settings.style.buttonBarMinimumInteritemSpacing = 20
        settings.style.buttonBarItemLeftRightMargin = 20
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
             oldCell?.label.textColor = UIColor.init(white: 0.8, alpha: 1.0)
             newCell?.label.textColor = UIColor.white
        }
    }


    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let arrVC = NSMutableArray()
        
        for data in self.arrWisdomList {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomVC") as! WWMWisdomVC
            vc.itemInfo = IndicatorInfo.init(title: data.cat_Name)
            vc.wisdomData = data
            arrVC.add(vc)
        }
        return arrVC as! [UIViewController]
    }
}
