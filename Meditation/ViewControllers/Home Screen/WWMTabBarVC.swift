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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let restoreValue = KUSERDEFAULTS.string(forKey: "restore"){
            print("restore.... \(restoreValue)")
            if restoreValue == "1"{
                self.showToast(message: KRESTOREMSG)
                KUSERDEFAULTS.set("0", forKey: "restore")
            }
        }
        
        self.delegate = self
       // getUserProfileData(lat: self.lat, long: self.long)
        setupView()
        
        if !reachable.isConnectedToNetwork() {
            if self.appPreffrence.isLogout() {
                
                var userData = WWMUserData()
                userData = WWMUserData.init(json: self.appPreffrence.getUserData())
                print(userData)
                
//                self.lat = userData.latitude
//                self.long = userData.longitude
//                city = userData.city
//                country = userData.country
                
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
                    
                    self.getUserProfileData(lat: self.lat, long: self.lat)
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
                
                self.getUserProfileData(lat: self.lat, long: self.lat)
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
            DispatchQueue.main.async {
                WWMHelperClass.showLoaderAnimate(on: self.view)
            }
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
        
        
        var arrMeditationData = [WWMMeditationData]()
        if let dataMeditation = json["meditation_data"] as? [[String:Any]]{
            for dict in dataMeditation {
                let data = WWMMeditationData.init(json: dict)
                arrMeditationData.append(data)
            }
        }
        
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
        
       // print(needsUpdate())
    }
    
    //  Converted to Swift 5 by Swiftify v5.0.7505 - https://objectivec2swift.com/
    func needsUpdate() -> Bool {
        let infoDictionary = Bundle.main.infoDictionary
        let appID = "1453359245"//infoDictionary?["CFBundleIdentifier"] as? String
        let url = URL(string: "http://itunes.apple.com/lookup?id=\(appID)")
        var data: Data? = nil
        if let url = url {
            data = try? Data(contentsOf: url)
        }
        var lookup: [AnyHashable : Any]? = nil
        do {
            if let data = data {
                lookup = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
            }
        } catch {
        }
        
        if (lookup?["resultCount"] as? NSNumber)?.intValue == 1 {
            if let results = lookup?["results"] as? [[String:Any]] {
                let appStoreVersion = results[0]["version"] as? String
                let currentVersion = infoDictionary?["CFBundleShortVersionString"] as? String
                if !(appStoreVersion == currentVersion) {
                    print("Need to update [\(appStoreVersion ?? "") != \(currentVersion ?? "")]")
                    return true
                }
            }
            
            
        }
        return false
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
        //WWMHelperClass.showSVHud()
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
                        
                        
                        self.appPreffrence.setHomePageURL(value: result["home_page_url"] as! String)
                        self.appPreffrence.setLearnPageURL(value: result["learn_page_url"] as! String)
                        self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
                        self.appPreffrence.setUserSubscription(value: result["subscription"] as! [String : Any])
                        
                        self.appPreffrence.setOffers(value: result["offers"] as! [String])
                        
                        if let userProfile = result["user_profile"] as? [String : Any]{
                            self.appPreffrence.setUserName(value:  userProfile["name"] as? String ?? "")
                        }
                        
                        self.appPreffrence.setSessionAvailableData(value: result["session_available"] as? Bool ?? false)
                        
                        
                        print("getPreMoodBool.... \(self.appPreffrence.getPrePostJournalBool())")
                        print("userSubscription.expiry_date... \(userSubscription.expiry_date)")
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
                        
//                        if let force_update = result["force_update"] as? Bool{
//                            if force_update{
//                                if self.needsUpdate(){
//                                    self.forceToUpdatePopUp()
//                                }
//                            }
//                        }
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
    
    func forceToUpdatePopUp(){
        
        alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView1.isRemove = false
        alertPopupView1.btnOK.layer.borderWidth = 2.0
        alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView1.lblTitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATETITLE) ?? KFORCEUPDATETITLE
        alertPopupView1.lblSubtitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATEDES) ?? KFORCEUPDATESUBTITLE
        alertPopupView1.btnOK.setTitle(KUSERDEFAULTS.string(forKey: KUPGRADEBUTTON) ?? "Update", for: .normal)
        alertPopupView1.btnClose.isHidden = true
        
        alertPopupView1.btnOK.addTarget(self, action: #selector(btnForceToUpdateDoneAction(_:)), for: .touchUpInside)
        alertPopupView1.btnClose.addTarget(self, action: #selector(btnForceToUpdateCancelAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        self.getUserProfileData(lat: self.lat, long: self.long)
    }
    
    @IBAction func btnForceToUpdateDoneAction(_ sender: Any) {
        //https://apps.apple.com/us/app/beeja-meditation/id1453359245
        UIApplication.shared.open(URL.init(string: "https://apps.apple.com/is/app/beeja-meditation/id1453359245")!, options: [:], completionHandler: nil)

    }
    
    @IBAction func btnForceToUpdateCancelAction(_ sender: Any) {
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
