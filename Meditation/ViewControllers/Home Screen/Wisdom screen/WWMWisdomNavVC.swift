//
//  WWMWisdomNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWisdomNavVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    
    var arrWisdomList = [WWMWisdomData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationWisdom(notification:)), name: Notification.Name("notificationWisdom"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Wisdom")
        
        self.fetchWisdomDataFromDB()
        //self.getWisdomAPI()
    }

    @objc func notificationWisdom(notification: Notification) {
        self.fetchWisdomDataFromDB()
    }
    
    // MARK: fetch WisdomData From DB
    
    func fetchWisdomDataFromDB() {
        let wisdomDataDB = WWMHelperClass.fetchDB(dbName: "DBWisdomData") as! [DBWisdomData]
        let wisdomDataDB1 = WWMHelperClass.fetchDB(dbName: "DBWisdomVideoData") as! [DBWisdomVideoData]
        
        //print("wisdomDataDB count... \(wisdomDataDB.count) wisdomDataDB1... \(wisdomDataDB1.count)")
        if wisdomDataDB.count > 0 {
            
            self.arrWisdomList.removeAll()
            
            for dict in wisdomDataDB {
                
                
                
                var jsonString: [String: Any] = [:]
                var jsonEmotionsString: [String: Any] = [:]
                var jsonEmotions: [[String: Any]] = []

                jsonString["id"] = Int(dict.id ?? "0")
                jsonString["name"] = dict.name
                                
                if (dict as AnyObject).id == nil{
                    return
                }
                
                let wisdomVideoDataDB = WWMHelperClass.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).id ?? "6", dbName: "DBWisdomVideoData", name: "wisdom_id")
                //print("wisdomVideoDataDB count... \(wisdomVideoDataDB.count) wisdomDataDB id... \((dict as AnyObject).id)")
                
                for dict1 in wisdomVideoDataDB{
                    
                    print((dict1 as AnyObject).video_name)
                    jsonEmotionsString["id"] = Int((dict1 as AnyObject).video_id ?? "0")
                    jsonEmotionsString["is_intro"] = (dict1 as AnyObject).is_intro ?? "0"
                    jsonEmotionsString["name"] = (dict1 as AnyObject).video_name ?? ""
                    jsonEmotionsString["poster_image"] = (dict1 as AnyObject).video_img ?? ""
                    jsonEmotionsString["video_url"] = (dict1 as AnyObject).video_url ?? ""
                    jsonEmotionsString["duration"] = (dict1 as AnyObject).video_duration ?? ""
                    jsonEmotionsString["vote"] = (dict1 as AnyObject).video_vote
                    
                    jsonEmotions.append(jsonEmotionsString)
                }
                
                jsonString["video_list"] = jsonEmotions
                jsonEmotions.removeAll()
                let guidedData = WWMWisdomData.init(json: jsonString)
                self.arrWisdomList.append(guidedData)
                
            }
            
            //if let view = self.containerView.cont
            for view in self.containerView.subviews{
                view.removeFromSuperview()
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomDashboardVC") as! WWMWisdomDashboardVC
            vc.arrWisdomList = self.arrWisdomList
            self.addChild(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.containerView.addSubview((vc.view)!)
            vc.didMove(toParent: self)
            
            
        }
    }
}
