//
//  WWMSplashLoaderVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import SwiftyRSA

class WWMSplashLoaderVC: WWMBaseViewController {

    @IBOutlet weak var imageViewLoader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        do {
//            let password = "password"
//            let salt = AES256Crypter.randomSalt()
//            let key = try AES256Crypter.createKey(password: password.data(using: .utf8)!, salt: salt)
//            let keyStr = String.init(bytes: key, encoding: .utf8)
//            let plainText = "\(UIDevice.current.identifierForVendor!)" + ":\(key.base64EncodedString())"
//            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
//            }
//            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
//            let publicKey = try PublicKey.init(pemEncoded: keyString)
//            let clear = try ClearMessage(string: plainText, using: .utf8)
//            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
//            let base64String = encrypted.base64String
//            print(base64String)
//            guard let path1 = Bundle.main.path(forResource: "private", ofType: "pem") else { return
//            }
//            let keyString1 = try String(contentsOf: URL(fileURLWithPath: path1), encoding: .utf8)
//            let privatKey = try PrivateKey.init(pemEncoded: keyString1)
//            let clear1 = try encrypted.decrypted(with: privatKey, padding: .PKCS1)
//            let string = try clear1.string(encoding: .utf8)
//            print(string)
//            let param = "Hello:" + base64String
//            self.getEncryptesKey(param: param, key: key.base64EncodedString())
//
//
//
//        } catch {
//            print("Failed")
//            print(error)
//        }
//
////        let plainText = "Hello World"
////        let key = "password"
////
////        let cryptLib = CryptLib()
////
////        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: plainText, key: key)
////        print("cipherText \(cipherText! as String)")
////
////        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: "b96BKmGNsXnEyf4DR3KRMYfI6AIsl6UcD4nwLgDT+vQ=", key: key)
////        print("decryptedString \(decryptedString! as String)")
////
////        print(UIDevice.current.localizedModel)
////        print(UIDevice.current.model)
////
////
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
//
//            print("Decrypted hex string: \(str)")
//        } catch {
//            print("Failed")
//            print(error)
//        }
//
        self.setNavigationBar(isShow: false, title: "")
        //imageViewLoader.image = UIImage.gifImageWithName("SplashLoader")
        //self.saveMeditationDataToDB(data: ["":""])
        
        
        self.getMoodMeterDataAPI()
    }
    

    func getEncryptesKey(param:String, key:String) {
        
        
        WWMWebServices.requestAPIRSAEncryption(param: param, urlString: URL_HANDSHAKE, headerType: kPOSTHeader) { (result, error, success) in
            if success {
                if let encryptedStr = result["_hsk"] as? String {
                    
                    do {
                        
                        let cryptLib = CryptLib()
                        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: encryptedStr, key: key)

                        let data = Data.init(base64Encoded: encryptedStr)
                        let keyData = Data.init(base64Encoded: key)
                        //let data = encryptedStr.data(using: .utf8)
                        let iv = AES256Crypter.randomIv()

                        let aes = try AES256Crypter(key: keyData!, iv: iv)
                        let decryptedData = try aes.decrypt(data!)

                        let str = String.init(bytes: decryptedData, encoding: .utf8)
                       // print("Decrypted hex string: \(str)")
                    } catch {
                        print("Failed")
                        print(error)
                    }
                }
                
                
                print(result["_hsk"])
            }else {
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
        }
        
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_HANDSHAKE, headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.saveMoodMeterDataToDB(data: result)
            }else {
                self.getMoodMeterDataFromDB()
            }
        }
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
            
            
            
            alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
            let window = UIApplication.shared.keyWindow!
            
            alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
            alertPopupView.btnOK.layer.borderWidth = 2.0
            alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            
            alertPopupView.lblTitle.text = "Alert"
            alertPopupView.lblSubtitle.text = "Oh no, we've lost you! Please check your internet connection."
            alertPopupView.btnClose.isHidden = true
            
            alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
            window.rootViewController?.view.addSubview(alertPopupView)
            
            
//            let alert = UIAlertController(title: "Alert",
//                                          message: "The Internet connection appears to be offline.",
//                                          preferredStyle: UIAlertController.Style.alert)
//            
//            
//            let OKAction = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
//                self.getMoodMeterDataAPI()
//            }
//            alert.addAction(OKAction)
//            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.getMoodMeterDataAPI()
    }
    
    func saveMeditationDataToDB(data:[String:Any]) {
        var dbData = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        if dbData.count > 0 {
             WWMHelperClass.deletefromDb(dbName: "DBAllMeditationData")
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
                let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBAllMeditationData") as! DBAllMeditationData
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
        
        dbData = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.loadSplashScreenafterDelay()
                }
    }
    
    func getMeditationDataFromDB() {
        let dbData = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        if dbData.count > 0 {
            print(dbData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.loadSplashScreenafterDelay()
            }
        }else {
            let alert = UIAlertController(title: "Alert",
                                          message: "Oh no, we've lost you! Please check your internet connection.",
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
