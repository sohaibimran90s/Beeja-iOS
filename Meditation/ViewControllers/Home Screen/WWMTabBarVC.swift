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
import FBSDKLoginKit
import GoogleSignIn

class WWMTabBarVC: ESTabBarController,UITabBarControllerDelegate,CLLocationManagerDelegate {

    let layerGradient = CAGradientLayer()
    var currentLocation: CLLocation?
    let locManager = CLLocationManager()
    var city = ""
    var country = ""
    var lat = ""
    var long = ""
    let appPreffrence = WWMAppPreference()
    let reachable = Reachabilities()
    
    var alertPopupView = WWMAlertController()
    
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
    
    var flagConnAlertShow = false
    var forceLogoutPopupView = WWMAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //print("logger*** \(Logger.shared.getLogContent())")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationVCCommunity = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCCommunity") as! UINavigationController//
        let navigationVCProgress = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCProgress") as! UINavigationController//
        let navigationVCWisdom = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCWisdom") as! UINavigationController//
        let navigationVCGuided = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCGuided") as! UINavigationController//
        let navigationVCTimer = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCTimer") as! UINavigationController//
        let navigationVCLearn = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCLearn") as! UINavigationController//
        let navigationVCHome = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCHome") as! UINavigationController//
        
        
        navigationVCHome.tabBarItem = ESTabBarItem.init(WWMHomeAnimateContentView(), title: "Home", image: nil, selectedImage: nil)
        navigationVCCommunity.tabBarItem = ESTabBarItem.init(WWMCommunityAnimateContentView(), title: "Community", image: nil, selectedImage: nil)
        navigationVCGuided.tabBarItem = ESTabBarItem.init(WWMGuideAnimateContentView(), title: "Guided", image: nil, selectedImage: nil)
        navigationVCTimer.tabBarItem = ESTabBarItem.init(WWMTimerAnimateContentView(), title: "Timer", image: nil, selectedImage: nil)
        let extractedExpr = WWMLearnAnimateContentView()
        navigationVCLearn.tabBarItem = ESTabBarItem.init(extractedExpr, title: "Learn", image: nil, selectedImage: nil)
        navigationVCWisdom.tabBarItem = ESTabBarItem.init(WWMWisdomAnimateContentView(), title: "Wisdom", image: nil, selectedImage: nil)
        navigationVCProgress.tabBarItem = ESTabBarItem.init(WWMProgressAnimateContentView(), title: "Progress", image: nil, selectedImage: nil)
        self.viewControllers = [navigationVCHome, navigationVCCommunity,navigationVCTimer,navigationVCGuided,navigationVCLearn, navigationVCWisdom, navigationVCProgress]
        
        if let restoreValue = KUSERDEFAULTS.string(forKey: "restore"){
            //print("restore.... \(restoreValue)")
            if restoreValue == "1"{
                KUSERDEFAULTS.set("0", forKey: "restore")
                self.showToast(message: KRESTOREMSG)
            }
        }
        
