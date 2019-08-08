//
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
import Crashlytics
import Fabric
import CallKit


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
    
    static func sharedDelegate () -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var callObserver = CXCallObserver()
    
    //MARK: Appdelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        auth.redirectURL = URL(string: "Beeja-App://GetPlayList")
        auth.sessionUserDefaultsKey = "current session"
        
        IQKeyboardManager.shared.enable = true
      //  IQKeyboardManager.shared.enableDebugging = true
        //IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Next"

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        print(UIDevice.current.identifierForVendor!.uuidString)
        // GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
            print("could not start reachability notifier")
        }
        
        
                // Analytics
        
       Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-Beeja-App-Started",
                    AnalyticsParameterItemName: "Roshan Login in Beeja app",
                    AnalyticsParameterContentType: "App Login"
                    ])
        self.requestAuthorization()
        self.setLocalPush()
        
        callObserver.setDelegate(self, queue: nil)
        
       // Crashlytics.sharedInstance().crash()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("mmdkdfkdfkdfkdj")
        if let vc = window?.rootViewController as? WWMStartTimerVC{
            vc.updateTimer()
        }
    }
    
    func showForceUpdate() {
        WWMWebServices.requestAPIWithBodyForceUpdate(urlString: "https://beeja.s3.eu-west-2.amazonaws.com/mobile/config/update.json") { (result, error, success) in
            if success {
                if let baseUrl = result["base_url"] as? String{
                    KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                }else {
                    KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                }
                
                if let title = result["title"] as? String{
                    KUSERDEFAULTS.set(title, forKey: KFORCETOUPDATETITLE)
                }
                
                if let content = result["content"] as? String{
                    KUSERDEFAULTS.set(content, forKey: KFORCETOUPDATEDES)
                }
                
                if let button = result["button"] as? String{
                    KUSERDEFAULTS.set(button, forKey: KUPGRADEBUTTON)
                }
                
                if let force_update = result["force_update"] as? Bool{
                    if force_update{
                        if self.needsUpdate(){
                            self.forceToUpdatePopUp()
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
    
    func forceToUpdatePopUp(){
        
        alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView1.isRemove = false
        alertPopupView1.btnOK.layer.borderWidth = 2.0
        alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView1.lblTitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATETITLE) ?? "New Version Available"
        alertPopupView1.lblSubtitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATEDES) ?? "There is a newer version available for download! Please update the app by visiting the Apple Store."
        alertPopupView1.btnOK.setTitle(KUSERDEFAULTS.string(forKey: KUPGRADEBUTTON) ?? "Update", for: .normal)
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
            self.showForceUpdate()
            
            print("Reachable via WiFi")
        case .cellular:
            self.showForceUpdate()
            
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
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
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
    
    func syncAddSessionData() {
        let data = WWMHelperClass.fetchDB(dbName: "DBAddSession") as! [DBAddSession]
        if data.count > 0 {
            var arrData = [[String:Any]]()
            for dict in data {
                if let jsonResult = self.convertToDictionary(text: dict.addSession ?? "") {
                    arrData.append(jsonResult)
                }
            }
            let param = ["offline_data":arrData]
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDSESSION, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    WWMHelperClass.deletefromDb(dbName: "DBAddSession")
                    self.syncAddJournalData()
                }
            }
            
        }else {
            self.syncAddJournalData()
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
            WWMWebServices.requestAPIWithBody(param: param, urlString: URL_ADDJOURNAL, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
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
            WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_SUPPORT, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    WWMHelperClass.deletefromDb(dbName: "DBContactUs")
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
        
        
       
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       
        if url.absoluteString.contains("fb") {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }else if url.absoluteString.contains("beeja-app://getplaylist/"){
            
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

                        return .allButUpsideDown
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
        
        
        if self.value == 1{
            print("tomm")
            print("date... \(date)")
        }else if self.value == 2{
            print("everyday")
            print("date... \(date)")
        }else{
            print("defult")
            print("date... \(date)")
        }
        
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            let settingData = data[0]
            if settingData.isMorningReminder {
                if settingData.morningReminderTime != "" {
                let dateFormate = DateFormatter()
                dateFormate.locale = NSLocale.current
                dateFormate.dateFormat = "dd:MM:yyyy"
                var strDate = dateFormate.string(from: Date())
                strDate = strDate + " \(settingData.morningReminderTime!)"
                dateFormate.dateFormat = "dd:MM:yyyy HH:mm"
                print(settingData.morningReminderTime!)
                let date = dateFormate.date(from: strDate)
                let arrTemp = settingData.morningReminderTime?.components(separatedBy: ":")
                var str = "Good Morning!"
                if arrTemp?.count == 2 {
                    let hours = Int(arrTemp?[0] ?? "0") ?? 0
                    let minutes = Int(arrTemp?[1] ?? "0") ?? 0
                    let seconds = hours*60 + minutes
                    if seconds < 720 {
                        str = "Good Morning!"
                    }else if 720 <= seconds && seconds < 1080 {
                        str = "Good Afternoon!"
                    }else {
                        str = "Good Evening!"
                    }
                }
 
                // let timeStemp = Int(date!.timeIntervalSince1970)
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey:str, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "It's time for Beeja.", arguments: nil)
                content.sound = UNNotificationSound.default
                content.threadIdentifier = "local-notifications-MorningReminder"
                //print(Int(Date().timeIntervalSince1970))
                //print(timeStemp)
                //let time =  timeStemp - Int(Date().timeIntervalSince1970)
                // let toDateComponents = NSCalendar.currentCalendar.components([.Hour, .Minute], fromDate: timeStemp!)
                // let toDateComponents = Calendar.current.component([.hour, .minute], from: timeStemp!)
                let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                
                //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: true)
                let request = UNNotificationRequest(identifier: "MorningTimer", content: content, trigger: notificationTrigger)
                center.add(request){ (error) in
                    if error == nil {
                        print("schedule push succeed")
                    }
                }
                
                }
            }else {
                center.removePendingNotificationRequests(withIdentifiers: ["MorningTimer"])
            }
            if settingData.isAfterNoonReminder {
                if settingData.afterNoonReminderTime != "" {
                let dateFormate = DateFormatter()
                dateFormate.locale = NSLocale.current
                dateFormate.dateFormat = "dd:MM:yyyy"
                var strDate = dateFormate.string(from: Date())
                strDate = strDate + " \(settingData.afterNoonReminderTime!)"
                dateFormate.dateFormat = "dd:MM:yyyy HH:mm"
                print(settingData.afterNoonReminderTime!)
                let date = dateFormate.date(from: strDate)
                print(date!)
                let arrTemp = settingData.afterNoonReminderTime?.components(separatedBy: ":")
                var str = "Good Morning!"
                if arrTemp?.count == 2 {
                    let hours = Int(arrTemp?[0] ?? "0") ?? 0
                    let minutes = Int(arrTemp?[1] ?? "0") ?? 0
                    let seconds = hours*60 + minutes
                    if seconds < 720 {
                        str = "Good Morning!"
                    }else if 720 <= seconds && seconds < 1080 {
                        str = "Good Afternoon!"
                    }else {
                        str = "Good Evening!"
                    }
                    
                }
                // let timeStemp = Int(date!.timeIntervalSince1970)
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: str, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "It's time for Beeja.", arguments: nil)
                content.sound = UNNotificationSound.default
                content.threadIdentifier = "local-notifications-AfterNoonReminder"
                // print(Int(Date().timeIntervalSince1970))
                // print(timeStemp)
                //let time =  timeStemp - Int(Date().timeIntervalSince1970)
                // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
                var toDateComponents = Calendar.current.dateComponents([.hour,.minute], from: date!)
                toDateComponents.second = 0
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "AfternoonTimer", content: content, trigger: notificationTrigger)
                //notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
                
                center.add(request){ (error) in
                    if error == nil {
                        print("schedule push succeed")
                    }
                }
              }
                
            }else {
                center.removePendingNotificationRequests(withIdentifiers: ["AfternoonTimer"])
            }
            
            if settingData.isLearnReminder {
                if settingData.learnReminderTime != "" {
                let dateFormate = DateFormatter()
                dateFormate.locale = NSLocale.current
                dateFormate.dateFormat = "dd:MM:yyyy"
                    
                var strDate = dateFormate.string(from: Date())
                strDate = strDate + " \(settingData.learnReminderTime ?? "14:00")"
                dateFormate.dateFormat = "dd:MM:yyyy HH:mm"
                    
                let date = dateFormate.date(from: strDate)
                let arrTemp = settingData.learnReminderTime?.components(separatedBy: ":")
                let str = "Learn to meditate"
                
                // let timeStemp = Int(date!.timeIntervalSince1970)
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey:str, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "It's time to learn beeja meditation", arguments: nil)
                content.sound = UNNotificationSound.default
                content.threadIdentifier = "local-notifications-Learn"
                    
                    
                if self.value == 1{
                    if self.date == date{
                        let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
                        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                            
                            
                        let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                        center.add(request){ (error) in
                            if error == nil {
                                print("schedule push succeed")
                            }
                        }
                    }
                    print("tomm... date... \(self.date) date1... \(date!)")
                }else if self.value == 2{
                    if self.date > date!{
                        let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
                        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                            
                            
                        let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                        center.add(request){ (error) in
                            if error == nil {
                                print("schedule push succeed")
                            }
                        }
                    }
                    print("everyday... date... \(self.date) date1... \(date!)")
                }else{
                    let toDateComponents = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: toDateComponents, repeats: true)
                        
                        
                    let request = UNNotificationRequest(identifier: "LearnReminder", content: content, trigger: notificationTrigger)
                    center.add(request){ (error) in
                        if error == nil {
                            print("schedule push succeed")
                        }
                    }
                }
              }//end if settingData.learnReminderTime != ""
            }else {
                center.removePendingNotificationRequests(withIdentifiers: ["LearnReminder"])
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
        print("userNotificationCenter .. \(userInfo)")
        
        if let milestoneType = userInfo["milestoneType"] as? String{
            if milestoneType == "hours_meditate"{
   
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                
                vc.milestoneType = "hours_meditate"
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if milestoneType == "consecutive_days"{
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                
                vc.milestoneType = "consecutive_days"
                UIApplication.shared.keyWindow?.rootViewController = vc
            }else{
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                
                vc.milestoneType = "sessions"
                UIApplication.shared.keyWindow?.rootViewController = vc
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
}

