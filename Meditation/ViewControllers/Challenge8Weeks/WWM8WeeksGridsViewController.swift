//
//  WWM8WeeksGridsViewController.swift
//  Meditation
//
//  Created by Prashant Tayal on 19/06/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM8WeeksGridsViewController: WWMBaseViewController, IndicatorInfoProvider, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var collectionBoxes: UICollectionView!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblTodaysMed: UILabel!
    @IBOutlet weak var lblDaysCount: UILabel!
    @IBOutlet weak var lbl7DaysRevealText: UILabel!
    @IBOutlet weak var lblTodaysMedTC: NSLayoutConstraint!
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var btnReminderTC: NSLayoutConstraint!
    @IBOutlet weak var btnIntro: UIButton!
    @IBOutlet weak var viewExpired: UIView!
    @IBOutlet weak var viewExpiredTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRetake: UIView!
    @IBOutlet weak var viewRetakeTopConstraint: NSLayoutConstraint!
    
    var itemInfo: IndicatorInfo = "View"
    var selectedIndex: Int?
    var daysListData: [EightWeekModel] = []
    var checkExpireRetake = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetup()
    }
    
    //MARK:- UISettings
    func UISetup() {
        btnContinue.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        btnContinue.layer.borderWidth = 2.0
        
        self.check8WeekStatus()
    }
    
    func check8WeekStatus(){
        //to check if 8 challenge is expire or not
        if self.appPreference.get8WeekIsExpired(){
            self.checkExpireRetake = 1
        }
        
        //to check if 8 challenge is to retake
        if week8Count() == 63{
            self.checkExpireRetake = 2
        }
        
        if self.checkExpireRetake == 0{
            //Working
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = true
            self.lblTodaysMedTC.constant = 25
            self.lblTodaysMed.isHidden = false
            
            self.checkIntroCompleted()
        }else if self.checkExpireRetake == 1{
            //Expired
            self.viewExpired.isHidden = false
            self.viewRetake.isHidden = true
            self.lblTodaysMedTC.constant = 10
            self.lblTodaysMed.isHidden = true
            self.lblReminder.isHidden =  true
            self.btnIntro.isHidden = true
            self.btnReminder.isHidden = true
            self.btnContinue.isHidden = true
            self.lblDaysCount.isHidden = true
            self.lbl7DaysRevealText.isHidden = true
        }else{
            //Retake
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = false
             self.lblTodaysMedTC.constant = 10
            self.lblTodaysMed.isHidden = true
            self.lblReminder.isHidden =  true
            self.btnReminder.isHidden = true
            self.btnIntro.isHidden = true
            self.btnContinue.isHidden = true
            self.lblDaysCount.isHidden = true
            self.lbl7DaysRevealText.isHidden = true
        }
    }
    
    //to check if the challenge is expired or not
    func week8Count() -> Int{
        var completed30DayCount = 0
        for index in 0..<self.daysListData.count{
            if self.daysListData[index].date_completed != ""{
                completed30DayCount = completed30DayCount + 1
            }
            
            return completed30DayCount
        }
        return 0
    }
    
    //to check if to show intro button or not
    func checkIntroCompleted(){
                
        let intro_completed = self.appPreference.get8IntroCompleted()
        if intro_completed{
            self.btnIntro.isHidden = true
        }else{
            self.btnIntro.isHidden = false
        }
        
        var settingData = DBSettings()
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if let _ = settingData.eightWeekReminder{
                if (settingData.eightWeekReminder != "" || settingData.eightWeekReminder != nil){
                    self.btnReminder.isHidden = true
                    self.lblReminder.isHidden = true
                    self.btnReminder.frame.size.height = 0
                    self.btnReminderTC.constant = 0
                }else{
                    self.btnReminder.isHidden = false
                    self.lblReminder.isHidden = false
                    self.btnReminder.frame.size.height = 29
                    self.btnReminderTC.constant = 16
                }
            }else{
                self.btnReminder.isHidden = false
                self.lblReminder.isHidden = false
                self.btnReminder.frame.size.height = 29
                self.btnReminderTC.constant = 16
            }
        }
    }
    
    @IBAction func btnIntroAction(_ sender: UIButton) {
    }
    
    @IBAction func btnReminderAction(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC
        
        vc.isSetting = true
        vc.type = "8_week"
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        itemInfo
    }
    
    //MARK:- CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.daysListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell8Weeks", for: indexPath) as! Cell8Weeks
        
        //1. static unrevieled boxes
        if (indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 24 || indexPath.item == 61 || indexPath.item == 58 || indexPath.item == 55 || indexPath.item == 54) {
            cell.contentView.isHidden = true
            cell.isUserInteractionEnabled = false
        } else {
            cell.contentView.isHidden = false
            cell.isUserInteractionEnabled = true
        }
        
        //2. set selected
        cell.viewSquare.layer.borderColor = UIColor(hexString: "#00EBA9")?.cgColor
        if indexPath.item == selectedIndex {
            cell.viewSquare.layer.borderWidth = 2
        } else {
            cell.viewSquare.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 45, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        btnContinue.alpha = 1.0
        btnContinue.isEnabled = true
        collectionBoxes.reloadData()
    }
    
    @IBAction func btnContinueAction(_ sender: UIButton) {
    }
}
