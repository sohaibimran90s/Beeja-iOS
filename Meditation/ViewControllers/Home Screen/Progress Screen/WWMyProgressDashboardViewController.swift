//
//  WWMyProgressDashboardViewController.swift
//  Meditation
//
//  Created by Prashant Tayal on 17/04/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMyProgressDashboardViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var tabBarView: ButtonBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
    }
    
    func setUpUI() {
        
        print("frame width.... \(self.view.frame.size.width/2)")
        buttonBarView.frame.origin.y = -5
    
        
        buttonBarView.selectedBar.backgroundColor = UIColor.init(hexString: "#00eba9")
        buttonBarView.backgroundColor = UIColor.clear
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor(hexString: "#001252")
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size:  16)!
        }
       
        settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Medium", size:  16)!
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 30
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemLeftRightMargin = 20
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
             oldCell?.label.textColor = UIColor.init(white: 0.8, alpha: 1.0)
             newCell?.label.textColor = UIColor.white
        }
    }


    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var arrVC = [UIViewController]()
        
        let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressStatsVC") as! WWMMyProgressStatsVC
        vc1.itemInfo = IndicatorInfo.init(title: "Stats")
        
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressMoodVC") as! WWMMyProgressMoodVC
        vc2.itemInfo = IndicatorInfo.init(title: "Mood")
        
        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressJournalVC") as! WWMMyProgressJournalVC
        vc3.itemInfo = IndicatorInfo.init(title: "Journal")
        
        arrVC.append(vc1)
        arrVC.append(vc2)
        arrVC.append(vc3)
        
        return arrVC
    }
}
