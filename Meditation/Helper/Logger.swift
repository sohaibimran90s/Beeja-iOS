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
    static let logger = Logger()
    let user_id = WWMAppPreference().getUserID()
    let defaults = UserDefaults.standard
    
    func setUpLogger(){
        
        if getIsLogging(){
            DDLog.add(DDTTYLogger.sharedInstance!)
            fileLogger.rollingFrequency = TimeInterval(60*60*0.05)
            fileLogger.logFileManager.maximumNumberOfLogFiles = 30
            DDLog.add(fileLogger, with: .info)
        }
    }
    
    func setIsLogging(value: Bool){
        defaults.set(value, forKey: "isLogging")
        getLogContent()
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
        print(self.fileLogger.logFileManager.logsDirectory)
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
    
    func sendLogs() {
        
        if getIsLogging(){

            let logURLs = self.fileLogger.logFileManager.sortedLogFilePaths
                .map { URL.init(fileURLWithPath: $0, isDirectory: false) }
            
            var logsDict: [String: Data] = [:] // File Name : Log Data
            logURLs.forEach { (fileUrl) in
                guard let data = try? Data(contentsOf: fileUrl) else { return }
                logsDict[fileUrl.lastPathComponent] = data
            }
            
            if logsDict.isEmpty{
                return
            }
                     
            let finalLogData = self.sortedDataWithDate(logsDict: logsDict)
            
            let filtered = finalLogData.0.filter({ $0.key == "2020-09-03"})

            let param = RequestBody.logsBody(appPreference: WWMAppPreference(), dateFrom: finalLogData.1, dateTo: finalLogData.2)
            
            print("logs param*** \(param)")
            
            DataManager.sharedInstance.uploadLogs(logsDataArray: finalLogData.0, parameter: param) { (isSuccess, ErrorMsg) in
                
                print("isSuccess \(isSuccess) ErrorMsg \(ErrorMsg)")
            }
        }
    }

    func sortedDataWithDate(logsDict: [String: Data]) -> ([(key: String, value: Data)], dateFrom: String, dateTo: String){
        var dict: [String: Data] = [:]
        for (key, value) in logsDict{
            let keyName = logDate(dateArray: key.components(separatedBy: " "))
            dict[keyName] = value
         }
        
        let getMinMaxDate = dict.sorted { $0.key < $1.key }
        return (getMinMaxDate, getMinMaxDate.map({ $0.key }).min()!, getMinMaxDate.map({ $0.key }).max()!)
    }
    
    func logDate(dateArray: [String]) -> String{
        let finalDate = dateArray[1].components(separatedBy: "--")
        return finalDate[0]
    }
}
