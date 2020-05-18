//
//  WWMHelperClass.swift
//  Meditation
//
//  Created by Roshan Kumawat on 21/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SystemConfiguration
import Lottie
import Firebase

class WWMHelperClass {
    
    static var alertPopupView = WWMAlertController()
    static var view1 = UIView()
    static var animationView = AnimationView()
    static var galleryValue = false
    static var loader_register = false
    static var milestoneType: String = ""
    static var selectedType: String = ""
    static var days21StepNo: String = ""
    
    //learn
    static var step_audio: String = ""
    static var timer_audio: String = ""
    static var outro_audio: String = ""
    static var step_title: String = ""
    static var total_paid: Int = 0
    static var mantra_id: Int = 1
    static var step_id: Int = 1
    static var value: String = ""
    static var timerCount: Int = 0
    static var challenge7DayCount: Int = 0
    static var stepsCompleted = false
    
    static var xlpager = ""
    static var checkNinetyFivePer = 0
    
    //Analytic %age
    static var complete_percentage: String = "0"
    
    //3D-Touch
    static var loginSignupBool = false
    static var appPreffrence = WWMAppPreference()
    
    // Analytics
    class func sendEventAnalytics(contentType:String, itemId:String, itemName:String) {
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//            AnalyticsParameterItemID: "id-Beeja-App-Started",
//            AnalyticsParameterItemName: "Roshan Login in Beeja app",
//            AnalyticsParameterContentType: "App Login"
//            ])
        if itemName == "" {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: "\(contentType)_\(itemId)"
                ])
        }else {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterContentType: "\(contentType)_\(itemId)_\(itemName)"
            ])
        }
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func showPopupAlertController(sender : Any, message : String, title : String) -> Void{
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = title
        alertPopupView.lblSubtitle.text = message
        alertPopupView.btnClose.isHidden = true
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
//    class func showLoader(on view: UIView) {
//        DispatchQueue.main.async(execute: {() -> Void in
//            let imageView = UIImageView.init(frame: CGRect.init(x: view.frame.size.width/2 - 25, y: view.frame.size.height/2 - 25, width: 50, height: 50))
//            imageView.image = UIImage.gifImageWithName("ee_loading_img")
//            view.addSubview(imageView)
//        })
//    }
    
//    class func hideLoader(fromView view:UIView) {
//        DispatchQueue.main.async(execute: {() -> Void in
//            let subviewsEnum :NSEnumerator = (view.subviews as NSArray).reverseObjectEnumerator()
//            _ = UIView();
//            for subview in subviewsEnum{
//                if (subview is UIImageView) {
//                    (subview as AnyObject).removeFromSuperview()
//                }
//            }
//        })
//    }
    
    
    class func showLoaderAnimate(on view: UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
            
            //imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            //imageView.image = UIImage(named: "Background_Splash")
            animationView = AnimationView(name: "loader")
            //view1.isHidden = false
            view1 = UIView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            view1.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            animationView.frame = CGRect(x: view.frame.size.width/2 - 200, y: view.frame.size.height/2 - 200, width: 400, height: 400)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
           
            //view.addSubview(imageView)
            view1.addSubview(animationView)
            view.addSubview(view1)
            
        })
    }
    
    class func hideLoaderAnimate(on view: UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
            
            animationView.stop()
            view1.removeFromSuperview()
            //self.imageView.isHidden = true
        })
    }
    
    class func showActivity(on view: UIView, with color : UIColor) {
        DispatchQueue.main.async(execute: {() -> Void in
            let indicator = UIActivityIndicatorView(style: .gray)
            let halfButtonHeight: CGFloat = view.bounds.size.height / 2
            let buttonWidth: CGFloat = view.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth - buttonWidth / 2, y: halfButtonHeight)
            indicator.color = color
            view.addSubview(indicator)
            indicator.startAnimating()
        })
    }
    
    class func hideActivity(fromView view: UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
            let subviewsEnum :NSEnumerator = (view.subviews as NSArray).reverseObjectEnumerator()
            _ = UIView();
            for subview in subviewsEnum{
                if (subview is UIActivityIndicatorView) {
                    (subview as? UIActivityIndicatorView)?.stopAnimating()
                    (subview as AnyObject).removeFromSuperview()
                }
            }
        })
    }
    
    class func addShadowToView(view:UIView, radius:CGFloat, height:CGFloat) -> Void {
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor .groupTableViewBackground.cgColor
        view.layer.shadowColor = UIColor .darkGray.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = radius
        
        view.layer.shadowOffset = CGSize.init(width: 0.0, height: height)
    }
    
    class func addShadowToView(view:UIView, radius:CGFloat) -> Void {
        view.layer.masksToBounds = false
        //view.layer.borderColor = UIColor .groupTableViewBackground.cgColor
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = radius
        
        view.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.0)
    }
    
    class func validateEmail(EmailAddress: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: EmailAddress)
    }
    
    class func getLength(mobileNumber: String) -> Int {
        
        var strMobile =  mobileNumber;
        strMobile = strMobile.replacingOccurrences(of: "(", with: "")
        strMobile = strMobile.replacingOccurrences(of: ")", with: "")
        strMobile = strMobile.replacingOccurrences(of: " ", with: "")
        strMobile = strMobile.replacingOccurrences(of: "-", with: "")
        strMobile = strMobile.replacingOccurrences(of: "+", with: "")
        
        //Calculate lenght of string
        let length = strMobile.count;
        
        return length
    }
    
    // MARK : Build Version
    
    class func getVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString")
        let buildNo = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        print(buildNo ?? "")
        return "v\(version ?? "")"
    }
    
    class func getBuildVersion() -> String {
        let buildNo = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        print("build no\(buildNo ?? "")")
        return "b\(buildNo ?? "")"
    }
    
    class func daysLeft(expiryDate: String) -> Int{
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        if let _ = dateFormatter.date(from: expiryDate){
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        }
        
        let currentDateString = dateFormatter.string(from: Date())
        let currentDate = self.getExpireDate(expiryDate: currentDateString, formatter: dateFormatter)
        let expireDate = self.getExpireDate(expiryDate: expiryDate, formatter: dateFormatter)
        
        if expireDate > currentDate{
            let day =  Calendar.current.dateComponents([.day], from: currentDate, to: expireDate ).day ?? 0
            print("day..... \(day) currentDate++ \(currentDate) expireDate... \(expireDate)")
            return day
        }else{
            return -1
        }
    }
    
    class func dateComparison(expiryDate: String) -> Int{
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
        if let _ = dateFormatter.date(from: expiryDate){
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        }
        
        let currentDateString = dateFormatter.string(from: Date())
        let expireDate = self.getExpireDate(expiryDate: expiryDate, formatter: dateFormatter)
        let currentDate = self.getExpireDate(expiryDate: currentDateString, formatter: dateFormatter)
      
        print("currentDate..... \(currentDate) expireDate---- \(expireDate)")
        if currentDate > expireDate {
            KUSERDEFAULTS.set(true, forKey: "getPrePostMoodBool")
            return 1
        }else{
            KUSERDEFAULTS.set(false, forKey: "getPrePostMoodBool")
            return 0
        }
    }
    
    class func getExpireDate(expiryDate: String, formatter: DateFormatter) -> Date{

//        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.locale = Locale.current
        formatter.locale = Locale(identifier: formatter.locale.identifier)
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let expireDate = formatter.date(from: expiryDate)
            else {
                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                let newExpireDate = formatter.date(from: expiryDate)
                print("12 Hour - \(newExpireDate ?? Date())")
                return newExpireDate!
        }
        
        print("24 Hour - \(expireDate)")
        return expireDate
    }
    
    class func dateComparison1(expiryDate: String) -> (Int, Int, Int){
        
        var date_completed: String = ""
        if expiryDate != ""{
           let date1 = expiryDate.components(separatedBy: " ")
            date_completed = date1[0]
        }
                
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDateString = dateFormatter.string(from: Date())
        var currentDate = dateFormatter.date(from: currentDateString)!
        let expireDate = dateFormatter.date(from: date_completed) ?? currentDate
        let day =  Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        
        if currentDate == expireDate{
            if let _ = dateFormatter.date(from: expiryDate){
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }else{
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            }
            
//            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
            currentDate = dateFormatter.date(from: dateFormatter.string(from: Date()))!
            let expirDate = dateFormatter.date(from: expiryDate) ?? currentDate
            
            let second =  Calendar.current.dateComponents([.second], from: currentDate, to: expirDate).second ?? 0
            let min =  Calendar.current.dateComponents([.minute], from: currentDate, to: expirDate).minute ?? 0
            print("day..... \(day) second..... \(second) expiryDate... \(expirDate) currentDate... \(currentDate) min... \(min) date_completed... \(date_completed)")
            return (1, day, second)
        }else{
            return (0, day, 0)
        }
    }
    
    //MARK:- Database Methods
    
    class func fetchDB(dbName:String) -> [Any] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!
    }
    
    class func deletefromDb(dbName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let param = try? managedContext.fetch(fetchRequest)
        for object in param! {
            managedContext.delete(object as! NSManagedObject)
            do {
                try managedContext.save()
                
            } catch {
                print(error)
            }
        }
    }
    
    class func deleteRowfromDb(dbName: String, id: String, type: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate(format: "\(type) = %@", id)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let param = try? managedContext.fetch(fetchRequest)
        for object in param! {
            managedContext.delete(object as! NSManagedObject)
            do {
                try managedContext.save()
                
            } catch {
                print(error)
            }
        }
    }
    
    class func updateJournalfromDb(dbName: String, index: Int, data: String, meditation_type: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "meditation_type == %@", meditation_type)
        
        do{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let fetchDataJournal = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = fetchDataJournal[index] as! NSManagedObject
            print("data...+++ \(data)")
            objectUpdate.setValue(data, forKey: "data")
            objectUpdate.setValue(meditation_type, forKey: "meditation_type")
            
            do{
                try managedContext.save()
            }catch{
                print("error journal...")
            }
            
        }catch{
            print("error update cart...")
        }
    }
    
    class func fetchEntity(dbName : String) -> NSManagedObject {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let entity =  NSEntityDescription.entity(forEntityName: dbName,
                                                 in:appDelegate.managedObjectContext)
        let managedObject = NSManagedObject.init(entity: entity!, insertInto: appDelegate.managedObjectContext)
        return managedObject
    }
    
    class func saveDb() {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.managedObjectContext.save()
            
        } catch {
            print(error)
        }
    }
    
    class func fetchNinetyFivePercentFilterDB(name: String, dbName: String, type: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "\(type) == %@", name)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
    
    class func addNinetyFivePercentData(type: String){
        
        print("selectedMeditation*** \(type)")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBNinetyFivePercent") as! [DBNinetyFivePercent]
        if data.count > 0 {
            let ninetyFivePercentArray = WWMHelperClass.fetchNinetyFivePercentFilterDB(name: type, dbName: "DBNinetyFivePercent", type: "meditation_name")
            
            var flag = 0
            for dict in ninetyFivePercentArray{
                let meditation_name = (dict as AnyObject).meditation_name as? String
                if meditation_name == type{
                    flag = 1
                    break
                }
            }
            
            if flag == 0{
                let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
                
                dbNinetyFivePercent.meditation_name = type
                dbNinetyFivePercent.meditation_value = "0"
            }
            
        }else{
            let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
            
            dbNinetyFivePercent.meditation_name = type
            dbNinetyFivePercent.meditation_value = "0"
        }
        
        WWMHelperClass.saveDb()
    }
    
    class func ninetyFivePercentMsg(type: String) -> (String, String, String){
        
        print("selectedMeditation*** \(type)")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBNinetyFivePercent") as! [DBNinetyFivePercent]
        if data.count > 0 {
            let ninetyFivePercentArray = WWMHelperClass.fetchNinetyFivePercentFilterDB(name: type, dbName: "DBNinetyFivePercent", type: "meditation_name")
            
            for dict in ninetyFivePercentArray{
                let value = (dict as AnyObject).meditation_value as? String
                let meditation_name = (dict as AnyObject).meditation_name as? String
                if meditation_name == type{
                    print("value+++ \(value) meditation_name+++ \(meditation_name) data+++ \(data.count) self.checkNinetyFivePer+++ \(self.checkNinetyFivePer)")
                    if value == "0"{
                        //1
                        if type == "Learn"{
                           return (kLTMCOMPLETENINETYFIVEPOPUP, kGOTIT, KCANCEL)
                        }else{
                           return (kCOMPLETENINETYFIVEPOPUP, kGOTIT, KCANCEL)
                        }
                    }else{
                        
                        //0
                        return (kINCOMPLETENINETYFIVEPOPUP, kEXIT, kCONTINUE)

                    }
                }
            }
        }
        
        return (kLTMBELOWNINTEYFIVEPOPUP, KOK, KCANCEL)
    }
    
    class func checkNinetyFivePercentData(type: String) -> String{
        
        print("selectedMeditation*** \(type)")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBNinetyFivePercent") as! [DBNinetyFivePercent]
        if data.count > 0 {
            let ninetyFivePercentArray = WWMHelperClass.fetchNinetyFivePercentFilterDB(name: type, dbName: "DBNinetyFivePercent", type: "meditation_name")
            
            for dict in ninetyFivePercentArray{
                let value = (dict as AnyObject).meditation_value as? String
                let meditation_name = (dict as AnyObject).meditation_name as? String
                if meditation_name == type{
                    print("value+++ \(value) meditation_name+++ \(meditation_name) data+++ \(data.count) self.checkNinetyFivePer+++ \(self.checkNinetyFivePer)")
                    if value == "0"{
                        self.deleteRowfromDb(dbName: "DBNinetyFivePercent", id: meditation_name!, type: "meditation_name")
                        let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
                        
                        dbNinetyFivePercent.meditation_name = meditation_name
                        dbNinetyFivePercent.meditation_value = "1"
                        
                        WWMHelperClass.saveDb()
                        
                        print("00000****")
                        return "1"
                    }else{
                        print("11111+++****")
                        return "0"
                    }
                }
            }
        }
        
        return "1"
    }
    
    class func checkNinetyFivePercentForOfflineData(type: String) -> String{
        
        print("selectedMeditation*** \(type)")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBNinetyFivePercent") as! [DBNinetyFivePercent]
        if data.count > 0 {
            let ninetyFivePercentArray = WWMHelperClass.fetchNinetyFivePercentFilterDB(name: type, dbName: "DBNinetyFivePercent", type: "meditation_name")
            
            for dict in ninetyFivePercentArray{
                let value = (dict as AnyObject).meditation_value as? String
                let meditation_name = (dict as AnyObject).meditation_name as? String
                if meditation_name == type{
                    print("value+++ \(value) meditation_name+++ \(meditation_name) data+++ \(data.count)")
                    if value == "0"{
                        print("00000****")
                        return "1"
                    }else{
                        return "0"
                    }
                }
            }
        }
        
        return "0"
    }
    
    class func fetchGuidedFilterDB(type: String, dbName: String, name: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "\(name) == %@", type)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
    
    class func fetchGuidedFilterEmotionsDB(guided_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "guided_id == %@", guided_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
    
    class func fetchGuidedFilterAudiosDB(emotion_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "emotion_id == %@", emotion_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
    
    //add ninetyfivepercent from backend
    
    class func addNinetyFivePercentDataFromBackend(type: String, count: Int){
        
        print("selectedMeditation*** \(type)")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBNinetyFivePercent") as! [DBNinetyFivePercent]
        if data.count > 0 {
            let ninetyFivePercentArray = WWMHelperClass.fetchNinetyFivePercentFilterDB(name: type, dbName: "DBNinetyFivePercent", type: "meditation_name")
            
            var flag = 0
            for dict in ninetyFivePercentArray{
                let meditation_name = (dict as AnyObject).meditation_name as? String
                if meditation_name == type{
                    if count > 0{
                        self.deleteRowfromDb(dbName: "DBNinetyFivePercent", id: meditation_name!, type: "meditation_name")
                        let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
                        
                        dbNinetyFivePercent.meditation_name = meditation_name
                        dbNinetyFivePercent.meditation_value = "1"
                    }
                    
                    flag = 1
                }
            }
            
            if flag == 0{
                if count > 0{
                    let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
                    
                    dbNinetyFivePercent.meditation_name = type
                    dbNinetyFivePercent.meditation_value = "1"
                }else{
                    let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
                    
                    dbNinetyFivePercent.meditation_name = type
                    dbNinetyFivePercent.meditation_value = "0"
                }
            }
            
        }else{
            let dbNinetyFivePercent = WWMHelperClass.fetchEntity(dbName: "DBNinetyFivePercent") as! DBNinetyFivePercent
            
            dbNinetyFivePercent.meditation_name = type
            dbNinetyFivePercent.meditation_value = "0"
        }
        
        WWMHelperClass.saveDb()
    }
    
   static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}


public class Reachabilities {
     func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}


public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}
