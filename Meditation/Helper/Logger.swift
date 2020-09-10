//
//  Logger.swift
//  Meditation
//
//  Created by Prema Negi on 26/08/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import Foundation
import CocoaLumberjack
import MessageUI
import UIKit

class Logger: NSObject, MFMailComposeViewControllerDelegate {
    
    public let fileLogger: DDFileLogger = DDFileLogger()
    static let shared = Logger()
    let user_id = WWMAppPreference().getUserID()
    let defaults = UserDefaults.standard
    
    func setUpLogger(){
        if getIsLogging(){
            DDLog.add(DDTTYLogger.sharedInstance!)
            fileLogger.rollingFrequency = TimeInterval(60*60*24)
            fileLogger.logFileManager.maximumNumberOfLogFiles = 30
            DDLog.add(fileLogger, with: .info)
        }
    }
    
    func setIsLogging(value: Bool){
        defaults.set(value, forKey: "isLogging")
        getLogContent()
        
        if getIsLogging(){
            setUpLogger()
        }
    }
    
    func getIsLogging() -> Bool{
        return defaults.bool(forKey: "isLogging")
    }
    
    func generateLogs(type: String, user_id: String, filePath: String, line: Int, column: Int, function: String, logText: String){
        
        if getIsLogging(){
            DDLogInfo("Type: \(type) user_id: \(user_id) filePath: \(filePath) line: \(line) column: \(column) function: \(function) log: \(logText)")
        }
    }
    
    func getLogContent(){
        //print(self.fileLogger.logFileManager.logsDirectory)
    }
    
    func deleteLogFile(){
        self.fileLogger.rollLogFile(withCompletion: {
            for filename: String in
                self.fileLogger.logFileManager.sortedLogFilePaths {
                    do {
                        try FileManager.default.removeItem(atPath: filename)
                    } catch {
                        print(error.localizedDescription)
                    }
            }
        })
    }
    
    func sendLogs(datefrom: String, dateTo: String, vc: UIViewController) {
        
        if getIsLogging(){
            
            let logURLs = self.fileLogger.logFileManager.sortedLogFilePaths
                .map { URL.init(fileURLWithPath: $0, isDirectory: false) }
            
            var logsDict: [String: Data] = [:] // File Name : Log Data
            logURLs.forEach { (fileUrl) in
                guard let data = try? Data(contentsOf: fileUrl) else { return }
                logsDict[fileUrl.lastPathComponent] = data
            }
            
            if logsDict.isEmpty{
                self.alertMsg(msg: "No Record Found", vc: vc)
                return
            }
            
            let getDate = self.getDateFromTo(datefrom: datefrom, dateTo: dateTo, vc: vc)
            if !getDate.0{
                return
            }
            
            let logData = self.sortedDataWithDate(logsDict: logsDict)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
        
            
            let finalLogData = logData.filter({ $0.key >= getDate.1 && $0.key <= getDate.2})
            //print(finalLogData)
            
            let param = RequestBody.logsBody(appPreference: WWMAppPreference(), dateFrom: getDate.1, dateTo: getDate.2)
            
            //print("logs param*** \(param)")
            DataManager.sharedInstance.uploadLogs(logsDataArray: finalLogData, parameter: param) { (isSuccess, ErrorMsg) in
                
                if isSuccess{
                    self.deleteLogFile()
                    self.alertMsg(msg: "Data uploaded successfully", vc: vc)
                }
                //print("isSuccess \(isSuccess) ErrorMsg \(ErrorMsg)")
            }
        }
    }
    
    func sortedDataWithDate(logsDict: [String: Data]) -> [(key: String, value: Data)]{
        var dict: [String: Data] = [:]
        for (key, value) in logsDict{
            let keyName = logDate(dateArray: key.components(separatedBy: " "))
            dict[keyName] = value
        }
        
        return dict.sorted { $0.key < $1.key }
    }
    
    func logDate(dateArray: [String]) -> String{
        let finalDate = dateArray[1].components(separatedBy: "--")
        return finalDate[0]
    }
    
    func getDateFromTo(datefrom: String, dateTo: String, vc: UIViewController) -> (Bool, fromDate: String, toDate: String){
        if datefrom == "" && dateTo == ""{
            self.alertMsg(msg: "Please enter valid dates", vc: vc)
        }else if datefrom == ""{
            self.alertMsg(msg: "Please enter from date", vc: vc)
        }else if dateTo == ""{
            self.alertMsg(msg: "Please enter To date", vc: vc)
        }else if !checkValidDate(dateToCheck: datefrom){
            self.alertMsg(msg: "Please enter from date in the correct formet i.e YYYY-MM-dd", vc: vc)
        }else if !checkValidDate(dateToCheck: dateTo){
            self.alertMsg(msg: "Please enter to date in the correct formet i.e YYYY-MM-dd", vc: vc)
        }else{
            return (true, datefrom, dateTo)
        }
        
        return (false, datefrom, dateTo)
    }
    
    func alertMsg(msg: String, vc: UIViewController){
        let alert = UIAlertController(title: msg, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func checkValidDate(dateToCheck: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let _ = dateFormatter.date(from: dateToCheck){
                //print("true date:\(date)")
                return true
            }else{
                //print("wrong date")
                return false
            }
    }
}
