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

class WWMHelperClass {
    
    class func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func showPopupAlertController(sender : Any, message : String, title : String) -> Void{
        
        let alert = UIAlertController(title: title as String,
                                      message: message as String,
                                      preferredStyle: UIAlertController.Style.alert)
        
        
        let OKAction = UIAlertAction(title: "OK",
                                     style: .default, handler: nil)
        
        alert.addAction(OKAction)
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        
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

public class Reachability {
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
