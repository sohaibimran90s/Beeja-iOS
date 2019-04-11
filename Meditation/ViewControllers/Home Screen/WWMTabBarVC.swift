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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupView()
        DispatchQueue.main.async {
            WWMHelperClass.showSVHud()
        }
        
        //self.getUserProfileData()
        
        if !reachable.isConnectedToNetwork() {
            if self.appPreffrence.isLogout() {
                var userData = WWMUserData()
                userData = WWMUserData.init(json: self.appPreffrence.getUserData())
                print(userData)
                lat = userData.latitude
                long = userData.longitude
                city = userData.city
                country = userData.country
                self.getUserProfileData()
            }else {
                self.connectionLost()
            }
        }else {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.requestWhenInUseAuthorization()
            locManager.startUpdatingLocation()
        }
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         currentLocation = locations[0]
        if lat == "" {
            getCityAndCountry()
        }
        
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if self.appPreffrence.isLogout() {
            var userData = WWMUserData()
            userData = WWMUserData.init(json: self.appPreffrence.getUserData())
            print(userData)
            lat = userData.latitude
            long = userData.longitude
            city = userData.city
            country = userData.country
        }
        
        getUserProfileData()
    }
    
    func getCityAndCountry() {
        lat = "\(currentLocation.coordinate.latitude)"
        long = "\(currentLocation.coordinate.longitude)"
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
                        self.lat = userData.latitude
                        self.long = userData.longitude
                        self.city = userData.city
                        self.country = userData.country
                    }
                    
                    self.getUserProfileData()
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
                self.getUserProfileData()
        })
    }
    
    
    func setupView() {
        
        layerGradient.colors = [UIColor.init(hexString: "#5732a3")!.cgColor, UIColor.init(hexString: "#001252")!.cgColor]
        layerGradient.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 84)
       self.tabBar.layer.insertSublayer(layerGradient, at: 0)
        for index in 0..<4 {
            let item = self.tabBar.items?[index]
            item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if index == 2 {
                
                item?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
        self.selectedIndex = 2
    }
    

    
    func setDataToDb(json:[String:Any]) {
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
                levelDB.prepTime = Int32(dic.prepTime)!
                levelDB.meditationTime = Int32(dic.meditationTime)!
                levelDB.restTime = Int32(dic.restTime)!
                levelDB.minPrep = Int32(dic.minPrep)!
                levelDB.minRest = Int32(dic.minRest)!
                levelDB.minMeditation = Int32(dic.minMeditation)!
                levelDB.maxPrep = Int32(dic.maxPrep)!
                levelDB.maxRest = Int32(dic.maxRest)!
                levelDB.maxMeditation = Int32(dic.maxMeditation)!
                meditationDB.addToLevels(levelDB)
            }
            settingDB.addToMeditationData(meditationDB)
        }
        WWMHelperClass.saveDb()
        NotificationCenter.default.post(name: NSNotification.Name.init("GETSettingData"), object: nil)
        
    }

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        for itemTab in  self.tabBar.items!{
            
            itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            if itemTab == item {
                
                itemTab.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
            }
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
    }
    
    func getUserProfileData() {
        //WWMHelperClass.showSVHud()
        let param = [
            "user_id":self.appPreffrence.getUserID(),
            "lat": lat,
            "long":long,
            "city":city,
            "country":country
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETPROFILE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    if success {
                        var userData = WWMUserData.sharedInstance
                        userData = WWMUserData.init(json: result["user_profile"] as! [String : Any])
                        print(userData)
                        self.appPreffrence.setUserData(value: result["user_profile"] as! [String : Any])
                        
                        self.setDataToDb(json: result["settings"] as! [String:Any])
                    }else {
                        self.getDataFromDatabase()
                    }
                    
                }else {
                    self.getDataFromDatabase()
                }
                
            }else {
                self.getDataFromDatabase()
            }
            WWMHelperClass.dismissSVHud()
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
        alertPopupView.lblSubtitle.text = "Oh no, we've lost you! Please check your internet connection."
        alertPopupView.btnOK.setTitle("Retry", for: .normal)
        alertPopupView.btnClose.isHidden = true
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        WWMHelperClass.showSVHud()
        self.getUserProfileData()
    }
}
