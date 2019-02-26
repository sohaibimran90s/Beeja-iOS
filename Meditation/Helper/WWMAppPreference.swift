//
//  WWMAppPreference.swift
//  Meditation
//
//  Created by Roshan Kumawat on 07/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMAppPreference: NSObject {
    
    let defaults = UserDefaults.standard
    
    func setIsLogin(value:Bool) {
        defaults.set(value, forKey: "login")
        defaults.synchronize()
    }
    
    func setIsFirstTimeSplash(value:Bool) {
        defaults.set(value, forKey: "firstTimeSplash")
        defaults.synchronize()
    }
    
    func setIsSecondTimeSplash(value:Bool) {
        defaults.set(value, forKey: "secondTimeSplash")
        defaults.synchronize()
    }
    
    func setLastLoginDate(value:Date) {
        defaults.set(value, forKey: "lastLoginDate")
        defaults.synchronize()
    }
    func setUserData(value:[String:Any]) {
        defaults.set(value, forKey: "UserData")
        defaults.synchronize()
    }
    
    func setUserID(value:String) {
        defaults.set(value, forKey: "User_Id")
        defaults.synchronize()
    }
    
    func setUserToken(value:String) {
        defaults.set(value, forKey: kUserToken)
        defaults.synchronize()
    }
    func setDeviceToken(value:String) {
        defaults.set(value, forKey: kDeviceToken)
        defaults.synchronize()
    }
    
    func setIsProfileCompleted(value:Bool) {
        defaults.set(value, forKey: "IsProfileCompleted")
        defaults.synchronize()
    }
    
    func getUserID() -> String {
        return UserDefaults.standard.string(forKey: "User_Id") ?? ""
    }
    
    func getDeviceToken() -> String {
        return UserDefaults.standard.string(forKey: kDeviceToken) ?? ""
    }

    func getToken() -> String {
        return UserDefaults.standard.string(forKey: kUserToken) ?? ""
    }
    
    
    func isProfileComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: "IsProfileCompleted")
    }
    
    func isLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: "login")
    }
    
    func isLogout() -> Bool {
        if UserDefaults.standard.dictionary(forKey: "UserData") != nil{
            return true
        }
        return false
    }
    
    func isFirstTimeSplash() -> Bool {
        return UserDefaults.standard.bool(forKey: "firstTimeSplash")
    }
    
    func isSecondTimeSplash() -> Bool {
        return UserDefaults.standard.bool(forKey: "secondTimeSplash")
    }
    
    func lastLoginDate() -> Date {
        return UserDefaults.standard.object(forKey: "lastLoginDate") as? Date ?? Date()
    }
}
