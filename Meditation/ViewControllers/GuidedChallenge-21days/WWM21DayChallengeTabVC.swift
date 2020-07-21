//
//  WWM21DayChallengeTabVC.swift
//  Meditation
//
//  Created by Prema Negi on 06/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWM21DayChallengeTabVC: WWMBaseViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "View"
    var type = ""
    var name = ""
    var meditationType = ""
    
    @IBOutlet weak var lblPracticalSessionCount: UILabel!
    @IBOutlet weak var lblSpiritualSessionCount: UILabel!
    @IBOutlet weak var lblChallTypePractical: UILabel!
    @IBOutlet weak var lblChallTypeSpiritual: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPracticalCount: UILabel!
    @IBOutlet weak var lblSpiritualCount: UILabel!
    
    var delegate: WWMGuidedDashboardDelegate?
    var check7Days = false
    let reachable = Reachabilities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblPracticalSessionCount.isHidden = true
        self.lblSpiritualSessionCount.isHidden = true
        self.getSessionCount(name: self.name)
        self.layout()
    }
    
    func layout(){
        self.lblPracticalSessionCount.layer.cornerRadius = 16
        self.lblPracticalSessionCount.layer.borderWidth = 1.0
        self.lblPracticalSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        self.lblSpiritualSessionCount.layer.cornerRadius = 16
        self.lblSpiritualSessionCount.layer.borderWidth = 1.0
        self.lblSpiritualSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        self.lblTitle.text = self.name.capitalized
        if self.name.contains("21"){
            self.lblDescription.text = "A curated set of 21 guided sessions, aimed at taking you on a journey and creating habits. Choose a style of guidance - from Practical or Spiritual to get started."
        }else{
            self.lblDescription.text = "A curated set of 7 guided sessions, aimed at taking you on a journey and creating habits. Choose a style of guidance - from Practical or Spiritual to get started."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.toCheck7DayChallengeExit()
    }
    
    func toCheck7DayChallengeExit(){
        //print("self.name+++ \(self.name)")
        if self.name == "7 Days challenge"{
            self.lblChallTypePractical.text = "7 DAY CHALLENGE"
            self.lblChallTypeSpiritual.text = "7 DAY CHALLENGE"
            
            if WWMHelperClass.challenge7DayCount > 1{
                //print("yes+++")
            }else{
                //print("no+++")
                let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
                //print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
                
                if guidedDataDB.count > 0{
                    for dict in guidedDataDB {
                        //print("...... \((dict as AnyObject).guided_id) .... meditation_type \(((dict as AnyObject).meditation_type)) self.name..... \(self.name)")
                        
                        let subCategory = ((dict as AnyObject).meditation_type) ?? "practical"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                            
                            self.appPreference.set21ChallengeName(value: self.name)
                            vc.cat_name = self.name
                            vc.name = self.name
                            vc.subCategory = subCategory ?? "practical"
                            vc.category = self.name
                            vc.intro_url = (dict as AnyObject).intro_url ?? ""
                            vc.id = (dict as AnyObject).guided_id ?? ""
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                }
            }
        }else{
            self.lblChallTypePractical.text = "21 DAY CHALLENGE"
            self.lblChallTypeSpiritual.text = "21 DAY CHALLENGE"
            
        }
    }
    
    func getSessionCount(name: String){
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
        //print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                if (dict as AnyObject).meditation_type == "practical"{
                    let complete_count = (dict as AnyObject).complete_count ?? "0"
                    if Int(complete_count!)! > 0{
                        
                        self.lblPracticalSessionCount.isHidden = false
                        self.lblPracticalSessionCount.text = "\(complete_count ?? "0")"
                        lblPracticalCount.text = "\(complete_count ?? "0") days done, you’re doing great!"
                    }
                }
                if (dict as AnyObject).meditation_type == "spiritual"{
                    let complete_count = (dict as AnyObject).complete_count ?? "0"
                    if Int(complete_count!)! > 0{
                        
                        self.lblSpiritualSessionCount.isHidden = false
                        self.lblSpiritualSessionCount.text = "\(complete_count ?? "0")"
                        lblSpiritualCount.text = "\(complete_count ?? "0") days done, you’re doing great!"
                    }
                }
            }
        }
    }
    
    @IBAction func btnPracticalAction(_ sender: UIButton){
        practicalAction()
    }
    
    func checkSpiritualIntroVideoCompleted(){
        let getChallengeStatus = self.appPreference.getSpiritualChallenge()
        if getChallengeStatus{
            //print("Challenge already accepted")
        }else{
            //print("Challenge not accepted yet")
        }
    }
    
    func practicalAction(){
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
        //print("self.type+++ \(self.type) self.name+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
        
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                //print((dict as AnyObject).meditation_type)
                if (dict as AnyObject).meditation_type == "practical"{
                    //print("\((dict as AnyObject).guided_id) \((dict as AnyObject).emotion_key)")
                    
                    let getChallengeStatus = self.appPreference.getPracticalChallenge()
                    if getChallengeStatus{
                        //print("Challenge already accepted")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                        
                        self.appPreference.set21ChallengeName(value: self.name)
                        vc.cat_name = self.name
                        vc.intro_url = (dict as AnyObject).intro_url ?? ""
                        vc.name = self.name
                        vc.subCategory = "practical"
                        vc.category = self.name
                        vc.id = (dict as AnyObject).guided_id ?? ""
                        self.navigationController?.pushViewController(vc, animated: false)
                    }else{
                        //print("Challenge not accepted yet")
                        
                        if reachable.isConnectedToNetwork() {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                                                        
                            vc.value = "curatedCards"
                            vc.emotionId = ""
                            vc.id = (dict as AnyObject).guided_id ?? ""
                            vc.videoURL = (dict as AnyObject).intro_url ?? ""
                            vc.category = self.name
                            vc.subCategory = "practical"
                            vc.emotionKey = (dict as AnyObject).meditation_key ?? ""
                            self.navigationController?.pushViewController(vc, animated: false)
                        }else {
                            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                        }
                    }
                }
            }
        }
    }
    
    func spiritualAction(){
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
        //print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
        
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                if (dict as AnyObject).meditation_type == "spiritual"{
                    //print((dict as AnyObject).guided_id)
                    
                    let getChallengeStatus = self.appPreference.getSpiritualChallenge()
                    if getChallengeStatus{
                        //print("Challenge already accepted")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                        
                        self.appPreference.set21ChallengeName(value: self.name)
                        vc.cat_name = self.name
                        vc.intro_url = (dict as AnyObject).intro_url ?? ""
                        vc.name = self.name
                        vc.subCategory = "spiritual"
                        vc.category = self.name
                        vc.id = (dict as AnyObject).guided_id ?? ""
                        vc.emotionKey = (dict as AnyObject).meditation_key ?? ""
                        self.navigationController?.pushViewController(vc, animated: false)
                    }else{
                        //print("Challenge not accepted yet")
                        
                        if reachable.isConnectedToNetwork() {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                                                        
                            vc.value = "curatedCards"
                            vc.emotionId = ""
                            vc.id = (dict as AnyObject).guided_id ?? ""
                            vc.videoURL = (dict as AnyObject).intro_url ?? ""
                            vc.category = self.name
                            vc.subCategory = "spiritual"
                            vc.emotionKey = (dict as AnyObject).meditation_key ?? ""
                            self.navigationController?.pushViewController(vc, animated: false)
                        }else {
                            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnSpiritualAction(_ sender: UIButton){
        spiritualAction()
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        print(self.name)
        return itemInfo
    }
}
