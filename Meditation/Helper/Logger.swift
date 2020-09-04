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
        DDLog.add(DDTTYLogger.sharedInstance!)
        fileLogger.rollingFrequency = TimeInterval(60*60*0.05)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 30
        DDLog.add(fileLogger, with: .info)
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
            
            let logData = self.sortedDataWithDate(logsDict: logsDict)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let now = Date()
            let sevenDaysAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)
            let lastDate = dateFormatter.string(from: sevenDaysAgo)
            let currentDate = dateFormatter.string(from: now)
            
            let finalLogData = logData.filter({ $0.key >= lastDate && $0.key <= currentDate})
            
            
            let param = RequestBody.logsBody(appPreference: WWMAppPreference(), dateFrom: lastDate, dateTo: currentDate)
            
            print("logs param*** \(param)")
            
            DataManager.sharedInstance.uploadLogs(logsDataArray: finalLogData, parameter: param) { (isSuccess, ErrorMsg) in
                
                if isSuccess{
                    self.deleteLogFile()
                }
                print("isSuccess \(isSuccess) ErrorMsg \(ErrorMsg)")
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
}
