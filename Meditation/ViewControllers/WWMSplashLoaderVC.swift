//
//  WWMSplashLoaderVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import CommonCrypto

class WWMSplashLoaderVC: WWMBaseViewController {

    @IBOutlet weak var imageViewLoader: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let plainText = "Hello World"
        let key = "password"
        
        let cryptLib = CryptLib()
        
        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: plainText, key: key)
        print("cipherText \(cipherText! as String)")
        
        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: "b96BKmGNsXnEyf4DR3KRMYfI6AIsl6UcD4nwLgDT+vQ=", key: key)
        print("decryptedString \(decryptedString! as String)")
        
        print(UIDevice.current.localizedModel)
        print(UIDevice.current.model)
        
        
//        do {
//            let sourceData = "Hello World".data(using: .utf8)!
//            let password = "password"
//            let salt = AES256Crypter.randomSalt()
//            let iv = AES256Crypter.randomIv()
//            let key = try AES256Crypter.createKey(password: password.data(using: .utf8)!, salt: salt)
//            let aes = try AES256Crypter(key: key, iv: iv)
//            let encryptedData = try aes.encrypt(sourceData)
//            let decryptedData = try aes.decrypt(encryptedData)
//
//            let str = String.init(bytes: decryptedData, encoding: .utf8)!
//            //let strEncr = String.init(bytes: encryptedData, encoding: .utf8)!
//            print("Encrypted hex string: \(encryptedData.base64EncodedString())")
//            print("Decrypted hex string: \(str)")
//        } catch {
//            print("Failed")
//            print(error)
//        }
        
        self.setNavigationBar(isShow: false, title: "")
        //imageViewLoader.image = UIImage.gifImageWithName("SplashLoader")
        //self.saveMeditationDataToDB(data: ["":""])
        
        
        self.getMoodMeterDataAPI()

        
    }
    

    func loadSplashScreenafterDelay() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSplashAnimationVC") as! WWMSplashAnimationVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
   
    // SAVE Data To Database
    func saveMoodMeterDataToDB(data:[String:Any]) {
        let moodData = WWMHelperClass.fetchDB(dbName: "DBMoodMeter") as! [DBMoodMeter]
        if moodData.count > 0 {
            WWMHelperClass.deletefromDb(dbName: "DBMoodMeter")
        }
        
        let moodDB = WWMHelperClass.fetchEntity(dbName: "DBMoodMeter") as! DBMoodMeter
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: data, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        moodDB.data = myString
        WWMHelperClass.saveDb()
        
        self.getMeditationDataAPI()
    }
    
    func getMoodMeterDataFromDB() {
        let moodData = WWMHelperClass.fetchDB(dbName: "DBMoodMeter") as! [DBMoodMeter]
        if moodData.count > 0 {
            print(moodData[0])
            self.getMeditationDataAPI()
        }else {
            let alert = UIAlertController(title: "Alert",
                                          message: "The Internet connection appears to be offline.",
                                          preferredStyle: UIAlertController.Style.alert)
            
            
            let OKAction = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
                self.getMoodMeterDataAPI()
            }
            alert.addAction(OKAction)
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }
    }
    func saveMeditationDataToDB(data:[String:Any]) {
        var dbData = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        if dbData.count > 0 {
             WWMHelperClass.deletefromDb(dbName: "DBMeditationData")
        }
     
        var arrMeditationData = [WWMMeditationData]()
        if let dataMeditation = data["result"] as? [[String:Any]]{
            for dict in dataMeditation {
                let data = WWMMeditationData.init(json: dict)
                arrMeditationData.append(data)
            }
        }
            for  index in 0..<arrMeditationData.count {
                let dataM = arrMeditationData[index]
                let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationData") as! DBMeditationData
                meditationDB.meditationId = Int32(dataM.meditationId)
                meditationDB.meditationName = dataM.meditationName
                meditationDB.isMeditationSelected = false
                for  index in 0..<dataM.levels.count {
                    let dic = dataM.levels[index]
                    let levelDB = WWMHelperClass.fetchEntity(dbName: "DBLevelData") as! DBLevelData
                    levelDB.isLevelSelected = false
                    levelDB.levelId = Int32(dic.levelId)
                    levelDB.levelName = dic.levelName
                    levelDB.prepTime = Int32(dic.prepTime)!
                    levelDB.meditationTime = Int32(dic.meditationTime)!
                    levelDB.restTime = Int32(dic.restTime)!
                    levelDB.minPrep = Int32(dic.minPrep)!
                    levelDB.minRest = Int32(dic.minRest)!
                    levelDB.minMeditation = Int32(dic.minMeditation)!
                    levelDB.maxPrep = Int32(dic.maxPrep)!
                    levelDB.maxRest = Int32(dic.maxRest)!
                    levelDB.maxMeditation = Int32(dic.maxMeditation)!
                    meditationDB.addToLevels(levelDB)
                }
                WWMHelperClass.saveDb()
            }
        
        dbData = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.loadSplashScreenafterDelay()
                }
    }
    
    func getMeditationDataFromDB() {
        let dbData = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        if dbData.count > 0 {
            print(dbData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.loadSplashScreenafterDelay()
            }
        }else {
            let alert = UIAlertController(title: "Alert",
                                          message: "The Internet connection appears to be offline.",
                                          preferredStyle: UIAlertController.Style.alert)
            
            
            let OKAction = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
                self.getMeditationDataAPI()
            }
            alert.addAction(OKAction)
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }
    }
    // API Calling
    
    func getMoodMeterDataAPI() {
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMOODMETERDATA, headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.saveMoodMeterDataToDB(data: result)
            }else {
                self.getMoodMeterDataFromDB()
            }
        }
    }
    
    
    func getMeditationDataAPI() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMEDITATIONDATA, headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.saveMeditationDataToDB(data: result)
            }else {
               self.getMeditationDataFromDB()
            }
        }
    }

}
