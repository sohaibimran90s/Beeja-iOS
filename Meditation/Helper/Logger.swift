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
        // File logger
        DDLog.add(DDTTYLogger.sharedInstance!)
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 30
        DDLog.add(fileLogger, with: .info)
        
        self.setIsLogging(value: false)
        //sendLogs()
    }
    
    func setIsLogging(value: Bool){
        defaults.set(value, forKey: "isLogging")
        getLogContent()
    }
    
    func getIsLogging() -> Bool{
        return defaults.bool(forKey: "isLogging")
    }
    
    func generateLogs(type: String, user_id: String, filePath: String, line: Int, column: Int, function: String, logText: String){
        
        /*
         Literal        Type     Value

         #file          String   The name of the file in which it appears.
         #line          Int      The line number on which it appears.
         #column        Int      The column number in which it begins.
         #function      String   The name of the declaration in which it appears.
         */
        
        if getIsLogging(){
            DDLogInfo("Type: \(type) user_id: \(user_id) filePath: \(filePath) line: \(line) column: \(column) function: \(function) log: \(logText)")
        }
    }
    
    func getLogContent(){
        print(self.fileLogger.logFileManager.logsDirectory)
        
        for path in self.fileLogger.logFileManager.sortedLogFilePaths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                print(content)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
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
    
    func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    private func sendLogs() {
        
        let appPreference = WWMAppPreference()
        var param: [String: AnyObject] = [:]
        param["user_id"] = appPreference.getUserID() as AnyObject
        param["device_id"] = UIDevice.current.identifierForVendor!.uuidString as AnyObject
        param["platform"] = "iOS" as AnyObject
        param["app_version"] = WWMHelperClass.getVersion() as AnyObject
        param["date_from"] = "2020-09-01" as AnyObject
        param["date_to"] = "2020-09-02" as AnyObject
        
        
        let logURLs = self.fileLogger.logFileManager.sortedLogFilePaths
            .map { URL.init(fileURLWithPath: $0, isDirectory: false) }
        
        var logsDict: [String: Data] = [:] // File Name : Log Data
        logURLs.forEach { (fileUrl) in
            guard let data = try? Data(contentsOf: fileUrl) else { return }
            logsDict[fileUrl.lastPathComponent] = data
        }
        
        for (fileName, logData)  in logsDict {
            print("fileName... \(fileName) logData... \(logData)")
        }
        
        
        DataManager.sharedInstance.uploadLogs(logsDataArray: logsDict, parameter: param) { (isSuccess, ErrorMsg) in
            
            print(isSuccess)
            print(ErrorMsg)
        }
        
        
        
        
        /*guard let _ = UIApplication.shared.delegate as? AppDelegate, MFMailComposeViewController.canSendMail() == true else {
            return
        }
        
        let mailCompose = MFMailComposeViewController()
        mailCompose.mailComposeDelegate = self
        mailCompose.setSubject("Logs for agostini.tech!")
        mailCompose.setMessageBody("", isHTML: false)
        
        let logURLs = self.fileLogger.logFileManager.sortedLogFilePaths
            .map { URL.init(fileURLWithPath: $0, isDirectory: false) }
        
        var logsDict: [String: Data] = [:] // File Name : Log Data
        logURLs.forEach { (fileUrl) in
            guard let data = try? Data(contentsOf: fileUrl) else { return }
            logsDict[fileUrl.lastPathComponent] = data
        }
        
        for (fileName, logData)  in logsDict {
            mailCompose.addAttachmentData(logData, mimeType: "text/plain", fileName: fileName)
        }
        
        vc.present(mailCompose, animated: true, completion: nil)*/
    }
}
