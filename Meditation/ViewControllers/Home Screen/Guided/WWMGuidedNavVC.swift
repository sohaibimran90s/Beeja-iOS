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
    
    var arrGuidedList = [WWMGuidedData]()
    var type = "guided"
    var typeTitle = ""
    var guided_type = "Guided"
    var challenge7DayCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.offlineDatatoServerCall()
        KNOTIFICATIONCENTER.addObserver(forName: NSNotification.Name(rawValue: "guidedDropDownClicked"), object: nil, queue: nil, using: catchNotification)
        
        self.appPreference.setGuidedSleep(value: "Guided")
        self.typeTitle = "Guided"
        self.setUpNavigationBarForDashboard(title: "guided")
        self.guided_type = "Guided"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
    }
    
    //insert offline data to server
    func offlineDatatoServerCall(){

        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            
            for data in nintyFivePercentDB{
                
                print("nintyFivePercentDB.count++++====== \(nintyFivePercentDB.count)")
                
                if let jsonResult = self.convertToDictionary1(text: data.data ?? "") {
                    
                    print("data....++++++===== \(String(describing: data.data)) id++++++++==== \(String(describing: data.id))")
                    
                    self.completeMeditationAPI(mood_id: jsonResult["mood_id"] as? String ?? "", user_id: jsonResult["user_id"] as? String ?? "", rest_time: "\(jsonResult["rest_time"] as? Int ?? 0)", emotion_id: jsonResult["emotion_id"] as? String ?? "", tell_us_why: jsonResult["tell_us_why"] as? String ?? "", prep_time: "\(jsonResult["prep_time"] as? Int ?? 0)", meditation_time: "\(jsonResult["meditation_time"] as? Int ?? 0)", watched_duration: jsonResult["watched_duration"] as? String ?? "", level_id: jsonResult["level_id"] as? String ?? "", complete_percentage: "\(jsonResult["complete_percentage"] as? Int ?? 0)", rating: jsonResult["rating"] as? String ?? "", meditation_type: jsonResult["meditation_type"] as? String ?? "", category_id: jsonResult["category_id"] as? String ?? "", meditation_id: jsonResult["meditation_id"] as? String ?? "", date_time: jsonResult["date_time"] as? String ?? "", type: jsonResult["type"] as? String ?? "", guided_type: jsonResult["guided_type"] as? String ?? "", audio_id: jsonResult["audio_id"] as? String ?? "", step_id: "\(jsonResult["step_id"] as? Int ?? 1)", mantra_id: "\(jsonResult["mantra_id"] as? Int ?? 1)", id: "\(data.id ?? "")", is_complete: jsonResult["is_complete"] as? String ?? "0")
                    
                }
            }
        }
    }
    
    func completeMeditationAPI(mood_id: String, user_id: String, rest_time: String, emotion_id: String, tell_us_why: String, prep_time: String, meditation_time: String, watched_duration: String, level_id: String, complete_percentage: String, rating: String, meditation_type: String, category_id: String, meditation_id: String, date_time: String, type: String, guided_type: String, audio_id: String, step_id: String, mantra_id: String, id: String, is_complete: String) {

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
                "complete_percentage": complete_percentage,
                "is_complete": is_complete
                ] as [String : Any]
        }else{
            param = [
                "type": self.type,
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
                "complete_percentage": complete_percentage,
                "is_complete": is_complete
                ] as [String : Any]
        }

        print("meter param... \(param)")

        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {

                print("URL_MEDITATIONCOMPLETE..... success guided")
                WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: id, type: "id")
            }
        }
    }//insert offline data to server*
        
    override func viewWillAppear(_ animated: Bool) {
        self.fetchGuidedDataFromDB()
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
    }

    @objc func catchNotification(notification: Notification){
        self.type = notification.userInfo?["type"] as! String
        guided_type = notification.userInfo?["subType"] as! String
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.appPreference.setGuideType(value: self.guided_type)
        self.appPreference.setGuideTypeFor3DTouch(value: guided_type)
        print("type*** \(self.type) guided_type*** \(guided_type)")
        
        if guided_type == "Guided"{
            self.appPreference.setGuidedSleep(value: "Guided")
            self.typeTitle = "Guided"
            setUpNavigationBarForDashboard(title: "guided")
        }else{
            self.appPreference.setGuidedSleep(value: "Sleep")
            self.typeTitle = "Sleep"
            setUpNavigationBarForDashboard(title: "sleep")
        }
        
        self.fetchGuidedDataFromDB()
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }

        NotificationCenter.default.removeObserver(self, name: Notification.Name("methodOfGuidedDropDown"), object: nil)
    }
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"         : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : type,
            "guided_type" : guided_type
            ] as [String : Any]
        
        print("param*** \(param)")
        
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
        
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.guided_type, dbName: "DBGuidedData", name: "cat_name")
        print("self.type+++ \(self.type) self.guided_type+++ \(self.guided_type) guidedDataDB.count*** \(guidedDataDB.count)")
        
        self.challenge7DayCount = 0
        
        if guidedDataDB.count > 0{
            print("guidedDataDB count... \(guidedDataDB.count)")
            
            self.arrGuidedList.removeAll()
            
            var jsonString: [String: Any] = [:]
            var jsonEmotionsString: [String: Any] = [:]
            var jsonEmotions: [[String: Any]] = []
            var jsonAudiosString: [String: Any] = [:]
            var jsonAudios: [[String: Any]] = []
            
            for dict in guidedDataDB {
                
                if (dict as AnyObject).meditation_type as? String == "practical"{
                    if (dict as AnyObject).intro_completed{
                        self.appPreference.setPracticalChallenge(value: true)
                    }
                }
                
                if (dict as AnyObject).meditation_type as? String == "spiritual"{
                    if (dict as AnyObject).intro_completed{
                        self.appPreference.setSpiritualChallenge(value: true)
                    }
                }
                
                jsonString["id"] = Int((dict as AnyObject).guided_id ?? "0")
                jsonString["name"] = (dict as AnyObject).guided_name as? String
                jsonString["meditation_type"] = (dict as AnyObject).meditation_type as? String
                jsonString["mode"] = (dict as AnyObject).guided_mode as? String
                jsonString["min_limit"] = (dict as AnyObject).min_limit as? String ?? "95"
                jsonString["max_limit"] = (dict as AnyObject).max_limit as? String ?? "98"
                jsonString["meditation_key"] = (dict as AnyObject).meditation_key as? String ?? "practical"
                jsonString["complete_count"] = (dict as AnyObject).complete_count as? String ?? "0"
                jsonString["intro_url"] = (dict as AnyObject).intro_url as? String ?? ""
                
                //to check if the database accept prac and spi 7 days challenge
                if (dict as AnyObject).guided_name as? String == "7 Days challenge"{
                    challenge7DayCount = challenge7DayCount + 1
                }
                
                let guidedEmotionsDataDB = WWMHelperClass.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).guided_id ?? "0", dbName: "DBGuidedEmotionsData", name: "guided_id")
                print("guidedEmotionsDataDB count... \(guidedEmotionsDataDB.count)")
                
                for dict1 in guidedEmotionsDataDB{
                    
                    //print("meditation_type... \((dict as AnyObject).meditation_type) intro_completed... \((dict1 as AnyObject).intro_completed) guided_name... \((dict1 as AnyObject).guided_name)")
                    
                    if (dict as AnyObject).meditation_type as? String == "practical"{
                        if (dict1 as AnyObject).intro_completed{
                            self.appPreference.setPracticalChallenge(value: true)
                        }
                    }
                    
                    if (dict as AnyObject).meditation_type as? String == "spiritual"{
                        if (dict1 as AnyObject).intro_completed{
                            self.appPreference.setSpiritualChallenge(value: true)
                        }
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
                    jsonEmotionsString["intro_url"] = (dict1 as AnyObject).intro_url ?? ""
                    jsonEmotionsString["emotion_type"] = (dict1 as AnyObject).emotion_type ?? ""
                    
                    let guidedAudiosDataDB = WWMHelperClass.fetchGuidedFilterAudiosDB(emotion_id: (dict1 as AnyObject).emotion_id ?? "0", dbName: "DBGuidedAudioData")
                    print("guidedAudiosDataDB count... \(guidedAudiosDataDB.count) \(guidedEmotionsDataDB.count)")
                    
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
            
            WWMHelperClass.challenge7DayCount = self.challenge7DayCount
            print("self.typeTitle+++ \(self.typeTitle)")
            
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
                    
                    if let result = result["result"] as? [[String:Any]] {
                        
                        print("audioList... \(result)")
                        
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
                        
                        for dict in result {
                            
                            if let meditation_list = dict["meditation_list"] as? [[String: Any]]{
                                
                                for meditationList in meditation_list {
                                    let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                                    
                                    let timeInterval = Int(Date().timeIntervalSince1970)
                                    
                                    dbGuidedData.last_time_stamp = "\(timeInterval)"
                                    dbGuidedData.cat_name = dict["name"] as? String
                                    
                                    if let id = meditationList["id"]{
                                        dbGuidedData.guided_id = "\(id)"
                                    }
                                    
                                    if let name = meditationList["name"] as? String{
                                        dbGuidedData.guided_name = name
                                    }
                                    
                                    if let meditation_type = meditationList["meditation_type"] as? String{
                                        dbGuidedData.meditation_type = meditation_type
                                    }
                                    
                                    if let guided_mode = meditationList["mode"] as? String{
                                        dbGuidedData.guided_mode = guided_mode
                                    }
                                    
                                    if let min_limit = meditationList["min_limit"] as? String{
                                        dbGuidedData.min_limit = min_limit
                                    }else{
                                        dbGuidedData.min_limit = "95"
                                    }
                                    
                                    if let max_limit = meditationList["max_limit"] as? String{
                                        dbGuidedData.max_limit = max_limit
                                    }else{
                                        dbGuidedData.max_limit = "98"
                                    }
                                    
                                    if let meditation_key = meditationList["meditation_key"] as? String{
                                        dbGuidedData.meditation_key = meditation_key
                                    }else{
                                        if let meditation_type = dict["meditation_type"] as? String{
                                            dbGuidedData.meditation_key = meditation_type
                                        }
                                    }
                                    
                                    if let complete_count = meditationList["complete_count"] as? Int{
                                        dbGuidedData.complete_count = "\(complete_count)"
                                    }else{
                                        dbGuidedData.complete_count = "0"
                                    }
                                    
                                    if let intro_url = meditationList["intro_url"] as? String{
                                        dbGuidedData.intro_url = intro_url
                                    }else{
                                        dbGuidedData.intro_url = ""
                                    }
                                    
                                    if let intro_completed = meditationList["intro_completed"] as? Bool{
                                        dbGuidedData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedData.intro_completed = false
                                    }
                                    
                                    //print("dbGuidedData.last_time_stamp \(dbGuidedData.last_time_stamp) dbGuidedData.cat_name \(dbGuidedData.cat_name) dbGuidedData.guided_name \(dbGuidedData.guided_name) dbGuidedData.meditation_type \(dbGuidedData.meditation_type) dbGuidedData.guided_mode \(dbGuidedData.guided_mode) dbGuidedData.min_limit \(dbGuidedData.min_limit) dbGuidedData.max_limit \(dbGuidedData.max_limit) dbGuidedData.meditation_key \(dbGuidedData.meditation_key) dbGuidedData.complete_count \(dbGuidedData.complete_count) dbGuidedData.intro_url \(dbGuidedData.intro_url)")
                                    
                                    if let emotion_list = meditationList["emotion_list"] as? [[String: Any]]{
                                        for emotionsDict in emotion_list {
                                            
                                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                            
                                            if let id = meditationList["id"]{
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
                                            
                                            if let intro_url = emotionsDict["intro_url"] as? String{
                                                dbGuidedEmotionsData.intro_url = intro_url
                                            }else{
                                                dbGuidedEmotionsData.intro_url = ""
                                            }
                                            
                                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                                dbGuidedEmotionsData.emotion_type = emotion_type
                                            }else{
                                                dbGuidedEmotionsData.emotion_type = ""
                                            }
                                            
                                            //print("dbGuidedEmotionsData.guided_id \(dbGuidedEmotionsData.guided_id) dbGuidedEmotionsData.emotion_id \(dbGuidedEmotionsData.emotion_id) dbGuidedEmotionsData.author_name  \(dbGuidedEmotionsData.author_name ) dbGuidedEmotionsData.emotion_image \(dbGuidedEmotionsData.emotion_image) dbGuidedEmotionsData.emotion_name \(dbGuidedEmotionsData.emotion_name) dbGuidedEmotionsData.intro_completed \(dbGuidedEmotionsData.intro_completed) dbGuidedEmotionsData.tile_type \(dbGuidedEmotionsData.tile_type) dbGuidedEmotionsData.emotion_key \(dbGuidedEmotionsData.emotion_key) dbGuidedEmotionsData.emotion_body \(dbGuidedEmotionsData.emotion_body) dbGuidedEmotionsData.completed  \(dbGuidedEmotionsData.completed) dbGuidedEmotionsData.completed_date \(dbGuidedEmotionsData.completed_date)  dbGuidedEmotionsData.intro_url \(dbGuidedEmotionsData.intro_url)")
                                            
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
                                                    
                                                    //print("dbGuidedAudioData.emotion_id \(dbGuidedAudioData.emotion_id) dbGuidedAudioData.audio_id \(dbGuidedAudioData.audio_id) dbGuidedAudioData.audio_image \(dbGuidedAudioData.audio_image) dbGuidedAudioData.audio_name \(dbGuidedAudioData.audio_name) dbGuidedAudioData.audio_url \(dbGuidedAudioData.audio_url) dbGuidedAudioData.author_name \(dbGuidedAudioData.author_name) dbGuidedAudioData.duration \(dbGuidedAudioData.duration) dbGuidedAudioData.paid \(dbGuidedAudioData.paid) dbGuidedAudioData.vote \(dbGuidedAudioData.vote)")
                                                    
                                                    WWMHelperClass.saveDb()
                                                }
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                            
                                        }
                                    }
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
}
