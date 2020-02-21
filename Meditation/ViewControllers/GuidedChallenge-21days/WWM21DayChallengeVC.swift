//
//  WWM21DayChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM21DayChallengeVC: WWMBaseViewController,IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var introBtn: UIButton!
    
    var selectedIndex = 0
    var itemInfo: IndicatorInfo = "View"
    var guidedData = WWMGuidedData()
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func introBtnAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminderVC") as! WWM21DaySetReminderVC

        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension WWM21DayChallengeVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWM21DayChallengeTVC") as! WWM21DayChallengeTVC
        
        if indexPath.row == 0{
            cell.upperLineLbl.isHidden = true
        }else{
            cell.upperLineLbl.isHidden = false
        }
        
        cell.stepLbl.layer.cornerRadius = 12
        
        if selectedIndex == indexPath.row{
            cell.descLbl.isHidden = false
            
            cell.backImg1.backgroundColor = UIColor(red: 14.0/255.0, green: 31.0/255.0, blue: 104.0/255.0, alpha: 0.7)
            cell.backImg2.isHidden = false
            cell.backImg1.isHidden = true
            cell.arrowImg.image = UIImage(named: "upArrow")
            cell.collectionView.isHidden = false
        }else{
            cell.descLbl.isHidden = true
            cell.backImg1.isHidden = false
            cell.backImg2.isHidden = true
            cell.arrowImg.image = UIImage(named: "downArrow")
            cell.collectionView.isHidden = true
            
        }
        cell.collectionView.tag = indexPath.row
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
}

extension WWM21DayChallengeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList[collectionView.tag].audio_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WWM21DayChallengeCVC", for: indexPath) as! WWM21DayChallengeCVC
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}
