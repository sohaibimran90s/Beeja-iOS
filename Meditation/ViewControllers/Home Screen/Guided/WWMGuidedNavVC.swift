//
//  WWMGuidedNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import CoreData

class WWMGuidedNavVC: WWMBaseViewController {

    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Dropdown Outlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var lblPractical: UILabel!
    @IBOutlet weak var lblSpritual: UILabel!
    @IBOutlet weak var imgPractical: UIImageView!
    @IBOutlet weak var imgSpritual: UIImageView!
    
    var arrGuidedList = [WWMGuidedData]()
    var type = "practical"
    var typeTitle = ""
    var guided_type = ""
    
    var containertapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dropDownView.isHidden = true
        
        self.offlineDatatoServerCall()
        
        containertapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDropDownTap(_:)))
        containertapGesture.delegate = self as? UIGestureRecognizerDelegate
        
        KNOTIFICATIONCENTER.addObserver(self, selector: #selector(self.methodOfGuidedDropDown(notification:)), name: Notification.Name("guidedDropDownClicked"), object: nil)

        if self.appPreference.getGuideType() == "practical"{
            self.typeTitle = "Practical Guidance"
            self.setUpNavigationBarForDashboard(title: "Practical Guidance")
            self.type = "practical"
            
            self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.imgSpritual.isHidden = true
            self.imgPractical.isHidden = false
        }else {
            self.typeTitle = "Spiritual Guidance"
            self.setUpNavigationBarForDashboard(title: "Spiritual Guidance")
            self.type = "spiritual"
            
            self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.imgSpritual.isHidden = false
            self.imgPractical.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationGuided(notification:)), name: Notification.Name("notificationGuided"), object: nil)
    }
    
    //insert offline data to server
    func offlineDatatoServerCall(){

        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            
            for data in nintyFivePercentDB{
                
                print("nintyFivePercentDB.count++++====== \(nintyFivePercentDB.count)")
                
                if let jsonResult = self.convertToDictionary1(text: data.data ?? "") {
                    
                    print("data....++++++===== \(data.data) id++++++++==== \(data.id)")
                    
                    self.completeMeditationAPI(mood_id: jsonResult["mood_id"] as? String ?? "", user_id: jsonResult["user_id"] as? String ?? "", rest_time: "\(jsonResult["rest_time"] as? Int ?? 0)", emotion_id: jsonResult["emotion_id"] as? String ?? "", tell_us_why: jsonResult["tell_us_why"] as? String ?? "", prep_time: "\(jsonResult["prep_time"] as? Int ?? 0)", meditation_time: "\(jsonResult["meditation_time"] as? Int ?? 0)", watched_duration: jsonResult["watched_duration"] as? String ?? "", level_id: jsonResult["level_id"] as? String ?? "", complete_percentage: "\(jsonResult["complete_percentage"] as? Int ?? 0)", rating: jsonResult["rating"] as? String ?? "", meditation_type: jsonResult["meditation_type"] as? String ?? "", category_id: jsonResult["category_id"] as? String ?? "", meditation_id: jsonResult["meditation_id"] as? String ?? "", date_time: jsonResult["date_time"] as? String ?? "", type: jsonResult["type"] as? String ?? "", guided_type: jsonResult["guided_type"] as? String ?? "", audio_id: jsonResult["audio_id"] as? String ?? "", step_id: "\(jsonResult["step_id"] as? Int ?? 1)", mantra_id: "\(jsonResult["mantra_id"] as? Int ?? 1)", id: "\(data.id ?? "")")
                    
                }
            }
        }
    }
    
    func completeMeditationAPI(mood_id: String, user_id: String, rest_time: String, emotion_id: String, tell_us_why: String, prep_time: String, meditation_time: String, watched_duration: String, level_id: String, complete_percentage: String, rating: String, meditation_type: String, category_id: String, meditation_id: String, date_time: String, type: String, guided_type: String, audio_id: String, step_id: String, mantra_id: String, id: String) {

        var param: [String: Any] = [:]
        if type == "learn"{
            param = [
                "type": type,
                "step_id": step_id,
                "mantra_id": mantra_id,
                "category_id" : category_id,
                "emotion_id" : emotion_id,
                "audio_id" : audio_id,
                "guided_type" : guided_type,
                "duration" : watched_duration,
                "rating" : rating,
                "user_id": user_id,
                "meditation_type": meditation_type,
                "date_time": date_time,
                "tell_us_why": tell_us_why,
                "prep_time": prep_time,
                "meditation_time": meditation_time,
                "rest_time": rest_time,
                "meditation_id": meditation_id,
                "level_id": level_id,
                "mood_id": mood_id,
                "complete_percentage": complete_percentage
                ] as [String : Any]
        }else{
            param = [
                "type": type,
                "category_id": category_id,
                "emotion_id": emotion_id,
                "audio_id": audio_id,
                "guided_type": guided_type,
                "watched_duration": watched_duration,
                "rating": rating,
                "user_id": user_id,
                "meditation_type": meditation_type,
                "date_time": date_time,
                "tell_us_why": tell_us_why,
                "prep_time": prep_time,
                "meditation_time": meditation_time,
                "rest_time": rest_time,
                "meditation_id": meditation_id,
                "level_id": level_id,
                "mood_id": mood_id,
                "complete_percentage": complete_percentage
                ] as [String : Any]
        }

        print("meter param... \(param)")

        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {

                print("URL_MEDITATIONCOMPLETE..... success guided")
                WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: id)
            }
        }
    }//insert offline data to server*

    
    @objc func notificationGuided(notification: Notification) {
        self.fetchGuidedDataFromDB()
    }
    
    @objc func handleDropDownTap(_ sender: UITapGestureRecognizer) {
        self.dropDownView.isHidden = true
        containerView.removeGestureRecognizer(containertapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchGuidedDataFromDB()
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
    }
    
    @objc func methodOfGuidedDropDown(notification: Notification){
        containerView.addGestureRecognizer(containertapGesture)
        self.dropDownView.isHidden = false
        if self.appPreference.getGuideType() == "practical"{
            self.type = "guided"
            guided_type = "practical"
            self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.imgSpritual.isHidden = true
            self.imgPractical.isHidden = false
        }else{
            self.type = "guided"
            guided_type = "spiritual"
            self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
            self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
            self.imgSpritual.isHidden = false
            self.imgPractical.isHidden = true
        }
    }
    
    @IBAction func btnPracticalClicked(_ sender: UIButton) {
        guided_type = "practical"
        self.type = "guided"
        self.lblPractical.font = UIFont.init(name: "Maax-Bold", size: 16)
        self.lblSpritual.font = UIFont.init(name: "Maax-Regular", size: 16)
        self.imgSpritual.isHidden = true
        self.imgPractical.isHidden = false
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.appPreference.setGuideType(value: self.guided_type)
        self.appPreference.setGuideTypeFor3DTouch(value: guided_type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
      /*
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
            
        } else {
            UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
        }
        */
    }
    
    @IBAction func btnSpritualClicked(_ sender: UIButton) {
        guided_type = "spiritual"
        self.type = "guided"
        self.lblPractical.font = UIFont.init(name: "Maax-Regular", size: 16)
        self.lblSpritual.font = UIFont.init(name: "Maax-Bold", size: 16)
        self.imgSpritual.isHidden = false
        self.imgPractical.isHidden = true
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.appPreference.setGuideType(value: self.guided_type)
        self.appPreference.setGuideTypeFor3DTouch(value: guided_type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
     /*   if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
            
        } else {
            UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
        }
        */
    }
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"         : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : type,
            "guided_type" : guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMGuidedNavVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                print("meditation api in guidednav in background...")
            }
        }
    }
    
    
    func setAnimationForExpressMood() {
        
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutExpressMoodViewWidth.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func btnExpressMoodAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
        vc.type = "pre"
        vc.meditationID = "0"
        vc.levelID = "0"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: Fetch Guided Data From DB
    func fetchGuidedDataFromDB() {
        
        let guidedDataDB = self.fetchGuidedFilterDB(type: self.type, dbName: "DBGuidedData")
        if guidedDataDB.count > 0{
            print("guidedDataDB count... \(guidedDataDB.count)")
            
            self.arrGuidedList.removeAll()
            
            var jsonString: [String: Any] = [:]
            var jsonEmotionsString: [String: Any] = [:]
            var jsonEmotions: [[String: Any]] = []
            for dict in guidedDataDB {
                
                jsonString["id"] = Int((dict as AnyObject).guided_id ?? "0")
                jsonString["name"] = (dict as AnyObject).guided_name as? String
                
                
                let guidedEmotionsDataDB = self.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).guided_id ?? "0", dbName: "DBGuidedEmotionsData")
                print("guidedEmotionsDataDB count... \(guidedEmotionsDataDB.count)")
                
                for dict1 in guidedEmotionsDataDB{
                    
                    jsonEmotionsString["emotion_id"] = Int((dict1 as AnyObject).emotion_id ?? "0")
                    jsonEmotionsString["emotion_name"] = (dict1 as AnyObject).emotion_name ?? ""
                    jsonEmotionsString["emotion_image"] = (dict1 as AnyObject).emotion_image ?? ""
                    jsonEmotionsString["tile_type"] = (dict1 as AnyObject).tile_type ?? ""
                    
                    jsonEmotions.append(jsonEmotionsString)
                }
                
                jsonString["emotion_list"] = jsonEmotions
                jsonEmotions.removeAll()
                let guidedData = WWMGuidedData.init(json: jsonString)
                self.arrGuidedList.append(guidedData)
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedDashboardVC") as! WWMGuidedDashboardVC
            vc.arrGuidedList = self.arrGuidedList
            vc.type = self.typeTitle
            self.addChild(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.containerView.addSubview((vc.view)!)
            vc.didMove(toParent: self)
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationGuided"), object: nil)
        }
       
    }
    
    func fetchGuidedFilterDB(type: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "meditation_type == %@", type)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
    
    func fetchGuidedFilterEmotionsDB(guided_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "guided_id == %@", guided_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
}
