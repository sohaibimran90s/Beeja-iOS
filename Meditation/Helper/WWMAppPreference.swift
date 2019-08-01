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
    
    func setSessionAvailableData(value: Bool) {
        defaults.set(value, forKey: "session_available")
        defaults.synchronize()
    }
    
    func setUserSubscription(value:[String : Any]) {
        defaults.set(value, forKey: "UserSubscription")
        defaults.synchronize()
    }
    
    func setUserData(value:[String : Any]) {
        defaults.set(value, forKey: "UserData")
        defaults.synchronize()
    }
    
    func setHomePageURL(value: String) {
        defaults.set(value, forKey: "home_page_url")
        defaults.synchronize()
    }
    
    func setLearnPageURL(value: String) {
        defaults.set(value, forKey: "learn_page_url")
        defaults.synchronize()
    }
    
    func setPreMoodCount(value: Int){
        defaults.set(value, forKey: "preMoodCount")
    }
    
    func setPrePostJournalBool(value: Bool){
        defaults.set(value, forKey: "prePostJournalBool")
    }

    func setPostMoodCount(value: Int){
        defaults.set(value, forKey: "postMoodCount")
    }
    
    func setPostJournalCount(value: Int){
        defaults.set(value, forKey: "postJournalCount")
    }
    
    
    func setPreJournalCount(value: Int){
        defaults.set(value, forKey: "preJournalCount")
    }
    

    func setUserID(value:String) {
        defaults.set(value, forKey: "User_Id")
        defaults.synchronize()
    }
    
    func setType(value:String) {
        defaults.set(value, forKey: "type")
        defaults.synchronize()
    }
    
    func setGuideType(value:String) {
        defaults.set(value, forKey: "guided_type")
        defaults.synchronize()
    }
    
    func getHomePageURL() -> String {
        return UserDefaults.standard.string(forKey: "home_page_url") ?? ""
    }
    
    func getLearnPageURL() -> String {
        return UserDefaults.standard.string(forKey: "learn_page_url") ?? ""
    }
    
    func getSessionAvailableData() -> Bool{
        return defaults.bool(forKey: "session_available")
    }
    
    func getPrePostJournalBool() -> Bool{
        return defaults.bool(forKey: "prePostJournalBool")
    }
    
    func getPreMoodCount() -> Int{
        return defaults.integer(forKey: "preMoodCount")
    }

    func getPostMoodBool() -> Bool{
        return defaults.bool(forKey: "postMoodBool")
    }
    
    func getPostMoodCount() -> Int{
        return defaults.integer(forKey: "postMoodCount")
    }
    
    func getPostJournalBool() -> Bool{
        return defaults.bool(forKey: "postJournalBool")
    }
    
    func getPostJournalCount() -> Int{
        return defaults.integer(forKey: "postJournalCount")
    }
    
    func getPreJournalBool() -> Bool{
        return defaults.bool(forKey: "postJournalBool")
    }
    
    func getPreJournalCount() -> Int{
        return defaults.integer(forKey: "preJournalCount")
    }

    func getType() -> String {
        return UserDefaults.standard.string(forKey: "type") ?? ""
    }
    func getGuideType() -> String {
        return UserDefaults.standard.string(forKey: "guided_type") ?? ""
    }
    
    func setUserToken(value:String) {
        defaults.set(value, forKey: kUserToken)
        defaults.synchronize()
    }
    func setDeviceToken(value:String) {
        defaults.set(value, forKey: kDeviceToken)
        defaults.synchronize()
    }
    
    func setUserName(value:String) {
        defaults.set(value, forKey: "UserName")
        defaults.synchronize()
    }
    
    func setIsProfileCompleted(value:Bool) {
        defaults.set(value, forKey: "IsProfileCompleted")
        defaults.synchronize()
    }
    
    func getUserID() -> String {
        return UserDefaults.standard.string(forKey: "User_Id") ?? ""
    }
    
    func getUserName() -> String {
        return UserDefaults.standard.string(forKey: "UserName") ?? ""
    }
    
    func getDeviceToken() -> String {
        return UserDefaults.standard.string(forKey: kDeviceToken) ?? ""
    }

    func getToken() -> String {
        return UserDefaults.standard.string(forKey: kUserToken) ?? ""
    }
    
    func getUserData() -> [String:Any] {
        return UserDefaults.standard.dictionary(forKey: "UserData")!
    }
    
    func getUserSubscription() -> [String:Any] {
        return UserDefaults.standard.dictionary(forKey: "UserSubscription")!
    }
    
    
    func isProfileComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: "IsProfileCompleted")
    }
    
    func isLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: "login")
    }
    
    func isLogout() -> Bool {
        if UserDefaults.standard.dictionary(forKey: "UserData")?.count ?? 0 > 0{
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
