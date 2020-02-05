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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }
    
    func setUpUI() {
        
        buttonBarView.frame.origin.y = -18
        
        buttonBarView.selectedBar.backgroundColor = UIColor.init(hexString: "#00eba9")
        buttonBarView.backgroundColor = UIColor.clear
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Bold", size: 16)!
        }
        settings.style.buttonBarItemFont = UIFont.init(name: "Maax-Bold", size: 14)!
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 15
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 15
        settings.style.buttonBarRightContentInset = 15
        settings.style.buttonBarMinimumInteritemSpacing = 1.0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.init(white: 0.8, alpha: 1.0)
            newCell?.label.textColor = UIColor.white
            
            newCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            oldCell?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
    
    
    // MARK: - PagerTabStripDataSource
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let arrVC = NSMutableArray()
        
        for data in self.arrGuidedList {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedEmotionVC") as! WWMGuidedEmotionVC
            
            print("data.cat_name... \(data.cat_Name)")
            vc.itemInfo = IndicatorInfo.init(title: data.cat_Name, image: UIImage(named: "21_day_icon"))
            vc.guidedData = data
            vc.type = self.type
        
            arrVC.add(vc)
        }
        return arrVC as! [UIViewController]
        // return [UIViewController]
    }
    

}
