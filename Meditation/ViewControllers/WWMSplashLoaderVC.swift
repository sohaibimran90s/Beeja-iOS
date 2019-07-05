//
//  WWMSplashLoaderVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 04/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import SwiftyRSA
import Lottie

class WWMSplashLoaderVC: WWMBaseViewController {

    @IBOutlet weak var imageViewLoader: UIImageView!
    var animationView = AnimationView()
    var executionTime: Double = 0.0
    let startDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        KUSERDEFAULTS.set("0", forKey: "restore")
//        do {
//            let password = "password"
//            let salt = AES256Crypter.randomSalt()
//            let key = try AES256Crypter.createKey(password: password.data(using: .utf8)!, salt: salt)
//            let keyStr = String.init(bytes: key, encoding: .utf8)
//            let plainText = "\(UIDevice.current.identifierForVendor!)" + ":\(password)"
//            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
//            }
//            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
//            let publicKey = try PublicKey.init(pemEncoded: keyString)
//            let clear = try ClearMessage(string: plainText, using: .utf8)
//            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
//            let base64String = encrypted.base64String
////            print(base64String)
////            guard let path1 = Bundle.main.path(forResource: "private", ofType: "pem") else { return
////            }
////            let keyString1 = try String(contentsOf: URL(fileURLWithPath: path1), encoding: .utf8)
////            let privatKey = try PrivateKey.init(pemEncoded: keyString1)
////            let clear1 = try encrypted.decrypted(with: privatKey, padding: .PKCS1)
////            let string = try clear1.string(encoding: .utf8)
////            print(string)
//            let param = "Hello:" + base64String
//            self.getFirstEncryptesKey(param: param, key: password)
//
//
//
//        } catch {
//            print("Failed")w
//            print(error)
//        }

        self.imageViewLoader.isHidden = true
        self.setNavigationBar(isShow: false, title: "")
        //imageViewLoader.image = UIImage.gifImageWithName("SplashLoader")
        //self.saveMeditationDataToDB(data: ["":""])
        
        animationView = AnimationView(name: "loader")
        animationView.frame = CGRect(x: view.frame.size.width/2 - 200, y: view.frame.size.height/2 - 200, width: 400, height: 400)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        self.view.addSubview(animationView)
        animationView.play()
        self.getMoodMeterDataAPI()
    }
    

    func getFirstEncryptesKey(param:String, key:String) {
        
        
        WWMWebServices.requestAPIRSAEncryption(param: param, urlString: URL_HANDSHAKE, headerType: kPOSTHeader) { (result, error, success) in
            if success {
                if let encryptedStr = result["_hsk"] as? String {
                    
                   let plainText = "Hello World"
                        let key1 = "your key"
                        
                        let cryptLib = CryptLib()
                        
                        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: plainText, key: key1)
                        print("cipherText \(cipherText! as String)")
                        print(encryptedStr)
                        let d = cryptLib.decryptCipherTextRandomIV(withCipherText: "A/llYYk0+iXtFPykOnqMgcVr/Be0hHvqv611uRhoURQ=", key: "ass")
                        
                        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: encryptedStr, key: key)
                    if decryptedString != nil {
                        let randomStr = String.init(data: cryptLib.generateRandomIV(16), encoding: .utf8)
                        
                        let encryted = cryptLib.encryptPlainTextRandomIV(withPlainText: randomStr, key: decryptedString)
                        
                        let paramSecond = "\(encryted!)"
                        
                        self.getSecondEncryptesKey(param: paramSecond, key: decryptedString!)
                    }
                    
                    

                }
            }else {
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func getSecondEncryptesKey(param:String, key:String) {
        WWMWebServices.requestAPIRSAEncryption(param: param, urlString: URL_HANDSHAKE, headerType: kPOSTHeader) { (result, error, success) in
            if success {
                if let encryptedStr = result["_hsk"] as? String {
                    
                }
                
            }else {
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
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
        
                print("excution..... \(self.executionTime)")
                if self.executionTime < 3.0{
                    print("less....")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        self.animationView.stop()
                        self.animationView.isHidden = true
                        self.imageViewLoader.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            
                            self.loadSplashScreenafterDelay()
                        }
                    }
                }else{
                    print("more....")
                    self.animationView.stop()
                    self.animationView.isHidden = true
                    self.imageViewLoader.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.loadSplashScreenafterDelay()
                    }
                }//end else
            }
    
    func getMeditationDataFromDB() {
        let dbData = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        if dbData.count > 0 {
            print("dbData... \(dbData) excution..... \(self.executionTime)")
            
            if self.executionTime < 3.0{
                print("less....")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.animationView.stop()
                    self.animationView.isHidden = true
                    self.imageViewLoader.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        
                        self.loadSplashScreenafterDelay()
                    }
                }
            }else{
                print("more....")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.loadSplashScreenafterDelay()
                }
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
            
            self.executionTime = Date().timeIntervalSince(self.startDate)

            if sucess {
                self.saveMoodMeterDataToDB(data: result)
            }else {
                self.getMoodMeterDataFromDB()
            }
        }
    }
    
    
    func getMeditationDataAPI() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMEDITATIONDATA, headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            
            self.executionTime = Date().timeIntervalSince(self.startDate)
            
            if sucess {
                self.saveMeditationDataToDB(data: result)
            }else {
               self.getMeditationDataFromDB()
            }
        }
    }

}
