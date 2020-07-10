                    
//  AppDelegate.swift
//  Meditation
//
//  Created by Roshan Kumawat on 03/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import CoreData
import UserNotifications
import Reachability
import FirebaseCrashlytics
//import Fabric
import CallKit
import FirebaseAnalytics


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, CXCallObserverDelegate {
    

    fileprivate let redirectUri = URL(string:"beeja-med-test-app://beeja-med-test-callback")!
    fileprivate let clientIdentifier = "2fd82c511bd74915b2b16ff1903eeb2b"
    fileprivate let name = "spotify"
    static fileprivate let kAccessTokenKey = "access-token-key"
    
    var window: UIWindow?
    let appPreference = WWMAppPreference()
    let center = UNUserNotificationCenter.current()
    let reachability = Reachability()
    var auth = SPTAuth()
    let gcmMessageIDKey = "gcm.message_id"
    
    let appPreffrence = WWMAppPreference()
    var alertPopupView1 = WWMAlertController()
    var date = Date()
    var value = 0
    
    var tabBarController:UITabBarController?
    var userData = WWMUserData.sharedInstance
    
    var guided_type = ""
    var type = ""
    var application: UIApplication?
    
    var min_limit = ""
    var max_limit = ""
    
    static func sharedDelegate () -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var callObserver = CXCallObserver()
    
    //MARK: Appdelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.application = application
        
        auth.redirectURL = URL(string: "Beeja-App://GetPlayList")
        auth.sessionUserDefaultsKey = "current session"
        
        IQKeyboardManager.shared.enable = true
      //  IQKeyboardManager.shared.enableDebugging = true
        //IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Next"

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        //Fabric.with([Crashlytics.self])
        //Fabric.sharedSDK().debug = true
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        print(UIDevice.current.identifierForVendor!.uuidString)
        // GIDSignIn.sharedInstance().delegate = self
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        // To check the internet reachability
    
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability!.startNotifier()
        }catch{
            //print("could not start reachability notifier")
        }
        
        self.requestAuthorization()
        self.setLocalPush()
        
        callObserver.setDelegate(self, queue: nil)
        
        self.addShortCuts(application: application)
        NotificationCenter.default.addObserver(self, selector: #selector(addShortCutsRefresh), name: NSNotification.Name(rawValue: "logoutSuccessful"), object: nil)
        
//      EH - forced crash for FB Crashlytics testing purpose only - don't uncomment
//        Crashlytics.crashlytics().setUserID("userId Ehsan Test")
//        fatalError()
        
//        Crashlytics.sharedInstance().crash()
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//            AnalyticsParameterItemID: "id-Beeja-App-Started-123",
//            AnalyticsParameterContentType: "App Login 123"
//            ])
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    //MARK: For 3d touch code
    
    @objc func addShortCutsRefresh () {
        self.addShortCuts(application: self.application!)
    }
        
    func addShortCuts(application: UIApplication){
        
        let timer = UIMutableApplicationShortcutItem(type: "Timer", localizedTitle: "I know how to Meditate", localizedSubtitle: "Take me to timer", icon: UIApplicationShortcutIcon(templateImageName: "timer_3d"), userInfo: nil)
        let guided = UIMutableApplicationShortcutItem(type: "Guided", localizedTitle: "Guide Me", localizedSubtitle: "Meditations to suit your mood", icon: UIApplicationShortcutIcon(templateImageName: "guided_3d"), userInfo: nil)
        let learn = UIMutableApplicationShortcutItem(type: "Learn", localizedTitle: "Learn", localizedSubtitle: "Take our 12 step course", icon: UIApplicationShortcutIcon(templateImageName: "learn_3d"), userInfo: nil)
        let login = UIMutableApplicationShortcutItem(type: "Login", localizedTitle: "Experience Beeja", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "stop_3d"), userInfo: nil)
        let signup = UIMutableApplicationShortcutItem(type: "Signup", localizedTitle: "Start Beeja", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "stop_3d"), userInfo: nil)
        
        if self.appPreference.isProfileComplete() {
            application.shortcutItems = [timer, guided, learn]
        }else{
            application.shortcutItems = [login, signup]
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let handleShortCutItem = self.handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handleShortCutItem)
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool{
        var handle = false
        guard let shortCutType = shortcutItem.type as String? else {return false}
    
        UserDefaults.standard.set(true, forKey: "shortCutType")
        //print("shortCutType++++ \(shortCutType)")
        switch shortCutType {
        case "Timer":
            
            let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
            if data.count > 0 {
                
                WWMHelperClass.sendEventAnalytics(contentType: "3D", itemId: "I_KNOW_HOW", itemName: "")
                self.dismissRootViewController()
                //print("Take me to timer")
                handle = true
                              
                self.type = "timer"
                self.guided_type = ""
                    
                self.pushTimerGuidedLearnVC()
            }
            
            break
        case "Guided":
            
            let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
            if data.count > 0 {
                
                self.dismissRootViewController()
                print("Guided Meditation")
                handle = true
                    
                self.type = "guided"
                self.pushTimerGuidedLearnVC()
            }
            
            break
        case "Learn":
            
            let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
            if data.count > 0 {
                
                WWMHelperClass.sendEventAnalytics(contentType: "3D", itemId: "LEARN", itemName: "")
                self.dismissRootViewController()
                //print("Learn to Meditate")
                handle = true
                    
                self.type = "learn"
                self.guided_type = ""
                    
                self.pushTimerGuidedLearnVC()
            }
            
            break
            
        case "Login":

            handle = true
            WWMHelperClass.sendEventAnalytics(contentType: "3D", itemId: "LOG_IN", itemName: "")
            
            let moodData = WWMHelperClass.fetchDB(dbName: "DBMoodMeter") as! [DBMoodMeter]
            if moodData.count < 1 {
                let rootViewController = self.window!.rootViewController as! UINavigationController
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMSplashLoaderVC") as! WWMSplashLoaderVC
                rootViewController.pushViewController(profileViewController, animated: false)
            }else if self.appPreffrence.getCheckEnterSignupLogin(){
                    //print("checkEnterSignupLogin is true login")
                if self.appPreference.isLogin() {
                  if !self.appPreference.isProfileComplete() {
                        
                        let rootViewController = self.window!.rootViewController as! UINavigationController
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                        rootViewController.pushViewController(profileViewController, animated: false)
                    }
                        
                }
                    
            }else if self.appPreference.isLogout(){
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                    rootViewController.pushViewController(profileViewController, animated: false)
            }else{
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                    rootViewController.pushViewController(profileViewController, animated: false)
            }
            
            break
        case "Signup":

            handle = true
            
            WWMHelperClass.sendEventAnalytics(contentType: "3D", itemId: "START_BEEJA", itemName: "")
            //isProfileComplete
            let moodData = WWMHelperClass.fetchDB(dbName: "DBMoodMeter") as! [DBMoodMeter]
            if moodData.count < 1 {
                let rootViewController = self.window!.rootViewController as! UINavigationController
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMSplashLoaderVC") as! WWMSplashLoaderVC
                rootViewController.pushViewController(profileViewController, animated: false)
            }else if self.appPreffrence.getCheckEnterSignupLogin(){
                //print("checkEnterSignupLogin is true signup")
                
                if self.appPreference.isLogin() {
                  if !self.appPreference.isProfileComplete() {
                        
                        let rootViewController = self.window!.rootViewController as! UINavigationController
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                        rootViewController.pushViewController(profileViewController, animated: false)
                    }
                        
                }
            }else{
                
                WWMHelperClass.loginSignupBool = true
                    
                let rootViewController = self.window!.rootViewController as! UINavigationController
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                rootViewController.pushViewController(profileViewController, animated: false)
                
            }
            
            break
        default:
            break
        }
        
        return handle
    }
    
    
    func pushTimerGuidedLearnVC(){
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    func dismissRootViewController(){
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            if let navcontroller = topController.children[0] as? UINavigationController{
                navcontroller.popToRootViewController(animated: false)
            }
        }
    }
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"      : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : self.type,
            "guided_type"   : self.guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "Appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                //print("result appdelegate meditation data... \(result) success meditationdata api WWMHomeTabVC background thread")
                
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
    }//3D touch code end*
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let vc = window?.rootViewController as? WWMStartTimerVC{
            vc.updateTimer()
        }
    }
    
    func showForceUpdate() {
        WWMWebServices.requestAPIWithBodyForceUpdate(urlString: "https://beeja.s3.eu-west-2.amazonaws.com/mobile/config/update.json", context: "AppDelegate") { (result, error, success) in
            if success {
                
                //print("appdelegate result... \(result)")
                
                //set url from backend using constant*
                if kBETA_ENABLED{
                    
                    //print("I'm running in a non-DEBUG mode")
                    
                    if let baseUrl = result["base_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                    }
                }else{
                    
                    //print("I'm running in DEBUG mode")
                    
                    if let baseUrl = result["staging_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                    }
                }//*end
                
                if let title = result["title"] as? String{
                    KUSERDEFAULTS.set(title, forKey: KFORCETOUPDATETITLE)
                }
                
                if let content = result["content"] as? String{
                    KUSERDEFAULTS.set(content, forKey: KFORCETOUPDATEDES)
                }
                
                if let button = result["button"] as? String{
                    KUSERDEFAULTS.set(button, forKey: KUPGRADEBUTTON)
                }
                
                if let version_name = result["version_name"] as? String{
                    KUSERDEFAULTS.set(version_name, forKey: kVERSION_NAME)
                }
                
                if let force_update = result["force_update"] as? Bool{
                    if force_update{
                        if self.needsUpdate(){
                            self.forceToUpdatePopUp()
                            //self.syncDataWithServer()
                        }else {
                            self.syncDataWithServer()
                        }
                    }else {
                        self.syncDataWithServer()
                    }
                }else {
                    self.syncDataWithServer()
                }
                
            }else {
                self.syncDataWithServer()
            }
            
        }
    }
    
    
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
                let _ = results[0]["version"] as? String
                let currentVersion = infoDictionary?["CFBundleShortVersionString"] as? String
                
                //print("appStoreVersion... \(String(describing: appStoreVersion)) currentVersion... \(String(describing: currentVersion)) AWS appVersion... \(KUSERDEFAULTS.string(forKey: kVERSION_NAME) ?? "")")
                
                if KUSERDEFAULTS.string(forKey: kVERSION_NAME) ?? "" != "" && currentVersion != ""{
                    
                    let awsVersionArray = (KUSERDEFAULTS.string(forKey: kVERSION_NAME)?.components(separatedBy: "."))!
                    let currentVersionArray = (currentVersion?.components(separatedBy: "."))!
                    
                    if awsVersionArray.count > 2 && currentVersionArray.count > 2{
                        
                        if Int(awsVersionArray[1])! < Int(currentVersionArray[1])!{
                            return false
                        }else if Int(awsVersionArray[0])! > Int(currentVersionArray[0])!{
                            return true
                        }else if Int(awsVersionArray[0])! < Int(currentVersionArray[0])!{
                            return false
                        }else if Int(awsVersionArray[2])! > Int(currentVersionArray[2])!{
                            return true
                        }
                    }
                }
            }
        }
        return false
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
        alertPopupView1.btnOK.setTitle(KUSERDEFAULTS.string(forKey: KUPGRADEBUTTON) ?? KUPDATE, for: .normal)
        alertPopupView1.btnClose.isHidden = true
        
        alertPopupView1.btnOK.addTarget(self, action: #selector(btnForceToUpdateDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @IBAction func btnForceToUpdateDoneAction(_ sender: Any) {
        //https://apps.apple.com/us/app/beeja-meditation/id1453359245
        UIApplication.shared.open(URL.init(string: "https://apps.apple.com/is/app/beeja-meditation/id1453359245")!, options: [:], completionHandler: nil)
        
    }


    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected {
            print("Call Connect -> ")
        }
        
        if call.isOutgoing {
            print("Call outGoing ")
        }
        
        if call.hasEnded {
            print("Call hasEnded ")
            
            KUSERDEFAULTS.set("true", forKey: "CallEndedIdentifier")
            NotificationCenter.default.post(name: Notification.Name("NotificationCallEndedIdentifier"), object: nil)

        }
        
        if call.isOnHold {
            print("Call onHold ")
        }
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
//        // called when user signs into spotify. Session data saved into user defaults, then notification posted to call updateAfterFirstLogin in ViewController.swift. Modeled off recommneded auth flow suggested by Spotify documentation
//
//        if auth.canHandle(auth.redirectURL) {
//            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
//
//                if error != nil {
//                    print(error?.localizedDescription)
//                    return
//                }
//                let userDefaults = UserDefaults.standard
//                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session)
//                print(sessionData)
//                userDefaults.set(sessionData, forKey: "SpotifySession")
//                userDefaults.synchronize()
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//            })
//            return true
//        }
//
//        return false
//
//    }
//
    
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            
            //appPreference
            self.showForceUpdate()
            
            self.appPreference.setConnectionType(value: "wifi")
            print("Reachable via WiFi")
        case .cellular:
            self.showForceUpdate()
            
            self.appPreference.setConnectionType(value: "cellular")
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }

    
    func syncDataWithServer() {
        if self.appPreference.isLogout() {
            self.syncMeditationCompleteData()
        }
    }
    
    func syncMeditationCompleteData() {
        let data = WWMHelperClass.fetchDB(dbName: "DBMeditationComplete") as! [DBMeditationComplete]
        if data.count > 0 {
            var arrData = [[String:Any]]()
            for dict in data {
                if let jsonResult = self.convertToDictionary(text: dict.meditationData ?? "") {
                    arrData.append(jsonResult)
                }
            }
            let param = ["offline_data":arrData]
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "AppDelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    self.appPreffrence.setSessionAvailableData(value: true)
                    WWMHelperClass.deletefromDb(dbName: "DBMeditationComplete")
                    self.syncAddJournalData()
                }
            }
        }else {
            syncAddJournalData()
        }
    }
    
    func syncAddJournalData() {
        let data = WWMHelperClass.fetchDB(dbName: "DBJournalData") as! [DBJournalData]
        if data.count > 0 {
            var arrData = [[String:Any]]()
            for dict in data {
                if let jsonResult = self.convertToDictionary(text: dict.journalData ?? "") {
                    arrData.append(jsonResult)
                }
            }
            let param = ["offline_data":arrData]
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, context: "AppDelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    WWMHelperClass.deletefromDb(dbName: "DBJournalData")
                    self.syncContactUsData()
                }
            }
        }else {
            self.syncContactUsData()
        }
    }
    
    func syncContactUsData() {
        let data = WWMHelperClass.fetchDB(dbName: "DBContactUs") as! [DBContactUs]
        if data.count > 0 {
            WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_SUPPORT, context: "AppDelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    WWMHelperClass.deletefromDb(dbName: "DBContactUs")
                    self.syncSettingAPI()
                }
            }
        }else {
            self.syncSettingAPI()
        }
    }
    
    func syncSettingAPI() {
        
        var settingData = DBSettings()
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            
            var meditation_data = [[String:Any]]()
            let meditationData = settingData.meditationData!.array as? [DBMeditationData]
            for dic in meditationData!{
                
                if dic.meditationName == "Beeja"{
                    self.min_limit = dic.min_limit ?? "94"
                    self.max_limit = dic.max_limit ?? "97"
                }
                
                let levels = dic.levels?.array as? [DBLevelData]
                var levelDic = [[String:Any]]()
                for level in levels! {
                    let leveldata = [
                        "level_id": level.levelId,
                        "isSelected": level.isLevelSelected,
                        "name": level.levelName!,
                        "prep_time": "\(level.prepTime)",
                        "meditation_time": "\(level.meditationTime)",
                        "rest_time": "\(level.restTime)",
                        "prep_min": "\(level.minPrep)",
                        "prep_max": "\(level.maxPrep)",
                        "med_min": "\(level.minMeditation)",
                        "med_max": "\(level.maxMeditation)",
                        "rest_min": "\(level.minRest)",
                        "rest_max": "\(level.maxRest)"
                        ] as [String : Any]
                    levelDic.append(leveldata)
                }
                
                if dic.min_limit == "" || dic.min_limit == nil{
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "setmyown" : dic.setmyown,
                                "min_limit" : self.min_limit,
                                "max_limit" : self.max_limit,
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }else{
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "setmyown" : dic.setmyown,
                                "min_limit" : dic.min_limit ?? "94",
                                "max_limit" : dic.max_limit ?? "97",
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }
            }
            //"IsMilestoneAndRewards"
            let group = [
                "startChime": settingData.startChime!,
                "endChime": settingData.endChime!,
                "finishChime": settingData.finishChime!,
                "intervalChime": settingData.intervalChime!,
                "ambientSound": settingData.ambientChime!,
                "moodMeterEnable": settingData.moodMeterEnable,
                "IsMorningReminder": settingData.isMorningReminder,
                "IsMilestoneAndRewards": settingData.isMilestoneAndRewards,
                "MorningReminderTime": settingData.morningReminderTime!,
                "IsAfternoonReminder": settingData.isAfterNoonReminder,
                "AfternoonReminderTime": settingData.afterNoonReminderTime!,
                "MantraID": settingData.mantraID,
                "LearnReminderTime": settingData.learnReminderTime!,
                "IsLearnReminder": settingData.isLearnReminder,
                "isThirtyDaysReminder":settingData.isThirtyDaysReminder,
                "thirtyDaysReminder":settingData.thirtyDaysReminder ?? "",
                "isTwentyoneDaysReminder":settingData.isTwentyoneDaysReminder,
                "twentyoneDaysReminder":settingData.twentyoneDaysReminder ?? "",
                "isEightWeekReminder":settingData.isEightWeekReminder,
                "eightWeekReminder":settingData.eightWeekReminder ?? "",
                "meditation_data" : meditation_data
                ] as [String : Any]
            
            let param = [
                "user_id": self.appPreference.getUserID(),
                "isJson": true,
                "group": group
                ] as [String : Any]
            
            //print("param delegte ... \(param)")
            
            WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "sync with appdelegate", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    if let _ = result["success"] as? Bool {
                        //print("setting appdelegate... \(result) settingapi appdelegate with background")
                    }
                }
            }
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("willResignActive.........")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //self.addShortCuts(application: application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if self.appPreference.isLogin(){
            if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                self.appPreference.setType(value: "learn")
                self.type = "learn"
                self.meditationApi()
                self.appPreference.set21ChallengeName(value: "")
            }
        }
        
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       
        if url.absoluteString.contains("fb") {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        } else if url.absoluteString.contains("beeja-app://getplaylist/"){
            
            if auth.canHandle(auth.redirectURL) {
                auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                    
                    if error != nil {
                        print(error?.localizedDescription ?? "error")
                        //return
                    }
                    if (session != nil) {
                        let userDefaults = UserDefaults.standard
                        let sessionData = NSKeyedArchiver.archivedData(withRootObject: session as Any)
                        print(sessionData)
                        userDefaults.set(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                    
                })
                return true
            }else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
            }
        }else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
        }
        return true
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        
        
      if let tabcontroller = self.window?.rootViewController as? UITabBarController {
        if let nav = tabcontroller.selectedViewController as? UINavigationController {

            if WWMHelperClass.galleryValue{
                WWMHelperClass.galleryValue = false
                return .portrait
            }else{
                if (nav.visibleViewController?.isKind(of: WWMVedioPlayerVC.classForCoder()))! {

                        //return .allButUpsideDown
                    return .all
                    }
                }
            }
        }

        return .portrait
    }
    
    
    // MARK:- Local Notification
    //Local Notification Request Authorization.
    func requestAuthorization(){
        center.requestAuthorization(options: [.alert, .sound]){(granted, error) in
            if error == nil{
                print("Permission Granted")
            }
        }
        center.delegate = self
    }
    
    func setLocalPush(){
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            self.days21Reminder()
            self.identifyReminderType(type: "morning")
            self.identifyReminderType(type: "afternoon")
            self.identifyReminderType(type: "learn")
            self.identifyReminderType(type: "30Days")
        }
    }
    
    func days21Reminder(){
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        //21days_challenge_local_pushnotification
        let reminder21DaysTime = self.appPreffrence.getReminder21DaysTime()
        if reminder21DaysTime != ""{
            let dateFormate = DateFormatter()
            dateFormate.locale = Locale.current
            dateFormate.locale = Locale(identifier: dateFormate.locale.identifier)
            dateFormate.dateFormat = "yyyy-MM-dd"
            
            let reminder21DaysDate = self.appPreffrence.getReminder21DaysDate()
            let currentDate = self.getCurrentDate()
            let currentDate1 = dateFormate.string(from: currentDate)
            let currentDate2 = dateFormate.date(from: currentDate1)
            
            //print("appdelegate*** reminder21DaysDate \(reminder21DaysDate) currentDate*** \(currentDate2 ?? Date())")
            if reminder21DaysDate == currentDate2{
                let dateFormate = DateFormatter()
                dateFormate.locale = Locale.current
                dateFormate.locale = Locale(identifier: dateFormate.locale.identifier)
                dateFormate.dateFormat = "dd:MM:yyyy"
                
                let locale = NSLocale.current
                let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
                var date: Date = Date()
                var strDate = dateFormate.string(from: Date())
                
                if formatter.contains("a") {
                    //print("phone is set to 12 hours")
                    //phone is set to 12 hours
                    
                    let morningReminderArray = reminder21DaysTime.components(separatedBy: ":")
                    if morningReminderArray.count > 0{
                        if Int(morningReminderArray[0]) ?? 0 > 11{
                            dateFormate.dateFormat = "dd-MM-yyyy"
                            strDate = dateFormate.string(from: Date())
                            let reminder21DaysTime1 = reminder21DaysTime.components(separatedBy: " ")
                            strDate = strDate + " \(reminder21DaysTime1[0])"
                            
                            //print("strDate 12 pm+++ \(strDate)")
                            date = self.getRequiredFormat(dateStrInTwentyFourHourFomat: strDate)
                        }else{
                            strDate = dateFormate.string(from: Date())
                            
                            if reminder21DaysTime.contains("AM") || reminder21DaysTime.contains("am") || reminder21DaysTime.contains("pm") || reminder21DaysTime.contains("PM"){
                                strDate = strDate + " \(reminder21DaysTime)"
                            }else{
                                strDate = strDate + " \(reminder21DaysTime) AM"
                            }
                            
                            dateFormate.dateFormat = "dd:MM:yyyy hh:mm a"
                            
                            //print("strDate+++ \(strDate)")
                            date = dateFormate.date(from: strDate)!
                        }
                    }
                } else {
                    //phone is set to 24 hours
                    //print("phone is set to 24 hours")
                    //strDate = strDate + " \(settingData.morningReminderTime!)"
                    
                    let morningReminderArray = reminder21DaysTime.components(separatedBy: ":")
                    if morningReminderArray.count > 0{
                        if Int(morningReminderArray[0]) ?? 0 > 11{
                            
                            if reminder21DaysTime.contains("p") || reminder21DaysTime.contains("a") || reminder21DaysTime.contains("A") || reminder21DaysTime.contains("P"){
                                dateFormate.dateFormat = "hh:mm a"
                            }else{
                                dateFormate.dateFormat = "HH:mm"
                            }
                            
                            let date11 = dateFormate.date(from: reminder21DaysTime)
                            dateFormate.dateFormat = "hh:mm"
                            let Date12 = dateFormate.string(from: date11!)
                            //print("date12... \(Date12)")
                            strDate = strDate + " " + Date12
                            //print("strDate... \(strDate)")
                        }else{
                            strDate = strDate + " \(reminder21DaysTime)"
                        }
                    }
                    
                    dateFormate.dateFormat = "dd:MM:yyyy hh:mm"
                    print(reminder21DaysTime )
                    
                    date = dateFormate.date(from: strDate)!
                    
                }//phone is set to 24 hours end***
                print(reminder21DaysTime )
                
                
                var settingData = DBSettings()
                if data.count > 0 {
                    settingData = data[0]
                }
                
                self.afterNoonMorningReminderFunc(settingData: settingData, date: date, type: "challenge21days")
                
                self.appPreffrence.setReminder21DaysTime(value: "")
            }
        }else{
            center.removePendingNotificationRequests(withIdentifiers: ["ChallengeReminder"])
        }
    }
    
    func identifyReminderType(type: String){
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        let settingData = data[0]
        
        var reminderTime: String?
        var isReminder: Bool?
        
        if type == "morning"{
            reminderTime = settingData.morningReminderTime ?? ""
            isReminder = settingData.isMorningReminder
        }else if type == "afternoon"{
            reminderTime = settingData.afterNoonReminderTime ?? ""
            isReminder = settingData.isAfterNoonReminder
        }else if type == "30Days"{
            reminderTime = settingData.thirtyDaysReminder ?? ""
            isReminder = settingData.isThirtyDaysReminder
        }else if type == "learn"{
            reminderTime = settingData.learnReminderTime ?? ""
            isReminder = settingData.isLearnReminder
        }
        
        if isReminder ?? false {
            if reminderTime != "" {
            let dateFormate = DateFormatter()
            dateFormate.locale = Locale.current
            dateFormate.locale = Locale(identifier: dateFormate.locale.identifier)
            dateFormate.dateFormat = "dd:MM:yyyy"
                
            let locale = NSLocale.current
            let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
            var date: Date = Date()
            var strDate = dateFormate.string(from: Date())

            if formatter.contains("a") {
                //print("phone is set to 12 hours")

                let morningReminderArray = reminderTime?.components(separatedBy: ":")
                if morningReminderArray?.count ?? 0 > 0{
                    if Int(morningReminderArray?[0] ?? "0") ?? 0 > 11{
                        dateFormate.dateFormat = "dd-MM-yyyy"
                        strDate = dateFormate.string(from: Date())
                        let morningReminderTime1 = reminderTime?.components(separatedBy: " ")
                        strDate = strDate + " \(morningReminderTime1![0])"
                        
                        //print("morinit++ \(strDate)")
                        date = self.getRequiredFormat(dateStrInTwentyFourHourFomat: strDate)
                    }else{
                        strDate = dateFormate.string(from: Date())
                                                    
                        if reminderTime!.contains("AM") || reminderTime!.contains("am") || reminderTime!.contains("pm") || reminderTime!.contains("PM"){

                            strDate = strDate + " \(reminderTime!)"
                        }else{
                            strDate = strDate + " \(reminderTime!) AM"
                        }
                        
                        dateFormate.dateFormat = "dd:MM:yyyy hh:mm a"
                        date = dateFormate.date(from: strDate)!
                    }
                }
            } else {
                //phone is set to 24 hours
                //print("phone is set to 24 hours")
                //strDate = strDate + " \(settingData.morningReminderTime!)"
                    
                let morningReminderArray = reminderTime?.components(separatedBy: ":")
                if morningReminderArray?.count ?? 0 > 0{
                    if Int(morningReminderArray?[0] ?? "0") ?? 0 > 11{
                        
                        if reminderTime!.contains("p") || reminderTime!.contains("a") || reminderTime!.contains("A") || reminderTime!.contains("P"){
                            dateFormate.dateFormat = "hh:mm a"
                        }else{
                            dateFormate.dateFormat = "HH:mm"
                        }
                        
                        let date11 = dateFormate.date(from: reminderTime ?? "08:00")
                        dateFormate.dateFormat = "hh:mm"
                        let Date12 = dateFormate.string(from: date11!)
                        //print("date12... \(Date12)")
                        strDate = strDate + " " + Date12
                        //print("strDate... \(strDate)")
                    }else{
                        
                        if reminderTime!.contains("AM") || reminderTime!.contains("am") || reminderTime!.contains("pm") || reminderTime!.contains("PM") {
                            
                        let morningReminderTime1 = reminderTime?.components(separatedBy: " ")
                            strDate = strDate + " \(morningReminderTime1![0])"
                        }else{
                            strDate = strDate + " \(reminderTime!)"
                        }
                    }
                }
                
                //print("strDate+++ \(strDate)")
                    
                dateFormate.dateFormat = "dd:MM:yyyy hh:mm"
                print(reminderTime ?? "08:00")
                
                date = dateFormate.date(from: strDate)!
                
            }//phone is set to 24 hours end***
                print(reminderTime ?? "")
                
                if type == "learn"{
                    self.learnReminderFunc(settingData: settingData, date: date)
                }else{
                    self.afterNoonMorningReminderFunc(settingData: settingData, date: date, type: type)
                }
            }//isMorningReminder not nil****
        }else {
            center.removePendingNotificationRequests(withIdentifiers: ["MorningTimer"])
        }

    }
    
    func getCurrentDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = NSTimeZone.local
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    func getRequiredFormat(dateStrInTwentyFourHourFomat: String) -> Date{

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)

        let date: Date = dateFormatter.date(from: dateStrInTwentyFourHourFomat)!
        print(date)
        return date
    }
    
    func afterNoonMorningReminderFunc(settingData: DBSettings, date: Date, type: String){
        //let date = dateFormate.date(from: strDate)
        //print(date!)
        var arrTemp: [String]?
        if type == "morning"{
            arrTemp = settingData.morningReminderTime?.components(separatedBy: ":")
        }else if type == "afternoon"{
            arrTemp = settingData.afterNoonReminderTime?.components(separatedBy: ":")
        }else if type == "30Days"{
            arrTemp = settingData.thirtyDaysReminder?.components(separatedBy: ":")
        }
        
        var str = KGOODMORNING
        if type == "challenge21days"{
            str = KCHALLENGEREMINDER
        }else if type == "30Days"{
            str = "It’s time to start 30-Days challenge"
        }else{
            if arrTemp?.count == 2 {
                let hours = Int(arrTemp?[0] ?? "0") ?? 0
                let minutes = Int(arrTemp?[1] ?? "0") ?? 0
                let seconds = hours*60 + minutes
                if seconds < 720 {
                    str = KGOODMORNING
                }else if 720 <= seconds && seconds < 1080 {
                    str = KGOODAFTERNOON
                }else {
                    str = KGOODEVENING
                }
            }
        }
        
        // let timeStemp = Int(date!.timeIntervalSince1970)
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: str, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: KITSTIMEFORBEEJA, arguments: nil)
        content.sound = UNNotificationSound.default
        
        var identifire: String = ""
        
        if type == "morning"{
            content.threadIdentifier = "local-notifications-MorningReminder"
            identifire = "MorningTimer"
        }else if type == "afternoon"{
            content.threadIdentifier = "local-notifications-AfterNoonReminder"
            identifire = "AfternoonTimer"
        }else if type == "30Days"{
            content.threadIdentifier = "local-notifications-Challenge30DaysReminder"
            identifire = "ChallengeReminder"
        }else{
            content.threadIdentifier = "local-notifications-Challenge21DaysReminder"
            identifire = "ChallengeReminder"
        }
        
        
        var toDateComponents = Calendar.current.dateComponents([.hour,.minute], from: date)
        toDateComponents.second = 0
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifire, content: content, trigger: notificationTrigger)
        //notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        
        center.add(request){ (error) in
            if error == nil {
                print("schedule push succeed")
            }
        }
    }
    
    
    func learnReminderFunc(settingData: DBSettings, date: Date){
            let str = KLEARNTOMEDITATE1
            
            // let timeStemp = Int(date!.timeIntervalSince1970)
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey:str, arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: KTIMETOLEARN, arguments: nil)
            content.sound = UNNotificationSound.default
            content.threadIdentifier = "local-notifications-Learn"
               
    
        //local_pushnotification_learn_timer_guided
        //value = 1 means tommorrow clicked
            if self.value == 1{
                if self.date == date{
                    let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                        
                        
                    let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                    center.add(request){ (error) in
                        if error == nil {
                            print("schedule push succeed")
                        }
                    }
                }
                //print("tomm... date... \(self.date) date1... \(date)")
            }else if self.value == 2{
                //value = 2 means everyday clicked
                
                if self.date > date{
                    let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                        
                        
                    let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                    center.add(request){ (error) in
                        if error == nil {
                            print("schedule push succeed")
                        }
                    }
                }
                //print("everyday... date... \(self.date) date1... \(date)")
            }else{
                let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                    
                    
                let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                center.add(request){ (error) in
                    if error == nil {
                        print("schedule push succeed")
                    }
                }
            }
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if self.appPreffrence.isLogin(){
            if let type = userInfo["type"] as? String{
                if type == "force_logout"{
                    //print("force_logout_status+++ type \(type)")
                    self.appPreference.setForceLogout(value: "force_logout_true")
                    UIApplication.shared.keyWindow?.rootViewController = self.animatedTabBarController()
                }
            }
        }
        
        
        
        // Print full message.
        print("userNotificationCenter *** .. \(userInfo)")
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print("userNotificationCenter .. \(userInfo)")
        
        
        if self.appPreffrence.isLogin(){
            if let type = userInfo["type"] as? String{
                if type == "force_logout"{
                    //print("force_logout_status+++ type \(type)")
                    self.appPreference.setForceLogout(value: "force_logout_true")
                    UIApplication.shared.keyWindow?.rootViewController = self.animatedTabBarController()
                }
            }
            
            if let milestoneType = userInfo["milestoneType"] as? String{
                if milestoneType == "hours_meditate"{
                    
                    /*  let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                     
                     vc.milestoneType = "hours_meditate"
                     UIApplication.shared.keyWindow?.rootViewController = vc*/
                    
                    WWMHelperClass.milestoneType = "hours_meditate"
                    
                    UIApplication.shared.keyWindow?.rootViewController = self.animatedTabBarController()
                    
                }else if milestoneType == "consecutive_days"{
                    
                    /*  let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                     
                     vc.milestoneType = "consecutive_days"
                     UIApplication.shared.keyWindow?.rootViewController = vc*/
                    
                    WWMHelperClass.milestoneType = "consecutive_days"
                    UIApplication.shared.keyWindow?.rootViewController = self.animatedTabBarController()
                }else{
                    
                    /*   let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                     
                     vc.milestoneType = "sessions"
                     UIApplication.shared.keyWindow?.rootViewController = vc*/
                    
                    WWMHelperClass.milestoneType = "sessions"
                    UIApplication.shared.keyWindow?.rootViewController = self.animatedTabBarController()
                }
            }
        }
        
        
        completionHandler()
    }
    // MARK:- Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.kpis.FamilyTree" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "WWMDatabase", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let option = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: option)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            //abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}



extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        appPreference.setDeviceToken(value: fcmToken)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
    func animatedTabBarController()-> UITabBarController? {
        if self.tabBarController == nil {
            self.tabBarController = lottieSytleTabbar()
        }
        return self.tabBarController
    }
    
    func lottieSytleTabbar() -> WWMTabBarVC {
        UITabBar.appearance().barTintColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyBoard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        
        
        
        //        let navigationVCCommunity = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCCommunity") as! UINavigationController
        //        let navigationVCProgress = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCProgress") as! UINavigationController
        //        let navigationVCWisdom = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCWisdom") as! UINavigationController
        //        let navigationVCGuided = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCGuided") as! UINavigationController
        //        let navigationVCTimer = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCTimer") as! UINavigationController
        //        let navigationVCLearn = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCLearn") as! UINavigationController
        //        let navigationVCHome = storyBoard.instantiateViewController(withIdentifier: "WWMNavigationVCHome") as! UINavigationController
        //
        //
        //        navigationVCHome.tabBarItem = ESTabBarItem.init(WWMHomeAnimateContentView(), title: "Home", image: nil, selectedImage: nil)
        //        navigationVCCommunity.tabBarItem = ESTabBarItem.init(WWMCommunityAnimateContentView(), title: "Community", image: nil, selectedImage: nil)
        //        navigationVCGuided.tabBarItem = ESTabBarItem.init(WWMGuideAnimateContentView(), title: "Guided", image: nil, selectedImage: nil)
        //        navigationVCTimer.tabBarItem = ESTabBarItem.init(WWMTimerAnimateContentView(), title: "Timer", image: nil, selectedImage: nil)
        //        navigationVCLearn.tabBarItem = ESTabBarItem.init(WWMLearnAnimateContentView(), title: "Learn", image: nil, selectedImage: nil)
        //        navigationVCWisdom.tabBarItem = ESTabBarItem.init(WWMWisdomAnimateContentView(), title: "Wisdom", image: nil, selectedImage: nil)
        //        navigationVCProgress.tabBarItem = ESTabBarItem.init(WWMProgressAnimateContentView(), title: "Progress", image: nil, selectedImage: nil)
        //        tabBarController.viewControllers = [navigationVCHome, navigationVCCommunity,navigationVCGuided,navigationVCTimer,navigationVCLearn, navigationVCWisdom, navigationVCProgress]
        
        return tabBarController
    }
    
}

