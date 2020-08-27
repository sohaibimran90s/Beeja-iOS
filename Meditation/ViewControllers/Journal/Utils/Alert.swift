//
//  Alert.swift
// 
//
//  Created by Ehsan on 18/12/19.
//  Copyright © 2019 Ehsan. All rights reserved.
//

import UIKit

class Alert {
    
    class func alertWithOneButton (title: String, message: String, container: Any,
                                   completion: @escaping (UIAlertController, Int) -> Void)
    {
        let myAlert = UIAlertController(title: title, message:message,
                                        preferredStyle: UIAlertController.Style.alert);
        
        myAlert.view.accessibilityIdentifier = "NetworkAlertView"
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:
        { (action:UIAlertAction) in
            
            //LogUtils.LogDebug("Pressed OK")
            completion (myAlert, myAlert.actions.firstIndex(of: action)!)
        })
        
        // this action can add to more button
        myAlert.addAction(okAction);
        
        (container as AnyObject).present(myAlert, animated: true, completion: nil)
    }
    
    class func alertWithTwoButton (title: String, message: String, btn1 : String, btn2: String, container: Any,
                                   completion: @escaping (UIAlertController, Int) -> Void)
    {
        let myAlert = UIAlertController(title: title, message:message,
                                        preferredStyle: UIAlertController.Style.alert);
        
        
        let btn1Action = UIAlertAction(title: btn1, style: UIAlertAction.Style.cancel, handler:
        { (action:UIAlertAction) in
            
            //LogUtils.LogDebug("PRessed Cancel")
            completion (myAlert, myAlert.actions.firstIndex(of: action)!)
        })
        
        let btn2Action = UIAlertAction(title: btn2, style: UIAlertAction.Style.default, handler:
        { (action:UIAlertAction) in
            
            //LogUtils.LogDebug("Pressed OK")
            completion (myAlert, myAlert.actions.firstIndex(of: action)!)
        })
        
        
        // this action can add to more button
        myAlert.addAction(btn1Action);
        myAlert.addAction(btn2Action);
        
        (container as AnyObject).present(myAlert, animated: true, completion: nil)
    }
    
}

