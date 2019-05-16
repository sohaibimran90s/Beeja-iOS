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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    
    fileprivate let redirectUri = URL(string:"beeja-med-test-app://beeja-med-test-callback")!
    fileprivate let clientIdentifier = "2fd82c511bd74915b2b16ff1903eeb2b"
    fileprivate let name = "spotify"
    static fileprivate let kAccessTokenKey = "access-token-key"
    
    var window: UIWindow?
    let appPreference = WWMAppPreference()
    let center = UNUserNotificationCenter.current()
    let reachability = Reachability()
     var auth = SPTAuth()
    
    static func sharedDelegate () -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    //MARK: Appdelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        auth.redirectURL = URL(string: "Beeja-App://GetPlayList")
        auth.sessionUserDefaultsKey = "current session"
        
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        print(UIDevice.current.identifierForVendor!.uuidString)
        // GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if !application.isRegisteredForRemoteNotifications {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        }
        
        // To check the internet reachability
    
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        
        //        // Analytics
        //
        //        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
        //            AnalyticsParameterItemID: "id-Beeja-App-Started",
        //            AnalyticsParameterItemName: "Roshan Login in Beeja app",
        //            AnalyticsParameterContentType: "App Login"
        //            ])
        self.requestAuthorization()
        self.setLocalPush()
        
        return true
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
            self.syncDataWithServer()
            print("Reachable via WiFi")
        case .cellular:
            self.syncDataWithServer()
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
            let settingData = data[0]
            if settingData.isMorningReminder {
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
                
                
            }else {
                center.removePendingNotificationRequests(withIdentifiers: ["MorningTimer"])
            }
            if settingData.isAfterNoonReminder {
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
                
                
            }else {
                center.removePendingNotificationRequests(withIdentifiers: ["AfternoonTimer"])
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
    }
    // MARK:- Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        appPreference.setDeviceToken(value: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
        appPreference.setDeviceToken(value: "fhsdfhddjhfkj")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
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
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
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

