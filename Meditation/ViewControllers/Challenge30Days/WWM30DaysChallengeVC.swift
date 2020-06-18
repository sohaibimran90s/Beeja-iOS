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
    
    var itemInfo: IndicatorInfo = "View"
    var daysListData: [ThirtyDaysListData] = []
    
    var array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
        print(self.daysListData.count)
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func setUpView(){
        if self.i == 0{
            //Working
            self.viewExpired.isHidden = true
            self.viewRetake.isHidden = true
            self.viewReminder.isHidden = false
            self.viewHeaderHC.constant = 126
            self.lblMeditationCount.text = "Day 2/30"
            self.lblMeditationCountTopConstraint.constant = 16
            self.viewCollectionViewHC.constant = 403
            self.viewMeditationDaysHC.constant = 530
            self.viewExpiredTopConstraint.constant = 8
            self.lblLine.isHidden = false
            self.btnStartChallenge.isHidden = false
            self.lblBelowTitle.text = "Psst, we have little surprises everytime you complete a milestone."
        }else if self.i == 1{
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
    }
    
    @IBAction func btnExpiredClicked(_ sender: UIButton){
        
    }
    
    @IBAction func btnRetakeClicked(_ sender: UIButton){
        
    }
    
    //MARK: Share the love
    @IBAction func btnShareLoveClicked(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMShareLoveVC") as! WWMShareLoveVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Start Challenge
    @IBAction func btnStartChalClicked(_ sender: UIButton){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WWM30DaysChallengeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imgLeft = cell.viewWithTag(1) as! UIImageView
       // let imgRight = cell.viewWithTag(4) as! UIImageView
        let imgLock = cell.viewWithTag(5) as! UIImageView
        let viewBackLbl = cell.viewWithTag(2)!
        let lblChallNo = cell.viewWithTag(3) as! UILabel
        
        viewBackLbl.layer.borderWidth = 2.0
        viewBackLbl.layer.borderColor = UIColor.white.cgColor
        lblChallNo.text = "\(self.array[indexPath.item])"
        
        imgLock.layer.cornerRadius = 8
        imgLock.layer.borderColor = UIColor.black.cgColor
        imgLock.layer.borderWidth = 2
        
//        if self.daysListData[indexPath.item].completed{
//            imgLeft.image = UIImage(named: "lineGreen")
//        }else{
//            imgLeft.image = UIImage(named: "lineWhite")
//        }
        
        if self.array[indexPath.item]%7 == 0 || self.array[indexPath.item] == 30{
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTodaysChallengeVC") as! WWMTodaysChallengeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
