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
        let wisdomVideoDataDB = WWMHelperClass.fetchDB(dbName: "DBWisdomVideoData") as! [DBWisdomVideoData]
        
        var resultArray: [[String: Any]] = []
        var jsonString: [String: Any] = [:]
        var video_listJson: [String: Any] = [:]
        var video_list: [[String: Any]] = []
        if wisdomDataDB.count > 0 {
            for dict in wisdomDataDB {
                jsonString["id"] = Int(dict.id ?? "0")
                jsonString["name"] = dict.name
                
                for dict1 in wisdomVideoDataDB{
                    if dict1.wisdom_id == dict.id{
                        
                        video_listJson["id"] = Int(dict1.video_id ?? "0")
                        video_listJson["name"] = dict1.video_name ?? ""
                        video_listJson["poster_image"] = dict1.video_img ?? ""
                        video_listJson["video_url"] = dict1.video_url ?? ""
                        video_listJson["duration"] = dict1.video_duration ?? ""
                        video_listJson["vote"] = dict1.video_vote
                    }
                    
                    video_list.append(video_listJson)
                }
                
                jsonString["video_list"] = video_list
                resultArray.append(jsonString)
                
                print("resultArray... \(resultArray.count)")
                print("video_list... \(video_list.count)")
            }
            
            print("resultArray... \(resultArray.count)")
            print(resultArray)
            
            if let wisdomList = resultArray as? [[String:Any]] {
                self.arrWisdomList.removeAll()
                for data in wisdomList {
                    let wisdomData = WWMWisdomData.init(json: data)
                    self.arrWisdomList.append(wisdomData)
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
}
