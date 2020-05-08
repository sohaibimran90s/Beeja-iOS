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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
    }
    
    func layout(){
        self.lblPracticalSessionCount.layer.cornerRadius = 16
        self.lblPracticalSessionCount.layer.borderWidth = 1.0
        self.lblPracticalSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        self.lblSpiritualSessionCount.layer.cornerRadius = 16
        self.lblSpiritualSessionCount.layer.borderWidth = 1.0
        self.lblSpiritualSessionCount.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        print("self.name+++ \(self.name)")
        if self.name == "7 Days challenge"{
            if WWMHelperClass.challenge7DayCount > 1{
                print("yes+++")
            }else{
                print("no+++")
                let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
                print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
                
                if guidedDataDB.count > 0{
                    for dict in guidedDataDB {
                        //print((dict as AnyObject).guided_id)
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                        
                        vc.id = (dict as AnyObject).guided_id ?? ""
                        self.navigationController?.pushViewController(vc, animated: false)
                        
                    }
                }
            }
        }else{
            print("21 days")
        }
    }
    
    @IBAction func btnPracticalAction(_ sender: UIButton){
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
        print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
        
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                if (dict as AnyObject).meditation_type == "practical"{
                    //print((dict as AnyObject).guided_id)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                    
                    vc.id = (dict as AnyObject).guided_id ?? ""
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
    }
    
    @IBAction func btnSpiritualAction(_ sender: UIButton){
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.name, dbName: "DBGuidedData", name: "guided_name")
        print("self.type+++ \(self.type) self.guided_type+++ \(self.name) guidedDataDB.count*** \(guidedDataDB.count)")
        
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                if (dict as AnyObject).meditation_type == "Spiritual"{
                    print((dict as AnyObject).guided_id)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DayChallengeVC") as! WWM21DayChallengeVC
                    
                    vc.id = (dict as AnyObject).guided_id ?? ""
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
