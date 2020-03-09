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
        
        //self.fetchGuidedDataFromDB()
        
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
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
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
                "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
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
                print("result guidednavvc meditation data... \(result)")
                print("meditation api in guidednav in background...")
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                    }
                }
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
            var jsonAudiosString: [String: Any] = [:]
            var jsonAudios: [[String: Any]] = []
            
            var stepNo: Int = 0
            var cat_name = String()
            
            for dict in guidedDataDB {
                
                cat_name = (dict as AnyObject).guided_name as? String ?? ""
                
                jsonString["id"] = Int((dict as AnyObject).guided_id ?? "0")
                jsonString["name"] = (dict as AnyObject).guided_name as? String
                jsonString["meditation_type"] = (dict as AnyObject).meditation_type as? String
                jsonString["mode"] = (dict as AnyObject).guided_mode as? String
                
                let guidedEmotionsDataDB = self.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).guided_id ?? "0", dbName: "DBGuidedEmotionsData")
                print("guidedEmotionsDataDB count... \(guidedEmotionsDataDB.count)")
                
                for dict1 in guidedEmotionsDataDB{
                    
                    print("guidedEmotionsDataDB dict.... \(Int((dict1 as AnyObject).emotion_id ?? "0")) \((dict1 as AnyObject).completed ?? false)  \((dict1 as AnyObject).completed_date ?? ""))")
                    
                    if cat_name.contains("21"){
                         stepNo = stepNo + 1
                    }
                    
                    jsonEmotionsString["emotion_id"] = Int((dict1 as AnyObject).emotion_id ?? "0")
                    jsonEmotionsString["emotion_name"] = (dict1 as AnyObject).emotion_name ?? ""
                    jsonEmotionsString["emotion_image"] = (dict1 as AnyObject).emotion_image ?? ""
                    jsonEmotionsString["tile_type"] = (dict1 as AnyObject).tile_type ?? ""
                    jsonEmotionsString["author_name"] = (dict1 as AnyObject).author_name ?? ""
                    jsonEmotionsString["emotion_body"] = (dict1 as AnyObject).emotion_body ?? ""
                    jsonEmotionsString["emotion_key"] = (dict1 as AnyObject).emotion_key ?? ""
                    jsonEmotionsString["intro_completed"] = (dict1 as AnyObject).intro_completed ?? false
                    jsonEmotionsString["completed"] = (dict1 as AnyObject).completed ?? false
                    jsonEmotionsString["completed_date"] = (dict1 as AnyObject).completed_date ?? ""
                    jsonEmotionsString["stepNo"] = stepNo
                    
                    let guidedAudiosDataDB = self.fetchGuidedFilterAudiosDB(emotion_id: (dict1 as AnyObject).emotion_id ?? "0", dbName: "DBGuidedAudioData")
                    print("guidedAudiosDataDB count... \(guidedAudiosDataDB.count)")
                    
                    for dict2 in guidedAudiosDataDB{
                        
                        print("dict2.... \(dict2)")
                        jsonAudiosString["emotion_id"] = Int((dict2 as AnyObject).emotion_id ?? "0")
                        jsonAudiosString["id"] = Int((dict2 as AnyObject).audio_id ?? "0")
                        jsonAudiosString["audio_name"] = (dict2 as AnyObject).audio_name ?? ""
                        jsonAudiosString["duration"] = Int((dict2 as AnyObject).duration ?? "0")
                        jsonAudiosString["paid"] = (dict2 as AnyObject).paid ?? false
                        jsonAudiosString["audio_image"] = (dict2 as AnyObject).audio_image ?? ""
                        jsonAudiosString["audio_url"] = (dict2 as AnyObject).audio_url ?? ""
                        jsonAudiosString["vote"] = (dict2 as AnyObject).vote ?? false

                        jsonAudios.append(jsonAudiosString)
                    }
                    
                    jsonEmotionsString["audio_list"] = jsonAudios
                    jsonEmotions.append(jsonEmotionsString)
                    jsonAudios.removeAll()
                }
                
                jsonString["emotion_list"] = jsonEmotions
                jsonEmotions.removeAll()
                let guidedData = WWMGuidedData.init(json: jsonString)
                self.arrGuidedList.append(guidedData)
            }
            
            //if let view = self.containerView.cont
            for view in self.containerView.subviews{
                view.removeFromSuperview()
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedDashboardVC") as! WWMGuidedDashboardVC
            vc.arrGuidedList = self.arrGuidedList
            vc.type = self.typeTitle
            self.addChild(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.containerView.addSubview((vc.view)!)
            vc.didMove(toParent: self)
            
            //NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationGuided"), object: nil)
        }else{
            self.getGuidedListAPI()
        }
       
    }
    
    func getGuidedListAPI() {
        
        let param = ["user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success result... getGuidedListAPI \(result)")
                    
                    if let audioList = result["result"] as? [[String:Any]] {
                        
                        print("audioList... \(audioList)")
                        
                        let guidedData = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
                        if guidedData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                        }
                        
                        let guidedEmotionsData = WWMHelperClass.fetchDB(dbName: "DBGuidedEmotionsData") as! [DBGuidedEmotionsData]
                        if guidedEmotionsData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                        }
                        
                        let guidedAudioData = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                        if guidedAudioData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                        }
                        
                        for guidedDict in audioList {
                            
                            let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            print("timeInterval.... \(timeInterval)")
                            
                            dbGuidedData.last_time_stamp = "\(timeInterval)"
                            
                            if let id = guidedDict["id"]{
                                dbGuidedData.guided_id = "\(id)"
                            }
                            
                            if let name = guidedDict["name"] as? String{
                                dbGuidedData.guided_name = name
                            }
                            
                            if let meditation_type = guidedDict["meditation_type"] as? String{
                                dbGuidedData.meditation_type = meditation_type
                            }
                            
                            if let guided_mode = guidedDict["mode"] as? String{
                                dbGuidedData.guided_mode = guided_mode
                            }
                            
                            if let emotion_list = guidedDict["emotion_list"] as? [[String: Any]]{
                                for emotionsDict in emotion_list {
                                    
                                    let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                    
                                    if let id = guidedDict["id"]{
                                        dbGuidedEmotionsData.guided_id = "\(id)"
                                    }
                                    
                                    if let emotion_id = emotionsDict["emotion_id"]{
                                        dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                    }
                                    
                                    if let author_name = emotionsDict["author_name"]{
                                        dbGuidedEmotionsData.author_name = "\(author_name)"
                                    }
                                    
                                    if let emotion_image = emotionsDict["emotion_image"] as? String{
                                        dbGuidedEmotionsData.emotion_image = emotion_image
                                    }
                                    
                                    if let emotion_name = emotionsDict["emotion_name"] as? String{
                                        dbGuidedEmotionsData.emotion_name = emotion_name
                                    }
                                    
                                    if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                        dbGuidedEmotionsData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedEmotionsData.intro_completed = false
                                    }
                                    
                                    if let tile_type = emotionsDict["tile_type"] as? String{
                                        dbGuidedEmotionsData.tile_type = tile_type
                                    }
                                    
                                    if let emotion_key = emotionsDict["emotion_key"] as? String{
                                        dbGuidedEmotionsData.emotion_key = emotion_key
                                    }
                                    
                                    if let emotion_body = emotionsDict["emotion_body"] as? String{
                                        dbGuidedEmotionsData.emotion_body = emotion_body
                                    }
                                    
                                    if let completed = emotionsDict["completed"] as? Bool{
                                        dbGuidedEmotionsData.completed = completed
                                    }
                                    
                                    if let completed_date = emotionsDict["completed_date"] as? String{
                                        dbGuidedEmotionsData.completed_date = completed_date
                                    }
                                    
                                    if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                        for audioDict in audio_list {
                                            
                                            let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                            
                                            if let emotion_id = emotionsDict["emotion_id"]{
                                                dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                            }
                                            
                                            if let audio_id = audioDict["id"]{
                                                dbGuidedAudioData.audio_id = "\(audio_id)"
                                            }
                                            
                                            if let audio_image = audioDict["audio_image"] as? String{
                                                dbGuidedAudioData.audio_image = audio_image
                                            }
                                            
                                            if let audio_name = audioDict["audio_name"] as? String{
                                                dbGuidedAudioData.audio_name = audio_name
                                            }
                                            
                                            if let audio_url = audioDict["audio_url"] as? String{
                                                dbGuidedAudioData.audio_url = audio_url
                                            }
                                            
                                            if let author_name = audioDict["author_name"] as? String{
                                                dbGuidedAudioData.author_name = author_name
                                            }
                                            
                                            if let duration = audioDict["duration"]{
                                                dbGuidedAudioData.duration = "\(duration)"
                                            }
                                            
                                            if let paid = audioDict["paid"] as? Bool{
                                                dbGuidedAudioData.paid = paid
                                            }
                                            
                                            if let vote = audioDict["vote"] as? Bool{
                                                dbGuidedAudioData.vote = vote
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                        }
                                    }
                                    
                                    WWMHelperClass.saveDb()
                                }
                            }
                            
                            WWMHelperClass.saveDb()
                            
                            self.fetchGuidedDataFromDB()
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuided"), object: nil)
                        print("guided data tabbarvc in background thread...")
                    }
                }
            }
        }
    }//end guided api*

    
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
    
    func fetchGuidedFilterAudiosDB(emotion_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "emotion_id == %@", emotion_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
}
