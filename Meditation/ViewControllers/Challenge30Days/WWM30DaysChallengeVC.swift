//
//  WWM30DaysChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/04/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM30DaysChallengeVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHC: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblMeditationCount: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var lblBelowTitle: UILabel!
    @IBOutlet weak var btnStartChallenge: UIButton!
    @IBOutlet weak var lblMeditationCountTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewReminder: UIView!
    @IBOutlet weak var viewExpired: UIView!
    @IBOutlet weak var viewExpiredTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRetake: UIView!
    @IBOutlet weak var viewRetakeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeaderHC: NSLayoutConstraint!
    @IBOutlet weak var viewMeditationDaysHC: NSLayoutConstraint!
    @IBOutlet weak var viewCollectionViewHC: NSLayoutConstraint!
    @IBOutlet weak var btnIntro: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnReminder: UIButton!
    
    let reachable = Reachabilities()
    var itemInfo: IndicatorInfo = "View"
    var daysListData: [ThirtyDaysListData] = []
    
    var completed30DayCount = 0
    var checkExpireRetake = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func setUpView(){
        
        
        
        
        if self.checkExpireRetake == 0{
            //Working
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = true
            self.viewReminder.isHidden = false
            self.lblMeditationCount.text = "Day 2/30"
            self.lblMeditationCountTopConstraint.constant = 16
            self.viewCollectionViewHC.constant = 403
            self.viewMeditationDaysHC.constant = 530
            self.viewExpiredTopConstraint.constant = 8
            self.lblLine.isHidden = false
            self.btnStartChallenge.isHidden = false
            self.lblBelowTitle.text = "Psst, we have little surprises everytime you complete a milestone."
            
            if self.appPreference.getInvitationCount() > 4{
                self.viewHeaderHC.constant = 86
                self.btnShare.isHidden = true
            }else{
                self.viewHeaderHC.constant = 126
                self.btnShare.isHidden = false
            }
            
        }else if self.checkExpireRetake == 1{
            //Expired
            self.viewExpired.isHidden = false
            self.viewRetake.isHidden = true
            self.viewReminder.isHidden = true
            self.viewHeaderHC.constant = 90
            self.lblMeditationCount.text = ""
            self.lblMeditationCountTopConstraint.constant = 6
            self.viewCollectionViewHC.constant = 310
            self.viewMeditationDaysHC.constant = 360
            self.viewExpiredTopConstraint.constant = 16
            self.lblLine.isHidden = true
            self.btnStartChallenge.isHidden = true
            self.lblBelowTitle.text = ""
        }else{
            //Retake
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = false
            self.viewReminder.isHidden = true
            self.viewHeaderHC.constant = 82
            self.lblMeditationCount.text = "Day 30/30"
            self.lblMeditationCountTopConstraint.constant = 16
            self.viewCollectionViewHC.constant = 310
            self.viewMeditationDaysHC.constant = 390
            self.viewRetakeTopConstraint.constant = 16
            self.lblLine.isHidden = true
            self.btnStartChallenge.isHidden = true
            self.lblBelowTitle.text = ""
        }
        
        print(self.viewCollectionViewHC.constant)
        if WWMHelperClass.hasTopNotch{
            self.collectionViewHC.constant = 290
            self.viewCollectionViewHC.constant = self.viewCollectionViewHC.constant + 30
            self.viewMeditationDaysHC.constant = self.viewMeditationDaysHC.constant + 30
        }else{
            self.collectionViewHC.constant = 260
        }
        
        self.checkIntroCompleted()
    }
    
    //to check if the challenge is expired or not
    func day30Count() -> Int{
        
        for index in 0..<self.daysListData.count{
            if self.daysListData[index].date_completed != ""{
                self.completed30DayCount = self.completed30DayCount + 1
            }
            
            return self.completed30DayCount
        }
        return 0
    }
    
    //to check if to show intro button or not
    func checkIntroCompleted(){
        let intro_completed = self.appPreference.get30IntroCompleted()
        if intro_completed{
            self.btnIntro.isHidden = true
        }else{
            self.btnIntro.isHidden = false
        }
        
        var settingData = DBSettings()
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if settingData.thirtyDaysReminder != ""{
                self.btnReminder.isHidden = true
                self.lblReminder.isHidden = true
            }else{
                self.btnReminder.isHidden = false
                self.lblReminder.isHidden = false
            }
        }
        
        self.setLblTitle()
    }
    
    //to check if 12 steps completed today
    func setLblTitle(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        print("getDate12Step... \(self.appPreference.getDate12Step() ) date... \(dateFormatter.string(from: Date()))")
        if self.appPreference.getDate12Step() == dateFormatter.string(from: Date()){
            self.lblTitle.text = "Tomorrow is the first day of your challenge"
        }else{
            self.lblTitle.text = "Continue on your meditation journey and challenge yourself to create life-long habits."
        }
    }
    
    //MARK: Challenge Expired button
    @IBAction func btnExpiredClicked(_ sender: UIButton){
        
    }
    
    //MARK: Challenge Retake button
    @IBAction func btnRetakeClicked(_ sender: UIButton){
        
    }
    
    //MARK: Set a Reminder button
    @IBAction func btnReminderClicked(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC
        
        vc.isSetting = true
        vc.type = "30_days"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Share the love
    @IBAction func btnShareLoveClicked(_ sender: UIButton){
        if !reachable.isConnectedToNetwork() {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validatation_JournalOfflineMsg, title: kAlertTitle)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMShareLoveVC") as! WWMShareLoveVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //Start Challenge
    @IBAction func btnStartChalClicked(_ sender: UIButton){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnIntroVideoClicked(_ sender: UIButton){
        
        if self.appPreference.get21CompletedDaysCount() != 12{
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

        vc.challenge_type = "30days"
        vc.value = "30days"
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension WWM30DaysChallengeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.daysListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imgLeft = cell.viewWithTag(1) as! UIImageView
       // let imgRight = cell.viewWithTag(4) as! UIImageView
        let imgLock = cell.viewWithTag(5) as! UIImageView
        let viewBackLbl = cell.viewWithTag(2)!
        let lblChallNo = cell.viewWithTag(3) as! UILabel
    
        viewBackLbl.layer.borderWidth = 2.0
        lblChallNo.text = "\(self.daysListData[indexPath.item].day_name)"
        
        imgLock.layer.cornerRadius = 8
        imgLock.layer.borderColor = UIColor.black.cgColor
        imgLock.layer.borderWidth = 2
        
        if indexPath.item == 29{
            imgLeft.isHidden = true
        }
        
        if self.daysListData[indexPath.item].completed{
            viewBackLbl.backgroundColor = UIColor.init(hexString: "#00eba9")!
            viewBackLbl.layer.borderColor = UIColor.clear.cgColor
            imgLeft.image = UIImage(named: "lineGreen")
            lblChallNo.textColor = UIColor.black
        }else{
            viewBackLbl.layer.borderColor = UIColor.white.cgColor
            viewBackLbl.backgroundColor = UIColor.clear
            imgLeft.image = UIImage(named: "lineWhite")
            lblChallNo.textColor = UIColor.white
        }
        
        if self.daysListData[indexPath.item].is_milestone{
            imgLeft.isHidden = true
            imgLock.isHidden = false
        }else{
            imgLeft.isHidden = false
            imgLock.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width)/7
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        appPreference.set21ChallengeName(value: "30 Day Challenge")
        self.pushViewController(sender_Tag: indexPath.item)
    }
    
    func pushViewController(sender_Tag: Int){
        
        let obj = WWMLearnStepListVC()
        var flag = 0
        var position = 0
        
        print(self.daysListData[position].day_name)
        
        if self.daysListData[sender_Tag].completed{
            self.appPreference.setType(value: "learn")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            return
        }else{
            for i in 0..<sender_Tag{
                let date_completed = self.daysListData[i].date_completed
                if date_completed != ""{
                    let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                    if dateCompare.0 == 1{
                        flag = 1
                        break
                    }
                }
            }
        }
        
        //its mean you have done todays challenge
        if flag == 1{
            obj.xibCall(title1: KLEARNONESTEP)
            return
        }
        
        for i in 0..<sender_Tag{
            if !self.daysListData[i].completed{
                flag = 2
                position = i
                break
            }
        }
        
        //its mean you have not done previous step
        if flag == 2{
            obj.xibCall(title1: "\(KLEARNJUMPSTEP) \(self.daysListData[position].day_name) \(KLEARNJUMPSTEP1)")
        }else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
            
            WWMHelperClass.day_30_name = self.daysListData[position].day_name
            vc.daysListData = self.daysListData[position]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func check(sender_Tag: Int) -> Int{
        for i in 0..<sender_Tag{
            let date_completed = self.daysListData[i].date_completed
            if date_completed != ""{
                return 1
            }
        }
        return 0
    }
}
