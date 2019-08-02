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

class WWMHelperClass {
    
    static var alertPopupView = WWMAlertController()
    static var view1 = UIView()
    static var animationView = AnimationView()
    static var galleryValue = false
    static var loader_register = false
    static var milestoneType: String = ""
    static var selectedType: String = ""
    
    //learn
    static var step_audio: String = ""
    static var timer_audio: String = ""
    static var outro_audio: String = ""
    static var step_title: String = ""
    static var total_paid: Int = 0
    static var mantra_id: Int = 1
    static var step_id: Int = 1
    static var value: String = ""
    
    //static var imageView = UIImageView()
    
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
    
    class func showLoader(on view: UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
            let imageView = UIImageView.init(frame: CGRect.init(x: view.frame.size.width/2 - 25, y: view.frame.size.height/2 - 25, width: 50, height: 50))
            imageView.image = UIImage.gifImageWithName("ee_loading_img")
            view.addSubview(imageView)
        })
    }
    
    class func hideLoader(fromView view:UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
            let subviewsEnum :NSEnumerator = (view.subviews as NSArray).reverseObjectEnumerator()
            _ = UIView();
            for subview in subviewsEnum{
                if (subview is UIImageView) {
                    (subview as AnyObject).removeFromSuperview()
                }
            }
        })
    }
    
    
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
    
    
    class func dateComparison(expiryDate: String) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDateString = dateFormatter.string(from: Date())
        let currentDate = dateFormatter.date(from: currentDateString)!
       
        let expireDate = dateFormatter.date(from: expiryDate)!
       
        let day =  Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        print("day..... \(day)")
        
        if currentDate > expireDate{
            KUSERDEFAULTS.set(true, forKey: "getPrePostMoodBool")
            return 1
        }else{
            KUSERDEFAULTS.set(false, forKey: "getPrePostMoodBool")
            return 0
        }
    }
    
    class func dateComparison1(expiryDate: String) -> (Int, Int, Int){
        
        var date_completed: String = ""
        if expiryDate != ""{
           let date1 = expiryDate.components(separatedBy: " ")
            date_completed = date1[0]
        }
        
        print("date_completed... \(date_completed)")

        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDateString = dateFormatter.string(from: Date())
        var currentDate = dateFormatter.date(from: currentDateString)!
        
        let expireDate = dateFormatter.date(from: date_completed) ?? currentDate
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let day =  Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        
        if currentDate == expireDate{
            //yyyy-MM-dd HH:mm:ss
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            currentDate = dateFormatter.date(from: dateFormatter.string(from: Date()))!
            let expirDate = dateFormatter.date(from: expiryDate)!
            
            let second =  Calendar.current.dateComponents([.second], from: currentDate, to: expirDate).second ?? 0
            let min =  Calendar.current.dateComponents([.minute], from: currentDate, to: expirDate).minute ?? 0
            print("day..... \(day) second..... \(second) expiryDate... \(expirDate) currentDate... \(currentDate) min... \(min)")
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
