//
//  WWMTabBarVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import Lottie
import CoreLocation

class WWMTabBarVC: UITabBarController,UITabBarControllerDelegate,CLLocationManagerDelegate {

    let layerGradient = CAGradientLayer()
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var city = ""
    var country = ""
    var lat = ""
    var long = ""
    let appPreffrence = WWMAppPreference()
    let reachable = Reachabilities()
    
    var alertPopupView = WWMAlertController()
    var alertPopupView1 = WWMAlertController()
    
    var isGetProfileCall = false
    
    var alertPopup = WWMAlertPopUp()
    var milestoneType: String = ""
    
    var product_id: String = ""
    var responseArray: [[String: Any]] = []
    var date_time: Any?
    var transaction_id: Any?
    
    //community
    var strMonthYear = ""
    var communityData = WWMCommunityData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restoreValue = KUSERDEFAULTS.string(forKey: "restore"){
            print("restore.... \(restoreValue)")
            if restoreValue == "1"{
                self.showToast(message: KRESTOREMSG)
                KUSERDEFAULTS.set("0", forKey: "restore")
            }
        }
        
        //community
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: Date())
        
        DispatchQueue.global(qos: .background).async {
            self.getDictionaryAPI()
            self.meditationHistoryListAPI()
        }
        
        self.delegate = self
        setupView()
        
        if !reachable.isConnectedToNetwork() {
            if self.appPreffrence.isLogout() {
                
                var userData = WWMUserData()
                userData = WWMUserData.init(json: self.appPreffrence.getUserData())
                print(userData)
                
                let userData1 = self.appPreffrence.getUserData()
            
                self.lat = userData1["latitude"] as? String ?? ""
                self.long = userData1["longitude"] as? String ?? ""
                self.city = userData1["city"] as? String ?? ""
                self.country = userData1["country"] as? String ?? ""
                
                self.getUserProfileData(lat: self.lat, long: self.long)
            }else {
                self.connectionLost()
            }
        }else {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.requestWhenInUseAuthorization()
            locManager.startUpdatingLocation()
            
            
            
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("loction permission not access")
                    
                    self.appPreffrence.setLoctionDenied(value: "Location Disable")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    
                    self.appPreffrence.setLoctionDenied(value: "Location Enable")
                }
            } else {
                self.appPreffrence.setLoctionDenied(value: "Location Disable")
                print("Location services are not enabled")
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         currentLocation = locations[0]
        self.appPreffrence.setLoctionDenied(value: "Location Enable")
        if self.lat == "" {
            getCityAndCountry()
        }
        
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if self.appPreffrence.isLogout() {
            self.appPreffrence.setLoctionDenied(value: "Location Disable")
            var userData = WWMUserData()
            userData = WWMUserData.init(json: self.appPreffrence.getUserData())
            print(userData)
            self.lat = userData.latitude
            self.long = userData.longitude
            city = userData.city
            country = userData.country
        }
        
        getUserProfileData(lat: self.lat, long: self.long)
    }
    
    func getCityAndCountry() {
        self.lat = "\(currentLocation.coordinate.latitude)"
        self.long = "\(currentLocation.coordinate.longitude)"
        let geoCoder = CLGeocoder()
        //let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else {
                    if self.appPreffrence.isLogout() {
                        
                        var userData = WWMUserData()
                        userData = WWMUserData.init(json: self.appPreffrence.getUserData())
                        print(userData)
                        
                        let userData1 = self.appPreffrence.getUserData()
                        
//                        self.lat = userData.latitude
//                        self.long = userData.longitude
//                        self.city = userData.city
//                        self.country = userData.country
                        
                        self.lat = userData1["latitude"] as? String ?? ""
                        self.long = userData1["longitude"] as? String ?? ""
                        self.city = userData1["city"] as? String ?? ""
                        self.country = userData1["country"] as? String ?? ""
                        
                        
                        print("lat.. \(self.lat) long... \(self.long) city.. \(self.city) country... \(self.country)")
                    }
                    
                    self.getUserProfileData(lat: self.lat, long: self.long)
                    return
                }
                
                
                // Location name
                if let locationName = placeMark.location {
                    print(locationName)
                }
                // Street address
                if let street = placeMark.thoroughfare {
                    print(street)
                }
                // City
                if let cityPlace = placeMark.subAdministrativeArea {
                    self.city = cityPlace
                    print(self.city)
                }
                // Zip code
                if let zip = placeMark.isoCountryCode {
                    print(zip)
                }
                // Country
                if let countryPlace = placeMark.country {
                    self.country = countryPlace
                    print(self.country)
                }
                
                
                print("lat.. \(self.lat) long... \(self.long)")
                
                self.getUserProfileData(lat: self.lat, long: self.long)
        })
    }
    
    
    func setupView() {
        
        WWMHelperClass.selectedType = ""
        
        if self.appPreffrence.getType() == "timer"{
            self.viewControllers?.remove(at: 3)
            self.viewControllers?.remove(at: 3)
            
        }else if self.appPreffrence.getType() == "guided"{
            self.viewControllers?.remove(at: 2)
            self.viewControllers?.remove(at: 3)
        }else if self.appPreffrence.getType() == "learn"{
            WWMHelperClass.selectedType = "learn"
            self.viewControllers?.remove(at: 2)
            self.viewControllers?.remove(at: 2)
        }else {
            self.viewControllers?.remove(at: 3)
            self.viewControllers?.remove(at: 3)
        }
        
        if self.milestoneType == "hours_meditate"{
            WWMHelperClass.milestoneType = "hours_meditate"
            self.selectedIndex = 4
        }else if self.milestoneType == "consecutive_days"{
            WWMHelperClass.milestoneType = "consecutive_days"
            self.selectedIndex = 4
        }else if self.milestoneType == "sessions"{
            WWMHelperClass.milestoneType = "sessions"
            self.selectedIndex = 4
        }else{
            self.selectedIndex = 2
        }
        
        layerGradient.colors = [UIColor.init(hexString: "#5732a3")!.cgColor, UIColor.init(hexString: "#001252")!.cgColor]
        layerGradient.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 84)
        self.tabBar.layer.insertSublayer(layerGradient, at: 0)
        for index in 0..<5 {
            let item = self.tabBar.items?[index]
            item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if index == self.selectedIndex {
                
                item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
    }
    
    func setDataToDb(json:[String:Any]) {
        
        print("database setting.... \(json)")
        var arrMeditationData = [WWMMeditationData]()
        if let dataMeditation = json["meditation_data"] as? [[String:Any]]{
            for dict in dataMeditation {
                let data = WWMMeditationData.init(json: dict)
                arrMeditationData.append(data)
            }
        }
        
        if arrMeditationData.count > 0{
            let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
            if data.count > 0 {
                WWMHelperClass.deletefromDb(dbName: "DBSettings")
            }
            let settingDB = WWMHelperClass.fetchEntity(dbName: "DBSettings") as! DBSettings
            
            settingDB.startChime = json["startChime"] as? String ?? ""
            settingDB.ambientChime = json["ambientSound"] as? String ?? ""
            settingDB.endChime = json["endChime"] as? String ?? ""
            settingDB.finishChime = json["finishChime"] as? String ?? ""
            settingDB.intervalChime = json["intervalChime"] as? String ?? ""
            settingDB.isAfterNoonReminder = json["IsAfternoonReminder"] as? Bool ?? false
            settingDB.isMilestoneAndRewards = json["IsMilestoneAndRewards"] as? Bool ?? false
            settingDB.isMorningReminder = json["IsMorningReminder"] as? Bool ?? false
            settingDB.moodMeterEnable = json["moodMeterEnable"] as? Bool ?? false
            settingDB.morningReminderTime = json["MorningReminderTime"] as? String ?? ""
            settingDB.afterNoonReminderTime = json["AfternoonReminderTime"] as? String ?? ""
            settingDB.learnReminderTime = json["LearnReminderTime"] as? String ?? ""
            settingDB.isLearnReminder = json["IsLearnReminder"] as? Bool ?? false
            settingDB.mantraID = json["MantraID"] as? Int ?? 1
            
            settingDB.prepTime = "10"
            settingDB.meditationTime = "90"
            settingDB.restTime = "20"
            
            
            for  index in 0..<arrMeditationData.count {
                let dataM = arrMeditationData[index]
                let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationData") as! DBMeditationData
                meditationDB.meditationId = Int32(dataM.meditationId)
                meditationDB.setmyown = Int32(dataM.setmyown)
                meditationDB.meditationName = dataM.meditationName
                meditationDB.isMeditationSelected = dataM.isSelected
                
                for  index in 0..<dataM.levels.count {
                    let dic = dataM.levels[index]
                    let levelDB = WWMHelperClass.fetchEntity(dbName: "DBLevelData") as! DBLevelData
                    levelDB.isLevelSelected = dic.isSelected
                    if dic.isSelected {
                        settingDB.prepTime = "\(dic.prepTime)"
                        settingDB.meditationTime = "\(dic.meditationTime)"
                        settingDB.restTime = "\(dic.restTime)"
                    }
                    levelDB.levelId = Int32(dic.levelId)
                    levelDB.levelName = dic.levelName
                    levelDB.prepTime = Int32(dic.prepTime) ?? 0
                    levelDB.meditationTime = Int32(dic.meditationTime) ?? 0
                    levelDB.restTime = Int32(dic.restTime) ?? 0
                    levelDB.minPrep = Int32(dic.minPrep) ?? 1
                    levelDB.minRest = Int32(dic.minRest) ?? 0
                    levelDB.minMeditation = Int32(dic.minMeditation) ?? 0
                    levelDB.maxPrep = Int32(dic.maxPrep) ?? 0
                    levelDB.maxRest = Int32(dic.maxRest) ?? 0
                    levelDB.maxMeditation = Int32(dic.maxMeditation) ?? 0
                    meditationDB.addToLevels(levelDB)
                }
                settingDB.addToMeditationData(meditationDB)
            }
            WWMHelperClass.saveDb()
            NotificationCenter.default.post(name: NSNotification.Name.init("GETSettingData"), object: nil)
            
        }else {
            self.getDataFromDatabase()
        }
    }
    
    //GET dictionary api
    //MARK: API call
    func getDictionaryAPI() {
                
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_DICTIONARY, context: "URL_DICTIONARY", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                print("get dictionary result... \(result)")
                
                //community data*
                if let communtiyTimeStamp = result["guidedData"]{
                    self.fetchCommunityDataFromDB(time_stamp: communtiyTimeStamp)
                }
                
                //wisdom data*
                if let combinedMantra = result["combinedMantra"]{
                    self.fetchWisdomDataFromDB(time_stamp: combinedMantra)
                    
                }
                
                //guided data*
                if let guidedData = result["guidedData"]{
                    self.fetchGuidedDataFromDB(time_stamp: guidedData)
                }
                
                //steps data*
                if let steps = result["steps"]{
                    self.fetchStepsDataFromDB(time_stamp: steps)
                }
                
                //mantras data*
                 if let mantras = result["mantras"]{
                    self.fetchMantrasDataFromDB(time_stamp: mantras)
                }
                
                //getVibesImages data*
                if let getVibesImages = result["getVibesImages"]{
                    self.fetchGetVibesDataFromDB(time_stamp: getVibesImages)
                }
                
                //stepFaq*
                if let stepFaq = result["stepFaq"]{
                    self.appPreffrence.setStepFAQTimeStamp(value: stepFaq)
                    
                }
                
                print("success tabbarVC getdictionaryapi in background thread")
            }
        }
    }
    
    //MARK: Fetch Guided Data From DB
    func fetchGuidedDataFromDB(time_stamp: Any) {
        let getGuidedDataDB = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
        if getGuidedDataDB.count > 0 {
            
            for dict in getGuidedDataDB {
                                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let currentDateString = dateFormatter.string(from: Date())
                let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                let apiTimeStamp: String = "\(time_stamp)"

                 print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.getGuidedListAPI()
                }
            }
        }else{
            self.getGuidedListAPI()
        }
    }
    
    func getGuidedListAPI() {

        let param = ["user_id":self.appPreffrence.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMGuidedAudioListVC Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success result... \(result)")
                    
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
                            
                            if let emotion_list = guidedDict["emotion_list"] as? [[String: Any]]{
                                for emotionsDict in emotion_list {
                                    
                                    let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                    
                                    if let id = guidedDict["id"]{
                                        dbGuidedEmotionsData.guided_id = "\(id)"
                                    }
                                    
                                    if let emotion_id = emotionsDict["emotion_id"]{
                                        dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                    }
                                    
                                    if let emotion_image = emotionsDict["emotion_image"] as? String{
                                        dbGuidedEmotionsData.emotion_image = emotion_image
                                    }
                                    
                                    if let emotion_name = emotionsDict["emotion_name"] as? String{
                                        dbGuidedEmotionsData.emotion_name = emotion_name
                                    }
                                    
                                    if let tile_type = emotionsDict["tile_type"] as? String{
                                        dbGuidedEmotionsData.tile_type = tile_type
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
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuided"), object: nil)
                        print("guided data tabbarvc in background thread...")
                    }
                }
            }
        }
    }//end guided api*
    
    
    //MARK: Fetch Steps Data From DB
    func fetchStepsDataFromDB(time_stamp: Any) {
           let getStepsDataDB = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
           if getStepsDataDB.count > 0 {
               
               for dict in getStepsDataDB {
                                   
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                   let currentDateString = dateFormatter.string(from: Date())
                   let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                   let apiTimeStamp: String = "\(time_stamp)"

                    print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                   
                   let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                   let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                   
                   print("date1... \(systemDate) date2... \(apiDate)")
                   if systemDate < apiDate{
                       self.getLearnSetpsAPI()
                   }
               }
           }else{
               self.getLearnSetpsAPI()
           }
       }

    
    //MARK: getLearnSetps API call
    func getLearnSetpsAPI() {
        
        //self.learnStepsListData.removeAll()
        let param = ["user_id": self.appPreffrence.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STEPS, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            print("learn result... \(result)")
            if let _ = result["success"] as? Bool {
                if let total_paid = result["total_paid"] as? Double{
                    print("total_paid double.. \(total_paid)")
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    
                    print("GetLearnSetpsAPI count... \(data.count)")
                    
                    let getStepsData = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                    if getStepsData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBSteps")
                    }
                    
                    for dict in data{
                        
                        let dbStepsData = WWMHelperClass.fetchEntity(dbName: "DBSteps") as! DBSteps
                            
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        print("timeInterval.... \(timeInterval)")
                        
                        
                        dbStepsData.last_time_stamp = "\(timeInterval)"
                        
                        if let completed = dict["completed"] as? Bool{
                            dbStepsData.completed = completed
                        }
                        
                        if let date_completed = dict["date_completed"] as? String{
                            dbStepsData.date_completed = date_completed
                        }
                        
                        if let description = dict["description"] as? String{
                            dbStepsData.description1 = description
                        }
                        
                        if let id = dict["id"]{
                            dbStepsData.id = "\(id)"
                        }
                        
                        if let outro_audio = dict["outro_audio"] as? String{
                            dbStepsData.outro_audio = outro_audio
                        }
                        
                        if let step_audio = dict["step_audio"] as? String{
                            dbStepsData.step_audio = step_audio
                        }
                        
                        if let step_name = dict["step_name"] as? String{
                            dbStepsData.step_name = step_name
                        }
                        
                        if let timer_audio = dict["timer_audio"] as? String{
                            dbStepsData.timer_audio = timer_audio
                        }
                        
                        if let title = dict["title"] as? String{
                            dbStepsData.title = title
                        }
                        
                        WWMHelperClass.saveDb()
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationLearnSteps"), object: nil)
                }
            }
        }
    }
    
    
    //MARK: Fetch Get Vibes Data From DB
    
    func fetchGetVibesDataFromDB(time_stamp: Any) {
        let getVibesDataDB = WWMHelperClass.fetchDB(dbName: "DBGetVibesImages") as! [DBGetVibesImages]
        if getVibesDataDB.count > 0 {
            
            for dict in getVibesDataDB {
                                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let currentDateString = dateFormatter.string(from: Date())
                let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                let apiTimeStamp: String = "\(time_stamp)"

                 print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.getVibesAPI()
                }
            }
        }else{
            self.getVibesAPI()
        }
    }
    
    func getVibesAPI() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETVIBESIMAGES, context: "WWMMoodShareVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("result getVibesAPI... \(result)")
                    print("GetVibesAPI tabbarvc in background thread...")
                    
                    if let data = result["data"] as? [[String: Any]]{
                        
                        print("GetVibesAPI count... \(data.count)")
                        
                        let getVibesData = WWMHelperClass.fetchDB(dbName: "DBGetVibesImages") as! [DBGetVibesImages]
                        if getVibesData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGetVibesImages")
                        }
                        
                        for dict in data {
                            
                            if let images = dict["images"] as? [String]{
                                if images.count > 0{
                                    for i in 0..<images.count{
                                        let dbGetVibesData = WWMHelperClass.fetchEntity(dbName: "DBGetVibesImages") as! DBGetVibesImages
                                            
                                        let timeInterval = Int(Date().timeIntervalSince1970)
                                        print("timeInterval.... \(timeInterval)")
                                        
                                        dbGetVibesData.images = images[i]
                                        
                                        dbGetVibesData.last_time_stamp = "\(timeInterval)"
                                        
                                        if let id = dict["mood_id"]{
                                            dbGetVibesData.mood_id = "\(id)"
                                        }
                                        
                                        WWMHelperClass.saveDb()
                                        
                                    }//end images array
                                }
                            }
                        }
                    }
                }
            }
        }
    }//end getVibesAPI
    
    
    //MARK: Fetch Community Data From DB
    
    func fetchCommunityDataFromDB(time_stamp: Any) {
        let comunityDataDB = WWMHelperClass.fetchDB(dbName: "DBCommunityData") as! [DBCommunityData]
        if comunityDataDB.count > 0 {
            
            for dict in comunityDataDB {
                
                //let dbCommunityData = WWMHelperClass.fetchEntity(dbName: "DBCommunityData") as! DBCommunityData
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let currentDateString = dateFormatter.string(from: Date())
                let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                let apiTimeStamp: String = "\(time_stamp)"

                 print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.getCommunityAPI()
                }
            }
        }else{
            self.getCommunityAPI()
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK: Community api
    func getCommunityAPI() {

        let param = [
            "user_Id":self.appPreffrence.getUserID(),
            "month":self.strMonthYear
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMMUNITYDATA, context: "WWMCommunityVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                let comunityData = WWMHelperClass.fetchDB(dbName: "DBCommunityData") as! [DBCommunityData]
                if comunityData.count > 0 {
                    WWMHelperClass.deletefromDb(dbName: "DBCommunityData")
                }
                
                let dbCommunityData = WWMHelperClass.fetchEntity(dbName: "DBCommunityData") as! DBCommunityData
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: result["result"] as! [String : Any], options:.prettyPrinted)
                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                dbCommunityData.data = myString
                
                let timeInterval = Int(Date().timeIntervalSince1970)
                print("timeInterval.... \(timeInterval)")
                
                dbCommunityData.last_time_stamp = "\(timeInterval)"
                
                WWMHelperClass.saveDb()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationCommunity"), object: nil)
                print("success tabbarVC getcommunity in background thread")
            }
        }
    }
    
    //get mantras
    
    func fetchMantrasDataFromDB(time_stamp: Any) {
            let mantrasDataDB = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
            if mantrasDataDB.count > 0 {
                
                for dict in mantrasDataDB {
                                
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    let currentDateString = dateFormatter.string(from: Date())
                    let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                    let apiTimeStamp: String = "\(time_stamp)"

                     print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                    
                    let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                    let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                    
                    print("date1... \(systemDate) date2... \(apiDate)")
                    if systemDate < apiDate{
                        self.getMantrasAPI()
                    }
                }
            }else{
                self.getMantrasAPI()
            }
            
        }
        
        func getMantrasAPI() {
            
            WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_MANTRAS, context: "WWMListenMantraVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    
                    if let data = result["data"] as? [[String: Any]]{
                        
                        let mantrasData = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
                        if mantrasData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBMantras")
                        }
                        
                        for dict in data{
                            
                            print("mantras result... \(result)")
                            let dbMantrasData = WWMHelperClass.fetchEntity(dbName: "DBMantras") as! DBMantras
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                            let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                            dbMantrasData.data = myString
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            print("timeInterval.... \(timeInterval)")
                            
                            dbMantrasData.last_time_stamp = "\(timeInterval)"
                            
                            WWMHelperClass.saveDb()
                            
                        }
                    }
                    print("success tabbarvc getmantras api in background")
                }
            }
        }
    
    //get wisdom api
    func fetchWisdomDataFromDB(time_stamp: Any) {
        let wisdomDataDB = WWMHelperClass.fetchDB(dbName: "DBWisdomData") as! [DBWisdomData]
        let wisdomVideoData = WWMHelperClass.fetchDB(dbName: "DBWisdomVideoData") as! [DBWisdomVideoData]
        if wisdomDataDB.count > 0 {
            print("wisdomDataDB.. \(wisdomDataDB.count)")
            print("wisdomVideoData.. \(wisdomVideoData.count)")
            
            for dict in wisdomDataDB {
                            
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let currentDateString = dateFormatter.string(from: Date())
                let systemTimeStamp: String = dict.last_time_stamp ?? currentDateString
                let apiTimeStamp: String = "\(time_stamp)"

                 print("dict.last_time_stamp... \(dict.last_time_stamp!) systemTimeStamp.... \(systemTimeStamp) apiTimeStamp... \(apiTimeStamp)")
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.getWisdomAPI()
                }
            }
        }else{
            self.getWisdomAPI()
        }
        
    }
    
    func getWisdomAPI() {
        
        let param = ["user_id":self.appPreffrence.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETWISDOM, context: "WWMWisdomNavVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    
                    print("success getWisdomAPI \(result)")
                    if let wisdomList = result["result"] as? [[String:Any]] {
                        
                        let wisdomData = WWMHelperClass.fetchDB(dbName: "DBWisdomData") as! [DBWisdomData]
                        if wisdomData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBWisdomData")
                        }
                        
                        let wisdomVideoData = WWMHelperClass.fetchDB(dbName: "DBWisdomVideoData") as! [DBWisdomVideoData]
                        if wisdomVideoData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBWisdomVideoData")
                        }
                        
                        for dict in wisdomList {
                            var wisdom_id: Int = 0
                            print("wisdom result... \(result)")
                            let dbWisdomData = WWMHelperClass.fetchEntity(dbName: "DBWisdomData") as! DBWisdomData
                        
                            if let id = dict["id"]{
                                dbWisdomData.id = "\(id)"
                                wisdom_id = id as? Int ?? 0
                            }
                            if let name = dict["name"] as? String{
                                dbWisdomData.name = name
                            }
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            print("timeInterval.... \(timeInterval)")
                            
                            dbWisdomData.last_time_stamp = "\(timeInterval)"
                            
                            if let video_list = dict["video_list"] as? [[String: Any]]{
                                for dict1 in video_list{
                                    let dbWisdomVideoData = WWMHelperClass.fetchEntity(dbName: "DBWisdomVideoData") as! DBWisdomVideoData
                                    
                                    if let id = dict1["id"]{
                                        dbWisdomVideoData.video_id = "\(id)"
                                    }
                                    if let duration = dict1["duration"] as? String{
                                        dbWisdomVideoData.video_duration = duration
                                    }
                                    if let name = dict1["name"] as? String{
                                        dbWisdomVideoData.video_name = name
                                    }
                                    if let poster_image = dict1["poster_image"] as? String{
                                        dbWisdomVideoData.video_img = poster_image
                                    }
                                    if let video_url = dict1["video_url"] as? String{
                                        dbWisdomVideoData.video_url = video_url
                                    }
                                    
                                    if let vote = dict1["vote"] as? Bool{
                                        dbWisdomVideoData.video_vote = vote
                                    }

                                    dbWisdomVideoData.wisdom_id = "\(wisdom_id)"
                                    WWMHelperClass.saveDb()
                                    print("wisdomVideoData.count... \(wisdomVideoData.count)")
                                }
                            }
                            
                            WWMHelperClass.saveDb()
                        }
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationWisdom"), object: nil)
                        print("wisdomData tabbarvc in background thread...")
                    }
                }
            }
        }
    }


    
    //MeditationHistoryList API
    func meditationHistoryListAPI() {
        
        let param = ["user_id": self.appPreffrence.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONHISTORY+"?page=1", context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [String: Any]{
                    if let records = data["records"] as? [[String: Any]]{
                        
                        let meditationHistoryData = WWMHelperClass.fetchDB(dbName: "DBMeditationHistory") as! [DBMeditationHistory]
                        if meditationHistoryData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBMeditationHistory")
                        }
                        
                        for dict in records{
                            let dbMeditationHistory = WWMHelperClass.fetchEntity(dbName: "DBMeditationHistory") as! DBMeditationHistory
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                            let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                            dbMeditationHistory.data = myString
                            WWMHelperClass.saveDb()
                            
                        }
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationMeditationHistory"), object: nil)
                print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result)")
                print("success tabbarVC meditationhistoryapi in background thread")
            }
        }
    }
    

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        for itemTab in  self.tabBar.items!{
            
            itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if itemTab == item {
                
                //itemTab.selectedImage = UIImage.gifImageWithName("Home_White_1")
                
                itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
    }
    
    func getUserProfileData(lat: String, long: String) {
        if self.appPreffrence.getGetProfile(){
            WWMHelperClass.showLoaderAnimate(on: self.view)
            self.getProfileDataInBackground(lat: self.lat, long: self.long)
        }else{
            DispatchQueue.global(qos: .background).async {
                self.getProfileDataInBackground(lat: self.lat, long: self.long)
            }
        }
    }
    
    func getProfileDataInBackground(lat: String, long: String){
        if !isGetProfileCall {
            isGetProfileCall = true
        let param = [
            "user_id":self.appPreffrence.getUserID(),
            "lat": lat,
            "long": long,
            "city":city,
            "country":country
            ] as [String : Any]
            
        print("param... \(param)")
            
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETPROFILE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    if success {
                        
                        WWMHelperClass.hideLoaderAnimate(on: self.view)
                        
                        var userData = WWMUserData.sharedInstance
                        userData = WWMUserData.init(json: result["user_profile"] as! [String : Any])

                        
                        print("userData****** \(userData) result****** \(result) userprofile....\(result["user_profile"] as! [String : Any])")
                        
                        var userSubscription = WWMUserData.sharedInstance
                        userSubscription = WWMUserData.init(subscriptionJson: result["subscription"] as! [String : Any])
                        
                        self.appPreffrence.setGetProfile(value: false)
                        self.appPreffrence.setHomePageURL(value: result["home_page_url"] as! String)
                        self.appPreffrence.setLearnPageURL(value: result["learn_page_url"] as! String)
                        self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
                        self.appPreffrence.setUserSubscription(value: result["subscription"] as! [String : Any])
                        
                        self.appPreffrence.setOffers(value: result["offers"] as! [String])
                
                        
                        if let userProfile = result["user_profile"] as? [String : Any]{
                            self.appPreffrence.setUserName(value:  userProfile["name"] as? String ?? "")
                        }
                        
                        self.appPreffrence.setSessionAvailableData(value: result["session_available"] as? Bool ?? false)
                        
                        
                        print("getPreMoodBool.... \(self.appPreffrence.getPrePostJournalBool()) userSubscription.expiry_date... \(userSubscription.expiry_date)")
                        
                        self.appPreffrence.SetExpireDateBackend(value: userSubscription.expiry_date)

                        let difference = WWMHelperClass.dateComparison(expiryDate: userSubscription.expiry_date)

                        self.appPreffrence.setExpiryDate(value: false)
                        
                        if difference == 1{
                            if !self.appPreffrence.getPrePostJournalBool(){
                                
                                self.appPreffrence.setPrePostJournalBool(value: true)
                                
                                print("premood.. \(userSubscription.preMood) postmood.. \(userSubscription.postMood) prejouranl.. \(userSubscription.preJournal) postjoural.. \(userSubscription.postJournal)")
                                
                                self.appPreffrence.setPostMoodCount(value: 6)
                                self.appPreffrence.setPreMoodCount(value: 6)
                                self.appPreffrence.setPreJournalCount(value: 6)
                                self.appPreffrence.setPostJournalCount(value: 6)
                            }
                        }else{
                            self.appPreffrence.setExpiryDate(value: true)
                        }
                        
                        self.setDataToDb(json: result["settings"] as! [String:Any])
                        
                        
                        //*receiptValidation
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        
                        if let expiryDate = self.appPreffrence.getExpireDateBackend() as? String{
                            if expiryDate != ""{
                                print("self.appPreffrence.getExpiryDate... \(expiryDate)")
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                
                                print("formatter.date... \(String(describing: formatter.date(from: expiryDate)))")
                                
                                let expireDate = formatter.date(from: expiryDate)!
                                
                                let currentDateString = formatter.string(from: Date())
                                let currentDate = formatter.date(from: currentDateString)!
                                
                                if currentDate > expireDate{
                                    print("currentDate is greater than expireDate")
                                    if self.appPreffrence.isLogin(){
                                        DispatchQueue.global(qos: .background).async {
                                            self.receiptValidation()
                                        }
                                    }
                                }
                            }
                        }
                        //receiptValidation*
                        
                    }else {
                        self.getDataFromDatabase()
                    }
                }else {
                    self.getDataFromDatabase()
                }
            }else {
                self.getDataFromDatabase()
            }
                WWMHelperClass.hideLoaderAnimate(on: self.view)
            }
        }
    }
    
    
    
    func receiptValidation() {
          
          let receiptFileURL = Bundle.main.appStoreReceiptURL
          let receiptData = try? Data(contentsOf: receiptFileURL!)
          if let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)){
              let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString as AnyObject, "password" : "ec9270a657eb4b3e877be4c92cf3f8c2" as AnyObject]
              
              do {
                  let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                  let verifyReceiptURL = kURL_INAPPS_RECEIPT
                  let storeURL = URL(string: verifyReceiptURL)!
                  var storeRequest = URLRequest(url: storeURL)
                  storeRequest.httpMethod = "POST"
                  storeRequest.httpBody = requestData
                  
                  let session = URLSession(configuration: URLSessionConfiguration.default)
                  let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                      
                      do {
                          let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                          print("=======>",jsonResponse)
                          if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
                            print("date... \(date)")
                            
                            if let expiryDate = self?.appPreffrence.getExpireDateBackend(){
                                if expiryDate != ""{
                                    print("self.appPreffrence.getExpiryDate... \(expiryDate)")
                                    
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    
                                    print("formatter.date... \(String(describing: formatter.date(from: expiryDate)))")
                                    
                                    let expireDate = formatter.date(from: expiryDate)!
                                    
                                    if date > expireDate{
                                        print("product_id... \(self?.product_id ?? "")")
                                        print("repurchased")
                                        self?.getSubscriptionPlanId()
                                    }else{
                                        print("expired")
                                    }
                                }
                            }
                        }
                      } catch let parseError {
                          print(parseError)
                      }
                  })
                  task.resume()
              } catch let parseError {
                  print(parseError)
              }
        }
    }
      
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
          
          if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
              
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
             
            if let product_id = lastReceipt["product_id"] as? String {
                self.product_id = product_id
            }
            
            if let purchase_date_ms = lastReceipt["purchase_date_ms"] {
                self.date_time = purchase_date_ms
            }
            
            if let transaction_id = lastReceipt["transaction_id"]{
                self.transaction_id = transaction_id
            }
            
            if let expiresDate = lastReceipt["purchase_date"] as? String {
                return formatter.date(from: expiresDate)
            }
              
              return nil
          }
          else {
              return nil
          }
      }
    
    
    func getSubscriptionPlanId(){
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETSUBSCRIPTIONPPLANS, context: "WWMUpgradeBeejaVC", headerType: kGETHeader, isUserToken: false) { (response, error, sucess) in
            if sucess {
                if let result = response["result"] as? [[String: Any]]{
                    self.responseArray = result
                   print("result.... \(result)")
                    
                    var getProductId: Bool = false
                    var plan_id: Int = 2
                    var subscriptionPlan: String = "annual"
                    var subscriptionAmount: Any?
                    
                    for i in 0..<self.responseArray.count{
                        if let dict = self.responseArray[i] as? [String: Any]{
                            if let product_id = dict["product_id"] as? String{
                                if self.product_id == product_id{
                                    self.product_id = product_id
                                    
                                    if let id = dict["id"] as? Int{
                                        plan_id = id
                                    }
                                    
                                    if let name = dict["name"] as? String{
                                        subscriptionPlan = name
                                    }
                                                                        
                                    if let cost = dict["cost"]{
                                        subscriptionAmount = cost
                                    }
                                                                        
                                    getProductId = true
                                    break
                                }
                            }
                        }
                    }
                    
                    if getProductId{
                                                
                        let param = [
                            "plan_id" : plan_id,
                            "user_id" : self.appPreffrence.getUserID(),
                            "subscription_plan" : subscriptionPlan,
                            "date_time" : self.date_time!,
                            "transaction_id" : self.transaction_id!,
                            "amount" : subscriptionAmount!
                            ] as [String : Any]
                        
                        print("param,,,,... \(param)")
                        self.subscriptionSucessAPI(param: param)
                    }
                }
            }
        }
    }
    
    func subscriptionSucessAPI(param : [String : Any]) {
        
        print("param.....###### \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SUBSCRIPTIONPURCHASE, context: "WWMUpgradeBeejaVC", headerType: kPOSTHeader, isUserToken: true) { (response, error, sucess) in
            if sucess {
                print("success.... upgrade beeja tab bar vc")
                print("lat...\(self.lat) long... \(self.long)")
                self.getUserProfileData(lat: self.lat, long: self.long)
            }
        }
    }
    
    
    func getDataFromDatabase() {
        if self.appPreffrence.isLogout() {
            var userData = WWMUserData.sharedInstance
            userData = WWMUserData.init(json: self.appPreffrence.getUserData())
            print(userData)
            let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
            if data.count > 0 {
                NotificationCenter.default.post(name: NSNotification.Name.init("GETSettingData"), object: nil)
            }else {
                self.connectionLost()
            }
            
        }else {
            self.connectionLost()
        }
    }
    
    func connectionLost(){
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = kAlertTitle
        alertPopupView.lblSubtitle.text = internetConnectionLostMsg
        alertPopupView.btnOK.setTitle(KRETRY, for: .normal)
        alertPopupView.btnClose.isHidden = true
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
        
        self.getUserProfileData(lat: self.lat, long: self.long)
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 160, y: self.view.frame.size.height/2, width: self.view.frame.size.width - 60, height: 100))
        toastLabel.backgroundColor = UIColor.white
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 8)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 8;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
