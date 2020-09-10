//
//  WWMMyProgressVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMMyProgressVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnJournal: UIButton!
    @IBOutlet weak var btnMood: UIButton!
    @IBOutlet weak var btnStats: UIButton!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var moodView: UIView!
    @IBOutlet weak var journalView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBarForDashboard(title: "My Progress")
        self.setUpSelectedButtonUI(btn: btnStats)
        
//        xlpagerSettings()
        
        // Do any additional setup after loading the view.
    }
    
    func xlpagerSettings() {
        
    }
    
    func setUpSelectedButtonUI(btn:UIButton) {
        
        statsView.backgroundColor = UIColor.clear
        moodView.backgroundColor = UIColor.clear
        journalView.backgroundColor = UIColor.clear
         btnStats.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 12)
         btnMood.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 12)
         btnJournal.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 12)
        
//        btnJournal.backgroundColor = UIColor.white
//        btnJournal.layer.borderWidth = 1.0
//        btnJournal.layer.borderColor = UIColor.lightGray.cgColor
//        btnJournal.setTitleColor(UIColor.lightGray, for: .normal)
//
//        btnMood.backgroundColor = UIColor.white
//        btnMood.layer.borderWidth = 1.0
//        btnMood.layer.borderColor = UIColor.lightGray.cgColor
//        btnMood.setTitleColor(UIColor.lightGray, for: .normal)
//
//        btnStats.backgroundColor = UIColor.white
//        btnStats.setTitleColor(UIColor.lightGray, for: .normal)
//        btnStats.layer.borderWidth = 1.0
//        btnStats.layer.borderColor = UIColor.lightGray.cgColor
        var vc = UIViewController()
        if btn == btnStats {
            
            statsView.backgroundColor = UIColor.init(hexString: "#00eba9")
            btnStats.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 14)
             vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressStatsVC") as! WWMMyProgressStatsVC
            
            
        }else if btn == btnMood{
            
            moodView.backgroundColor = UIColor.init(hexString: "#00eba9")
            btnMood.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 14)
            vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressMoodVC") as! WWMMyProgressMoodVC
            
        }else if btn == btnJournal {
            
            journalView.backgroundColor = UIColor.init(hexString: "#00eba9")
            btnJournal.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 14)
            vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMyProgressJournalVC") as! WWMMyProgressJournalVC
            
        }
        if self.children.count > 0 {
            for childVc in self.children {
                childVc.willMove(toParent: nil)
                childVc.view.removeFromSuperview()
                childVc.removeFromParent()
            }
        }
        self.addChild(vc)
        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    @IBAction func btnJournalAction(_ sender: Any) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS_JOURNAL", itemId: "VIEWED", itemName: "")
        self.setUpSelectedButtonUI(btn: btnJournal)
    }
    
    @IBAction func btnMoodAction(_ sender: Any) {
        self.setUpSelectedButtonUI(btn: btnMood)
    }
    
    @IBAction func btnStatsAction(_ sender: Any) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "PROGRESS", itemId: "CALENDAR", itemName: "VIEWED")
        self.setUpSelectedButtonUI(btn: btnStats)
    }

}