        //community
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: Date())
        
        DispatchQueue.global(qos: .background).async {
            
            self.forceLogoutAPI()
            self.getDictionaryAPI()
            self.meditationHistoryListAPI()
            self.meditationlistAPI()
        }
        
        self.delegate = self
        setupView()
        
        if !reachable.isConnectedToNetwork() {
            if self.appPreffrence.isLogout() {
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
                    //print("loction permission not access")
                    
                    self.appPreffrence.setLoctionDenied(value: "Location Disable")
                case .authorizedAlways, .authorizedWhenInUse:
                    //print("Access")
                    
                    self.appPreffrence.setLoctionDenied(value: "Location Enable")
                }
            } else {
                self.appPreffrence.setLoctionDenied(value: "Location Disable")
                //print("Location services are not enabled")
            }
        }
    }
    
    func setupTabBarSeparators() {
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))

        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5

        // iterate through the items in the Tab Bar, except the last one
        for i in 0...(self.tabBar.items!.count - 2) {
            // make a new separator at the end of each tab bar item
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height))

            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = UIColor.lightGray

            self.tabBar.addSubview(separator)
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
            //print(userData)
            self.lat = userData.latitude
            self.long = userData.longitude
            city = userData.city
            country = userData.country
        }
        
        getUserProfileData(lat: self.lat, long: self.long)
    }
    
    func getCityAndCountry() {
        self.lat = "\(currentLocation?.coordinate.latitude ?? 51.37661)"
        self.long = "\(currentLocation?.coordinate.longitude ?? -0.08230)"
        let geoCoder = CLGeocoder()
        //let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let defaultLoc = CLLocation.init(latitude: 51.37661, longitude: -0.08230)
        geoCoder.reverseGeocodeLocation(currentLocation ?? defaultLoc, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else {
                    if self.appPreffrence.isLogout() {
                        
                        let userData1 = self.appPreffrence.getUserData()
                        self.lat = userData1["latitude"] as? String ?? ""
                        self.long = userData1["longitude"] as? String ?? ""
                        self.city = userData1["city"] as? String ?? ""
                        self.country = userData1["country"] as? String ?? ""
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
                
                
                //print("lat.. \(self.lat) long... \(self.long)")
                
                self.getUserProfileData(lat: self.lat, long: self.long)
        })
    }
    
    func setupView() {
        
        if self.appPreffrence.getType() == "timer"{
            self.viewControllers?.remove(at: 3)
            self.viewControllers?.remove(at: 3)
            self.appPreffrence.setType(value: "timer")
            
        }else if self.appPreffrence.getType() == "guided"{
            self.viewControllers?.remove(at: 2)
            self.viewControllers?.remove(at: 3)
            self.appPreffrence.setType(value: "guided")

        }else if self.appPreffrence.getType() == "learn"{
            self.appPreffrence.setType(value: "learn")
            self.viewControllers?.remove(at: 2)
            self.viewControllers?.remove(at: 2)
        }else {
            self.viewControllers?.remove(at: 3)
            self.viewControllers?.remove(at: 3)
            self.appPreffrence.setType(value: "timer")
        }
        
        if WWMHelperClass.milestoneType == "hours_meditate"{
            self.selectedIndex = 4
        }else if WWMHelperClass.milestoneType == "consecutive_days"{
            self.selectedIndex = 4
        }else if WWMHelperClass.milestoneType == "sessions"{
            self.selectedIndex = 4
        }else{
            self.selectedIndex = 2
        }
        
        if self.appPreffrence.getForceLogout() == "force_logout_true"{
            self.selectedIndex = 4
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
        
        self.setupTabBarSeparators()

    }
    
    //meditationAPI
    // Calling API
    func meditationApi(type: String) {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : 1,
            "level_id"         : 1,
            "user_id"       : self.appPreffrence.getUserID(),
            "type" : type,
            "guided_type" : ""
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMSignupLetsStartVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            }
        }
    
    func setDataToDb(json:[String:Any]) {
        //print("database setting.... \(json)")
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
            
            if json["startChime"] as? String == "JAY GURU DEVA"{
                settingDB.startChime = "JAI GURU DEVA"
            }else{
                settingDB.startChime = json["startChime"] as? String ?? kChimes_BURMESE_BELL
            }
            
            if json["endChime"] as? String == "JAY GURU DEVA"{
                 settingDB.endChime = "JAI GURU DEVA"
            }else{
                settingDB.endChime = json["endChime"] as? String ?? kChimes_BURMESE_BELL
            }
            
            if json["finishChime"] as? String == "JAY GURU DEVA"{
                 settingDB.finishChime = "JAI GURU DEVA"
            }else{
                settingDB.finishChime = json["finishChime"] as? String ?? kChimes_BURMESE_BELL
            }
            
            if json["ambientSound"] as? String == "JAY GURU DEVA"{
                 settingDB.ambientChime = "JAI GURU DEVA"
            }else{
                settingDB.ambientChime = json["ambientSound"] as? String ?? kChimes_BURMESE_BELL
            }
            
            if json["intervalChime"] as? String == "JAY GURU DEVA"{
                 settingDB.intervalChime = "JAI GURU DEVA"
            }else{
                settingDB.intervalChime = json["intervalChime"] as? String ?? kChimes_BURMESE_BELL
            }
            
            settingDB.isAfterNoonReminder = json["IsAfternoonReminder"] as? Bool ?? false
            settingDB.isMilestoneAndRewards = json["IsMilestoneAndRewards"] as? Bool ?? false
            settingDB.isMorningReminder = json["IsMorningReminder"] as? Bool ?? false
            settingDB.moodMeterEnable = json["moodMeterEnable"] as? Bool ?? false
            settingDB.morningReminderTime = json["MorningReminderTime"] as? String ?? ""
            settingDB.afterNoonReminderTime = json["AfternoonReminderTime"] as? String ?? ""
            settingDB.learnReminderTime = json["LearnReminderTime"] as? String ?? ""
            settingDB.isLearnReminder = json["IsLearnReminder"] as? Bool ?? false
            settingDB.mantraID = json["MantraID"] as? Int ?? 1
            settingDB.isThirtyDaysReminder = json["isThirtyDaysReminder"] as? Bool ?? false
            settingDB.thirtyDaysReminder = json["thirtyDaysReminder"] as? String ?? ""
            settingDB.isTwentyoneDaysReminder = json["isTwentyoneDaysReminder"] as? Bool ?? false
            settingDB.twentyoneDaysReminder = json["twentyoneDaysReminder"] as? String ?? ""
            settingDB.isEightWeekReminder = json["isEightWeekReminder"] as? Bool ?? false
            settingDB.eightWeekReminder = json["eightWeekReminder"] as? String ?? ""
            settingDB.prepTime = "10"
            settingDB.meditationTime = "90"
            settingDB.restTime = "20"
            
            self.appPreffrence.setIs30DaysReminder(value: json["isThirtyDaysReminder"] as? Bool ?? false)
            self.appPreffrence.setIs21DaysReminder(value: json["isTwentyoneDaysReminder"] as? Bool ?? false)
            
            for index in 0..<arrMeditationData.count {
                let dataM = arrMeditationData[index]
                let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationData") as! DBMeditationData
                meditationDB.meditationId = Int32(dataM.meditationId)
                meditationDB.setmyown = Int32(dataM.setmyown)
                meditationDB.meditationName = dataM.meditationName
                meditationDB.isMeditationSelected = dataM.isSelected
                meditationDB.min_limit = dataM.min_limit
                meditationDB.max_limit = dataM.max_limit
                
                if dataM.isSelected{
                    self.appPreffrence.setTimerMin_limit(value: dataM.min_limit)
                    self.appPreffrence.setTimerMax_limit(value: dataM.max_limit)
                    self.appPreffrence.setMeditation_key(value: dataM.meditationName)
                }
                
                //print("dataM.min_limit*** \(dataM.min_limit) dataM.max_limit*** \(dataM.max_limit) dataM.isSelected*** \(dataM.isSelected) dataM.meditationName*** \(dataM.meditationName)")
                
                for index in 0..<dataM.levels.count {
                    let dic = dataM.levels[index]
                    let levelDB = WWMHelperClass.fetchEntity(dbName: "DBLevelData") as! DBLevelData
                    levelDB.isLevelSelected = dic.isSelected
                    if dic.isSelected {
                        if dataM.isSelected {
                            settingDB.prepTime = "\(dic.prepTime)"
                            settingDB.meditationTime = "\(dic.meditationTime)"
                            settingDB.restTime = "\(dic.restTime)"
                            //print(settingDB.prepTime ?? "")
                            //print(settingDB.meditationTime ?? "")
                            //print(settingDB.restTime ?? "")
                        }
                        
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
                
                let systemDate = Int(Date().timeIntervalSince1970)
                
                //community data*
                if let communtiyTimeStamp = result["community"] as? Int{
                    
                    self.fetchCommunityDataFromDB(time_stamp: communtiyTimeStamp)
                }else{
                    self.getCommunityAPI()
                }
                
                //wisdom data*
                if let combinedMantra = result["wisdom"] as? Int{
                    
                    self.fetchWisdomDataFromDB(time_stamp: combinedMantra)
                }else{
                    self.getWisdomAPI()
                }
                
                //guided data*
                if let guidedData = result["guidedData"] as? Int{
                    
                    self.fetchGuidedDataFromDB(time_stamp: guidedData)
                }else{
                    self.getGuidedListAPI()
                }
                
                //steps data*
                if let steps = result["steps"] as? Int{
                    
                    self.fetchStepsDataFromDB(time_stamp: steps)
                }else{
                    self.getLearnAPI()
                }
                
                //mantras data*
                 if let mantras = result["mantras"] as? Int{
                    self.fetchMantrasDataFromDB(time_stamp: mantras)
                 }else{
                    self.getMantrasAPI()
                }
                
                //getVibesImages data*
                if let getVibesImages = result["getVibesImages"] as? Int{
                    self.fetchGetVibesDataFromDB(time_stamp: getVibesImages)
                }else{
                    self.getVibesAPI()
                }
                
                //stepFaq*
                if let stepFaq = result["stepFaq"] as? Int{
                    self.appPreffrence.setStepFAQTimeStamp(value: stepFaq)
                    
                }else{
                    self.appPreffrence.setStepFAQTimeStamp(value: systemDate)
                }
                
                //print("success tabbarVC getdictionaryapi in background thread")
            }
        }
    }
    
    func forceLogoutAPI() {
        
        let param = [
            "email" : self.appPreffrence.getEmail(),
            "user_id": self.appPreffrence.getUserID()
        ]
                
        WWMWebServices.requestAPIWithBody(param: param as [String : Any] , urlString: URL_FORCELOGOUT, context: "check_user", headerType: kPOSTHeader, isUserToken: true){ (result, error, sucess) in
            if sucess {
                //print(result["success"] as? Bool ?? true)
                if let sucess1 = result["success"] as? Bool{
                    if sucess1{
                        DispatchQueue.main.async {
                            self.forceLogoutPopup(message: result["message"] as? String ?? "")
                        }
                    }
                }
                
                //print("success forceLogout api in background thread")
            }
        }
    }
    
    func forceLogoutPopup(message: String) {
        
        forceLogoutPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        forceLogoutPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        forceLogoutPopupView.btnOK.layer.borderWidth = 2.0
        forceLogoutPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        forceLogoutPopupView.lblTitle.text = message
        forceLogoutPopupView.lblSubtitle.numberOfLines = 0
        forceLogoutPopupView.lblSubtitle.text = ""
        forceLogoutPopupView.lblSubtitle.isHidden = true
        forceLogoutPopupView.btnOK.setTitle(KOK, for: .normal)
        forceLogoutPopupView.btnClose.isHidden = true
        forceLogoutPopupView.btnClose.setTitle("", for: .normal)
        
        forceLogoutPopupView.btnOK.addTarget(self, action: #selector(btnForceLogoutAction(_:)), for: .touchUpInside)
        //challengePopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(forceLogoutPopupView)
    }
    
    @IBAction func btnForceLogoutAction(_ sender: Any) {
        self.forceLogoutPopupView.removeFromSuperview()
        DispatchQueue.main.async {
            self.logoutAPI()
        }
    }
    
    func logoutAPI() {

        WWMHelperClass.sendEventAnalytics(contentType: "WWMTabBarVC", itemId: "LOGOUT", itemName: "")
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "token" : self.appPreffrence.getToken(),
            "user_id": self.appPreffrence.getUserID()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGOUT, context: "WWMSettingsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreffrence.setIsLogin(value: false)
                self.appPreffrence.setUserToken(value: "")
                self.appPreffrence.setUserID(value: "")
                self.appPreffrence.setUserName(value: "")
                self.appPreffrence.setIsProfileCompleted(value: false)
                self.appPreffrence.setPrePostJournalBool(value: false)
                self.appPreffrence.setExpiryDate(value: false)
                self.appPreffrence.setGetProfile(value: true)
                self.appPreffrence.setCheckEnterSignupLogin(value: false)
                self.appPreffrence.setEmail(value: "")
                KUSERDEFAULTS.set("0", forKey: "restore")
                self.appPreffrence.setPracticalChallenge(value: false)
                self.appPreffrence.setSpiritualChallenge(value: false)
                self.appPreffrence.set21ChallengeName(value: "")
                UserDefaults.standard.set(false, forKey: "isLogging")
                Logger.shared.setIsLogging(value: false)

                // Delete the Database :
                WWMHelperClass.deletefromDb(dbName: "DBJournalData")
                WWMHelperClass.deletefromDb(dbName: "DBContactUs")
                WWMHelperClass.deletefromDb(dbName: "DBJournalList")
                WWMHelperClass.deletefromDb(dbName: "DBMeditationComplete")
                WWMHelperClass.deletefromDb(dbName: "DBSettings")
                WWMHelperClass.deletefromDb(dbName: "DBAddSession")
                WWMHelperClass.deletefromDb(dbName: "DBMeditationHistory")
                WWMHelperClass.deletefromDb(dbName: "DBWisdomData")
                WWMHelperClass.deletefromDb(dbName: "DBWisdomVideoData")
                WWMHelperClass.deletefromDb(dbName: "DBCommunityData")
                WWMHelperClass.deletefromDb(dbName: "DBStepFaq")
                WWMHelperClass.deletefromDb(dbName: "DBGetVibesImages")
                WWMHelperClass.deletefromDb(dbName: "DBSteps")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                WWMHelperClass.deletefromDb(dbName: "DBNintyFiveCompletionData")
                WWMHelperClass.deletefromDb(dbName: "DBNinetyFivePercent")
                WWMHelperClass.deletefromDb(dbName: "DBLearn")
                WWMHelperClass.deletefromDb(dbName: "DBThirtyDays")
                WWMHelperClass.deletefromDb(dbName: "DBEightWeek")
                self.appPreffrence.setType(value: "")
                WWMHelperClass.challenge7DayCount = 0
                self.appPreffrence.setLastTimeStamp21DaysBool(value: false)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                
                let loginManager = LoginManager()
                AccessToken.current = nil
                loginManager.logOut()
                GIDSignIn.sharedInstance()?.signOut()
                GIDSignIn.sharedInstance()?.disconnect()
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                let vcc = UINavigationController.init(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController = vcc
                
                
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
                
            }
            
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    //MARK: Fetch Guided Data From DB
    func fetchGuidedDataFromDB(time_stamp: Any) {
        let getGuidedDataDB = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
        if getGuidedDataDB.count > 0 {
            
            for dict in getGuidedDataDB {
                                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                let apiTimeStamp: String = "\(time_stamp)"

                if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                    self.appPreffrence.setLastTimeStamp21DaysBool(value: true)
                    self.getGuidedListAPI()
                    return
                }
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                //print("date1... \(systemDate) date2... \(apiDate)")
                if systemDate < apiDate{
                    self.appPreffrence.setLastTimeStamp21DaysBool(value: true)
                    self.getGuidedListAPI()
                }
            }
        }else{
            self.getGuidedListAPI()
        }
    }
    
    func getGuidedListAPI(){
        
        let param = ["user_id": self.appPreffrence.getUserID()]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
            if let _ = result["success"] as? Bool {
                if let result = result["result"] as? [[String:Any]] {
                    
                    //print("success result getGuidedListAPI... \(result)")
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
                                
                                //print("dbGuidedData.last_time_stamp \(dbGuidedData.last_time_stamp) dbGuidedData.cat_name  \(dbGuidedData.cat_name ) dbGuidedData.guided_name \(dbGuidedData.guided_name) dbGuidedData.meditation_type \(dbGuidedData.meditation_type) dbGuidedData.guided_mode \(dbGuidedData.guided_mode) dbGuidedData.min_limit \(dbGuidedData.min_limit) dbGuidedData.max_limit \(dbGuidedData.max_limit) dbGuidedData.meditation_key \(dbGuidedData.meditation_key) dbGuidedData.complete_count \(dbGuidedData.complete_count) dbGuidedData.intro_url \(dbGuidedData.intro_url)")
                                
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
                                        
                                        if let intro_url = emotionsDict["intro_url"] as? String{
                                            dbGuidedEmotionsData.intro_url = intro_url
                                        }else{
                                            dbGuidedEmotionsData.intro_url = ""
                                        }
                                        
                                        if let emotion_type = emotionsDict["emotion_type"] as? String{
                                            //print("emotion_type tab** \(emotion_type)")
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
                        self.appPreffrence.setLastTimeStamp21DaysBool(value: false)
                    }
                }
            }
        }
        WWMHelperClass.hideLoaderAnimate(on: self.view)
        
    }
    
    //MARK: Fetch Steps Data From DB
    func fetchStepsDataFromDB(time_stamp: Any) {
           let getDBLearnDB = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
           if getDBLearnDB.count > 0 {
               
               for dict in getDBLearnDB {
                                   
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                   let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                   let apiTimeStamp: String = "\(time_stamp)"

                    if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                        self.getLearnAPI()
                        return
                    }
                   
                   let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                   let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                   
                   //print("date1... \(systemDate) date2... \(apiDate)")
                   if systemDate < apiDate{
                       self.getLearnAPI()
                   }
               }
           }else{
               self.getLearnAPI()
           }
       }

    
    //MARK: getLearnSetps API call
    func getLearnAPI() {
        
        //self.learnStepsListData.removeAll()
        let param = ["user_id": self.appPreffrence.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_LEARN_, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                if let total_paid = result["total_paid"] as? Double{
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    //print("learn result... \(result) getLearnAPI count... \(data.count)")
                    
                    let getDBLearn = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
                    if getDBLearn.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBLearn")
                    }
                    
                    let getStepsData = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                    if getStepsData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBSteps")
                    }
                    
                    let getThirtyDaysData = WWMHelperClass.fetchDB(dbName: "DBThirtyDays") as! [DBThirtyDays]
                    if getThirtyDaysData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBThirtyDays")
                    }
                    
                    let getEightWeekData = WWMHelperClass.fetchDB(dbName: "DBEightWeek") as! [DBEightWeek]
                    if getEightWeekData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBEightWeek")
                    }
                    
                    for dict in data{
                        
                        let dbLearnData = WWMHelperClass.fetchEntity(dbName: "DBLearn") as! DBLearn
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        //print("timeInterval.... \(timeInterval)")
                        dbLearnData.last_time_stamp = "\(timeInterval)"
                        
                        if dict["name"] as? String == "30 Day Challenge"{
                            self.appPreffrence.set30IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreffrence.set30DaysURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreffrence.set30DaysIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                        
                        if dict["name"] as? String == "8 Weeks Challenge"{
                            self.appPreffrence.set8IntroCompleted(value: dict["intro_completed"] as? Bool ?? false)
                            self.appPreffrence.set8WeekURL(value: dict["intro_url"] as? String ?? "")
                            self.appPreffrence.set8WeekIsExpired(value: dict["is_expired"] as? Bool ?? false)
                        }
                        
                        if let name = dict["name"] as? String{
                            dbLearnData.name = name
                        }
                        
                        if let intro_url = dict["intro_url"] as? String{
                            dbLearnData.intro_url = intro_url
                        }
                        
                        if let intro_completed = dict["intro_completed"] as? Bool{
                            dbLearnData.intro_completed = intro_completed
                        }
                        
                        if let min_limit = dict["min_limit"] as? String{
                            dbLearnData.min_limit = min_limit
                        }
                        
                        if let max_limit = dict["max_limit"] as? String{
                            dbLearnData.max_limit = max_limit
                        }
                        
                        if let is_expired = dict["is_expired"] as? Bool{
                            dbLearnData.is_expired = is_expired
                        }else{
                            dbLearnData.is_expired = false
                        }
                        
                        if let day_list = dict["day_list"] as? [[String: Any]]{
                            for dict in day_list{
                                let dbThirtyDays = WWMHelperClass.fetchEntity(dbName: "DBThirtyDays") as! DBThirtyDays
                                
                                if let id = dict["id"]{
                                    dbThirtyDays.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbThirtyDays.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbThirtyDays.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbThirtyDays.description1 = description
                                }
                                
                                if let is_milestone = dict["is_milestone"] as? Bool{
                                    dbThirtyDays.is_milestone = is_milestone
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbThirtyDays.min_limit = min_limit
                                }else{
                                    dbThirtyDays.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbThirtyDays.max_limit = max_limit
                                }else{
                                    dbThirtyDays.max_limit = "98"
                                }
                                
                                if let prep_time = dict["prep_time"] as? String{
                                    dbThirtyDays.prep_time = prep_time
                                }else{
                                    dbThirtyDays.prep_time = "60"
                                }
                                
                                if let meditation_time = dict["meditation_time"] as? String{
                                    dbThirtyDays.meditation_time = meditation_time
                                }else{
                                    dbThirtyDays.meditation_time = "1200"
                                }
                                
                                if let rest_time = dict["rest_time"] as? String{
                                    dbThirtyDays.rest_time = rest_time
                                }else{
                                    dbThirtyDays.rest_time = "120"
                                }
                                
                                if let prep_min = dict["prep_min"] as? String{
                                    dbThirtyDays.prep_min = prep_min
                                }else{
                                    dbThirtyDays.prep_min = "0"
                                }
                                
                                if let prep_max = dict["prep_max"] as? String{
                                    dbThirtyDays.prep_max = prep_max
                                }else{
                                    dbThirtyDays.prep_max = "300"
                                }
                                
                                if let rest_min = dict["rest_min"] as? String{
                                    dbThirtyDays.rest_min = rest_min
                                }else{
                                    dbThirtyDays.prep_max = "0"
                                }
                                
                                if let rest_max = dict["rest_max"] as? String{
                                    dbThirtyDays.rest_max = rest_max
                                }else{
                                    dbThirtyDays.prep_max = "600"
                                }
                                
                                if let med_min = dict["med_min"] as? String{
                                    dbThirtyDays.med_min = med_min
                                }else{
                                    dbThirtyDays.med_min = "0"
                                }
                                
                                if let med_max = dict["med_max"] as? String{
                                    dbThirtyDays.med_max = med_max
                                }else{
                                    dbThirtyDays.med_max = "2400"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbThirtyDays.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbThirtyDays.date_completed = date_completed
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbThirtyDays.image = image
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        if let step_list = dict["step_list"] as? [[String: Any]]{
                            for dict in step_list{
                                let dbStepsData = WWMHelperClass.fetchEntity(dbName: "DBSteps") as! DBSteps
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
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbStepsData.min_limit = min_limit
                                }else{
                                    dbStepsData.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbStepsData.max_limit = max_limit
                                }else{
                                    dbStepsData.max_limit = "98"
                                }
                                
                                WWMHelperClass.saveDb()
                                
                            }
                        }
                        
                        //8 week
                        if let daywise_list = dict["daywise_list"] as? [[String: Any]]{
                            for dict in daywise_list{
                                let dbEightWeek = WWMHelperClass.fetchEntity(dbName: "DBEightWeek") as! DBEightWeek
                                                                
                                if let id = dict["id"]{
                                    dbEightWeek.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbEightWeek.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbEightWeek.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbEightWeek.description1 = description
                                }
                                
                                if let secondDescription = dict["second_description"] as? String{
                                    dbEightWeek.secondDescription = secondDescription
                                }else{
                                    dbEightWeek.secondDescription = ""
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbEightWeek.image = image
                                }else{
                                    dbEightWeek.image = ""
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbEightWeek.min_limit = min_limit
                                }else{
                                    dbEightWeek.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbEightWeek.max_limit = max_limit
                                }else{
                                    dbEightWeek.max_limit = "98"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbEightWeek.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbEightWeek.date_completed = date_completed
                                }
                                
                                if let is_pre_opened = dict["is_pre_opened"] as? Bool{
                                    dbEightWeek.is_pre_opened = is_pre_opened
                                }
                                
                                if let second_session_required = dict["second_session_required"] as? Bool{
                                    dbEightWeek.second_session_required = second_session_required
                                }
                                
                                if let second_session_completed = dict["second_session_completed"] as? Bool{
                                    dbEightWeek.second_session_completed = second_session_completed
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        WWMHelperClass.saveDb()
                    }
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
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                let apiTimeStamp: String = "\(time_stamp)"

                if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                     self.getVibesAPI()
                     return
                 }
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                //print("date1... \(systemDate) date2... \(apiDate)")
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
                    //print("result getVibesAPI... \(result) GetVibesAPI tabbarvc in background thread...")
                    
                    if let data = result["data"] as? [[String: Any]]{
                        
                        //print("GetVibesAPI count... \(data.count)")
                        
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
                                        //print("timeInterval.... \(timeInterval)")
                                        
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
        
        //print("time_stamp....+++ \(time_stamp)")
        
        let comunityDataDB = WWMHelperClass.fetchDB(dbName: "DBCommunityData") as! [DBCommunityData]
        if comunityDataDB.count > 0 {
            
            for dict in comunityDataDB {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                let apiTimeStamp: String = "\(time_stamp)"

                if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                    self.getCommunityAPI()
                    return
                }
                                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                //print("date1... \(systemDate) date2... \(apiDate)")
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
        
        //print("param get community.. \(param) URL_COMMUNITYDATA... \(URL_COMMUNITYDATA)")
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMMUNITYDATA, context: "WWMCommunityVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                //print("result getcommunity... \(result)")
                
                let comunityData = WWMHelperClass.fetchDB(dbName: "DBCommunityData") as! [DBCommunityData]
                if comunityData.count > 0 {
                    WWMHelperClass.deletefromDb(dbName: "DBCommunityData")
                }
                
                let dbCommunityData = WWMHelperClass.fetchEntity(dbName: "DBCommunityData") as! DBCommunityData
                
                if let result = result["result"] as? [String: Any]{
                    //print("result get community... \(result)")
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: result, options:.prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    dbCommunityData.data = myString
                    
                    let timeInterval = Int(Date().timeIntervalSince1970)
                    //print("timeInterval.... \(timeInterval)")
                    
                    dbCommunityData.last_time_stamp = "\(timeInterval)"
                    
                    WWMHelperClass.saveDb()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationCommunity"), object: nil)
                    //print("success tabbarVC getcommunity in background thread")
                }
            }
        }
    }
    
    //get mantras
    
    func fetchMantrasDataFromDB(time_stamp: Any) {
            let mantrasDataDB = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
            if mantrasDataDB.count > 0 {
                
                for dict in mantrasDataDB {
                                
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                    let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                    let apiTimeStamp: String = "\(time_stamp)"

                    if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                         self.getMantrasAPI()
                         return
                     }
                    
                    let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                    let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                    
                    //print("date1... \(systemDate) date2... \(apiDate)")
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
                            
                            //print("mantras result... \(result)")
                            let dbMantrasData = WWMHelperClass.fetchEntity(dbName: "DBMantras") as! DBMantras
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                            let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                            dbMantrasData.data = myString
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            //print("timeInterval.... \(timeInterval)")
                            
                            dbMantrasData.last_time_stamp = "\(timeInterval)"
                            
                            WWMHelperClass.saveDb()
                            
                        }
                    }
                    //print("success tabbarvc getmantras api in background")
                }
            }
        }
    
    //get wisdom api
    func fetchWisdomDataFromDB(time_stamp: Any) {
        let wisdomDataDB = WWMHelperClass.fetchDB(dbName: "DBWisdomData") as! [DBWisdomData]
        if wisdomDataDB.count > 0 {
            //print("wisdomDataDB.. \(wisdomDataDB.count) wisdomVideoData.. \(wisdomVideoData.count)")
            
            for dict in wisdomDataDB {
                            
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                let systemTimeStamp: String = dict.last_time_stamp ?? "\(Int(Date().timeIntervalSince1970))"
                let apiTimeStamp: String = "\(time_stamp)"

                 if systemTimeStamp == "nil" || apiTimeStamp == "nil"{
                     self.getWisdomAPI()
                     return
                 }
                
                let systemDate = Date(timeIntervalSince1970: Double(systemTimeStamp)!)
                let apiDate = Date(timeIntervalSince1970: Double(apiTimeStamp)!)
                
                //print("date1... \(systemDate) date2... \(apiDate)")
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
                    
                    //print("success getWisdomAPI \(result)")
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
                            //print("wisdom result... \(result)")
                            let dbWisdomData = WWMHelperClass.fetchEntity(dbName: "DBWisdomData") as! DBWisdomData
                        
                            if let id = dict["id"]{
                                dbWisdomData.id = "\(id)"
                                wisdom_id = id as? Int ?? 0
                            }
                            if let name = dict["name"] as? String{
                                dbWisdomData.name = name
                                dbWisdomData.cat_name = name
                            }
                            
                            let timeInterval = Int(Date().timeIntervalSince1970)
                            //print("timeInterval.... \(timeInterval)")
                            
                            dbWisdomData.last_time_stamp = "\(timeInterval)"
                            
                            if let video_list = dict["video_list"] as? [[String: Any]]{
                                for dict1 in video_list{
                                    let dbWisdomVideoData = WWMHelperClass.fetchEntity(dbName: "DBWisdomVideoData") as! DBWisdomVideoData
                                    
                                    if let id = dict1["id"]{
                                        dbWisdomVideoData.video_id = "\(id)"
                                    }
                                    
                                    if let is_intro = dict1["is_intro"] as? Int{
                                        dbWisdomVideoData.is_intro = "\(is_intro)"
                                    }else{
                                        dbWisdomVideoData.is_intro = "0"
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
                                    //print("wisdomVideoData.count... \(wisdomVideoData.count)")
                                }
                            }
                            
                            WWMHelperClass.saveDb()
                        }
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationWisdom"), object: nil)
                        //print("wisdomData tabbarvc in background thread...")
                    }
                }
            }
        }
    }


    //NinetyFive Percent API
    func meditationlistAPI() {
        let param = [
        "user_id":self.appPreffrence.getUserID(), "type": self.appPreffrence.getType()] as [String : Any]
        //print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONLIST, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            //print("result meditationlistAPI \(result)")
            if let data = result["data"] as? [[String: Any]]{
                for dict in data{
                    
                    //guided
                    if self.appPreffrence.getType() == "guided" || self.appPreffrence.getType() == "Guided"{
                        if let guided_type = dict["guided_type"] as? String{
                            if let name = dict["name"] as? String{
                                if let complete_count = dict["complete_count"] as? Int{
                                    //print("\(guided_type)_\(name) complete_count*** \(complete_count)")
                                    WWMHelperClass.addNinetyFivePercentDataFromBackend(type: "\(guided_type)_\(name)", count: complete_count)
                                }
                            }
                        }
                    }else{
                        if let name = dict["name"] as? String{
                            if let complete_count = dict["complete_count"] as? Int{
                                //print("\(name) complete_count*** \(complete_count)")
                                WWMHelperClass.addNinetyFivePercentDataFromBackend(type: name, count: complete_count)
                            }
                        }
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
                        
                        //print("meditationHistory records... \(records)")
                        
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
                //print("url MedHist....****** \(URL_MEDITATIONHISTORY+"/page=1") param MedHist....****** \(param) result medHist....****** \(result) success tabbarVC meditationhistoryapi in background thread")
            }
        }
    }
    
/*
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
    */
    func getUserProfileData(lat: String, long: String) {
        if self.appPreffrence.getGetProfile(){
            
            // CONNECTION IS NOT REACHABLE
            if !reachable.isConnectedToNetwork() {
                if !self.flagConnAlertShow{
                    self.connectionLost()
                    self.flagConnAlertShow = true
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.popUpForOfflineMode()
                        //self.btnDoneAction()
                    })
                }
            }else{// CONNECTION IS AVAILABLE
                WWMHelperClass.showLoaderAnimate(on: self.view)
                self.getProfileDataInBackground(lat: self.lat, long: self.long)
            }
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
            "email":self.appPreffrence.getEmail(),
            "lat": lat,
            "long": long,
            "city":city,
            "country":country
            ] as [String : Any]
            
            //print("param... \(param)")
            
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETPROFILE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if sucess {
                    if let success = result["success"] as? Bool {
                        if success {
                            
                            WWMHelperClass.hideLoaderAnimate(on: self.view)
                            //print("user_id****** \(self.appPreffrence.getUserID()) result***** \(result)")
                            
                            var userSubscription = WWMUserData.sharedInstance
                            userSubscription = WWMUserData.init(subscriptionJson: result["subscription"] as! [String : Any])
                            self.appPreffrence.setGetProfile(value: false)
                            self.appPreffrence.setHomePageURL(value: result["home_page_url"] as! String)
                            self.appPreffrence.set30DaysURL(value: result["30days_intro_url"] as! String)
                            self.appPreffrence.setInvitationCode(value: result["Invitation_code"] as! String)
                            self.appPreffrence.setLearnPageURL(value: result["learn_page_url"] as! String)
                            self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
                            self.appPreffrence.setUserSubscription(value: result["subscription"] as! [String : Any])
                            self.appPreffrence.setOffers(value: result["offers"] as! [String])
                            
                            if let userProfile = result["user_profile"] as? [String : Any]{
                                //setEmail
                                self.appPreffrence.setEmail(value: userProfile["email"] as? String ?? "")
                                self.appPreffrence.setUserName(value: userProfile["name"] as? String ?? "")
                                self.appPreffrence.setProfileImgURL(value: userProfile["profile_image"] as? String ?? "")
                                self.appPreffrence.setGender(value: userProfile["gender"] as? String ?? "")
                                self.appPreffrence.setDob(value: userProfile["dob"] as? String ?? "")
                                self.appPreffrence.setUserID(value:"\(userProfile["id"] as? Int ?? 0)")
                                
                                //this is for hide or unhide setting for paid and unpaid user
                                self.appPreffrence.setIsSubscribedBool(value: userProfile["is_subscribed"] as? Bool ?? false)
                            }
                            
                            self.appPreffrence.setSessionAvailableData(value: result["session_available"] as? Bool ?? false)
                            self.appPreffrence.SetExpireDateBackend(value: userSubscription.expiry_date)
                            self.appPreffrence.setSubscriptionPlan(value: userSubscription.subscription_plan)
                            self.appPreffrence.setSubscriptionId(value: "\(userSubscription.subscription_id)")
                            
                            let difference = WWMHelperClass.dateComparison(expiryDate: userSubscription.expiry_date)
                            
                            self.appPreffrence.setExpiryDate(value: false)
                            
                            if let subscription = result["subscription"] as? [String : Any]{
                                if let journal = subscription["journal"] as? [String : Any]{
                                    if let post = journal["post"] as? Int{
                                        if post >= 6{
                                            self.appPreffrence.setPostJournalCount(value: 0)
                                        }
                                    }
                                    
                                    if let pre = journal["pre"] as? Int{
                                        if pre >= 6{
                                            self.appPreffrence.setPreJournalCount(value: 0)
                                        }
                                    }
                                }
                                if let mood = subscription["mood"] as? [String : Any]{
                                    if let post = mood["post"] as? Int{
                                        if post >= 6{
                                            self.appPreffrence.setPostMoodCount(value: 0)
                                        }
                                    }
                                    
                                    if let pre = mood["pre"] as? Int{
                                        if pre >= 6{
                                            self.appPreffrence.setPreMoodCount(value: 0)
                                        }
                                    }
                                }
                            }
                            
                            if difference == 1{
                                if !self.appPreffrence.getPrePostJournalBool(){
                                    
                                    self.appPreffrence.setPrePostJournalBool(value: true)
                                    
                                    //print("premood.. \(userSubscription.preMood) postmood.. \(userSubscription.postMood) prejouranl.. \(userSubscription.preJournal) postjoural.. \(userSubscription.postJournal)")
                                    
                                    
                                    if let subscription = result["subscription"] as? [String : Any]{
                                        if let journal = subscription["journal"] as? [String : Any]{
                                            if let post = journal["post"] as? Int{
                                                if post >= 6{
                                                    self.appPreffrence.setPostJournalCount(value: 0)
                                                }else{
                                                    self.appPreffrence.setPostJournalCount(value: 6)
                                                }
                                            }
                                            
                                            if let pre = journal["pre"] as? Int{
                                                if pre >= 6{
                                                    self.appPreffrence.setPreJournalCount(value: 0)
                                                }else{
                                                    self.appPreffrence.setPreJournalCount(value: 6)
                                                }
                                            }
                                        }
                                        if let mood = subscription["mood"] as? [String : Any]{
                                            if let post = mood["post"] as? Int{
                                                if post >= 6{
                                                    self.appPreffrence.setPostMoodCount(value: 0)
                                                }else{
                                                    self.appPreffrence.setPostMoodCount(value: 6)
                                                }
                                            }
                                            
                                            if let pre = mood["pre"] as? Int{
                                                if pre >= 6{
                                                    self.appPreffrence.setPreMoodCount(value: 0)
                                                }else{
                                                    self.appPreffrence.setPreMoodCount(value: 6)
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                self.appPreffrence.setExpiryDate(value: true)
                            }
                            
                            self.setDataToDb(json: result["settings"] as! [String:Any])
                            
                            //*receiptValidation
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.locale = Locale.current
                            formatter.locale = Locale(identifier: formatter.locale.identifier)
                            
                            let expiryDate = self.appPreffrence.getExpireDateBackend()
                            if expiryDate != ""{
                                
                                if let _ = formatter.date(from: expiryDate){
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                }else{
                                    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                }
                                
                                let currentDateString = formatter.string(from: Date())
                                var expireDate: Date = Date()
                                var currentDate: Date = Date()
                                
                                //system date
                                currentDate = formatter.date(from: currentDateString)!
                                
                                //server Date
                                expireDate = WWMHelperClass.getExpireDate(expiryDate: expiryDate, formatter: formatter)
                                
                                //print("self.appPreffrence.getExpiryDate... \(expiryDate) formatter.date... \(String(describing: formatter.date(from: expiryDate))) currentDate+++ \(currentDate) expireDate++ \(expireDate)")
                                
                                
                                self.checkExpireFunc(currentDate: currentDate, expireDate: expireDate)
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                }
            }
        }
    }
    
    func checkExpireFunc(currentDate: Date, expireDate: Date){
        if currentDate > expireDate{
            //print("currentDate is greater than expireDate")
            if self.appPreffrence.isLogin(){
                DispatchQueue.global(qos: .background).async {
                    self.receiptValidation()
                }
            }
        }else{
            //print("currentDate is smaller than expireDate \(currentDate) \(expireDate)")
        }
    }
    
    func receiptValidation() {
        let appsToreUrlString = kURL_INAPPS_RECEIPT
        let receiptUrl = Bundle.main.appStoreReceiptURL
        do {
            let receipt = try Data(contentsOf: receiptUrl!)
            let encodedString = receipt.base64EncodedString()
            let requestContents = ["receipt-data" : encodedString  as AnyObject, "password": "ec9270a657eb4b3e877be4c92cf3f8c2" as AnyObject] as [String : Any]
            do {
                let requestJsonData = try JSONSerialization.data(withJSONObject: requestContents, options: [])
                let session = URLSession.shared
                let request = NSMutableURLRequest(url: URL(string: appsToreUrlString)!)
                request.httpMethod = "POST"
                request.httpBody = requestJsonData
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, err) in
                    if data != nil{
                        let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                        //print(json ?? "")
                        
                        Logger.shared.generateLogs(type: "API: receiptValidation", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "json \(json ?? "")")
                        if json != nil{
                            if let date = self.getExpirationDateFromResponse(json as! NSDictionary) {
                                //print("date...+++++ \(date)")
                                let expiryDate = self.appPreffrence.getExpireDateBackend()
                                if expiryDate != ""{
                                    //print("self.appPreffrence.getExpiryDate... \(expiryDate)")
                                    
                                    let formatter = DateFormatter()
//                                    formatter.locale = Locale(identifier: "en_US_POSIX")
                                    formatter.locale = Locale.current
                                    formatter.locale = Locale(identifier: formatter.locale.identifier)
                                    
                                    if let _ = formatter.date(from: expiryDate){
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    }else{
                                        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                    }
                                    
                                    //backend
                                    let expireDate = WWMHelperClass.getExpireDate(expiryDate: expiryDate, formatter: formatter)
                                    
                                    //apple
                                    let serverDate = WWMHelperClass.getExpireDate(expiryDate: formatter.string(from: date), formatter: formatter)
                                    //print("backend date \(expireDate) apple date++++ \(serverDate)")
                                    
                                    Logger.shared.generateLogs(type: "API: receiptValidation", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "json not nil backendExpireDate \(expireDate) appleExpireDate \(serverDate)")
                                    
                                    if serverDate > expireDate{
                                        //print("product_id... \(self.product_id) repurchased")
                                        
                                        Logger.shared.generateLogs(type: "API: receiptValidation", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "apple server date greater than backend server date")
                                        
                                        self.getSubscriptionPlanId()
                                    }else{
                                        //print("expired")
                                        
                                        Logger.shared.generateLogs(type: "API: receiptValidation", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "backend server date greater than apple server date")
                                    }
                                }
                            }
                        }
                    }
                }
                dataTask.resume()
                
            } catch { return }
        } catch { return }
    }
      
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.locale = Locale(identifier: formatter.locale.identifier)
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
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
                let expiryDateComponents = expiresDate.components(separatedBy: " ")
                let purchaseDateStr = expiryDateComponents[0] + " " + expiryDateComponents[1]
                
                let purchaseDate = formatter.date(from: purchaseDateStr)
                return purchaseDate
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
                   //print("result.... \(result)")
                    
                    Logger.shared.generateLogs(type: "API: getSubscriptionPlanId", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "self.responseArray \(self.responseArray)")
                    
                    var getProductId: Bool = false
                    var plan_id: Int = 2
                    var subscriptionPlan: String = "annual"
                    var subscriptionAmount: Any?
                    
                    for i in 0..<self.responseArray.count {
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
                        
                        //print("param,,,,... \(param)")
                        self.subscriptionSucessAPI(param: param)
                    }
                }
            }else{
                Logger.shared.generateLogs(type: "API: getSubscriptionPlanId", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "Response Fail")
            }
        }
    }
    
    func subscriptionSucessAPI(param : [String : Any]) {
        
        //print("param.....###### \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SUBSCRIPTIONPURCHASE, context: "WWMUpgradeBeejaVC", headerType: kPOSTHeader, isUserToken: true) { (response, error, sucess) in
            if sucess {
                //print("success.... upgrade beeja tab bar vc lat...\(self.lat) long... \(self.long)")
                
                Logger.shared.generateLogs(type: "API: subscriptionSucessAPI", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "param \(param)")
                self.getUserProfileData(lat: self.lat, long: self.long)
            }else{
                Logger.shared.generateLogs(type: "API: subscriptionSucessAPI", user_id: self.appPreffrence.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "Response Error")
            }
        }
    }
    
    func getDataFromDatabase() {
        if self.appPreffrence.isLogout() {
            var userData = WWMUserData.sharedInstance
            userData = WWMUserData.init(json: self.appPreffrence.getUserData())
            //print(userData)
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
    
    func popUpForOfflineMode(){
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = kAlertTitle
        alertPopupView.lblSubtitle.text = "Seems this is your first time after login. \nYou will have to get online once to setup your account and support the offline functionality."
        alertPopupView.btnOK.setTitle(KRETRY, for: .normal)
        alertPopupView.btnClose.isHidden = true
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneOfflinePopUP(_:)), for: .touchUpInside)
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.btnDoneAction()
    }
    
    @IBAction func btnDoneOfflinePopUP(_ sender: Any) {
        self.btnDoneAction()
    }
    
    func btnDoneAction(){
        //WWMHelperClass.hideLoaderAnimate(on: self.view)
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            //print("dismiss popup...")
            self.getDataFromDatabase()
        }else{
            if !reachable.isConnectedToNetwork() {
                if !self.flagConnAlertShow{
                    self.connectionLost()
                    self.flagConnAlertShow = true
                }else{
                    //print("no alert...")
                    self.getUserProfileData(lat: self.lat, long: self.long)
                }
            }else{
                self.getUserProfileData(lat: self.lat, long: self.long)
            }
        }
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

extension WWMTabBarVC{
    func convertToDictionary1(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
