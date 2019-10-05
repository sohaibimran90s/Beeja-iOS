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
    var alertPopupView1 = WWMAlertController()

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
//            let clear = try ClearMessage(string: "pulse", using: .utf8)
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
//            let param = "pulse:" + base64String
//            self.getFirstEncryptesKey(param: param, key: password)
//
//
//
//        } catch {
//            print("Failed")
//            print(error)
//        }

        WWMHelperClass.selectedType = ""
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
        self.showForceUpdate()
    }
    
    func showForceUpdate() {
        WWMWebServices.requestAPIWithBodyForceUpdate(urlString: "https://beeja.s3.eu-west-2.amazonaws.com/mobile/config/update.json", context: "WWMSplashLoaderVC") { (result, error, success) in
            if success {
                
                #if DEBUG
                    print("I'm running in DEBUG mode")
                
                    if let baseUrl = result["staging_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://staging.beejameditation.com", forKey: KBASEURL)
                    }
                #else
                    print("I'm running in a non-DEBUG mode")
                    if let baseUrl = result["base_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                }
                #endif
                
                if let force_update = result["force_update"] as? Bool{
                    if force_update{
                        if self.needsUpdate(){
                            self.forceToUpdatePopUp()
                        }else {
                            self.getMoodMeterDataAPI()
                        }
                    }else {
                        self.getMoodMeterDataAPI()
                    }
                }else {
                    self.getMoodMeterDataAPI()
                }
                
            }else {
                self.getMoodMeterDataAPI()
            }
            
        }
    }
    
    func needsUpdate() -> Bool {
        let infoDictionary = Bundle.main.infoDictionary
        let appID = "1453359245"//infoDictionary?["CFBundleIdentifier"] as? String
        let url = URL(string: "http://itunes.apple.com/lookup?id=\(appID)")
        var data: Data? = nil
        if let url = url {
            data = try? Data(contentsOf: url)
        }
        var lookup: [AnyHashable : Any]? = nil
        do {
            if let data = data {
                lookup = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
            }
        } catch {
        }
        
        if (lookup?["resultCount"] as? NSNumber)?.intValue == 1 {
            if let results = lookup?["results"] as? [[String:Any]] {
                let appStoreVersion = results[0]["version"] as? String
                let currentVersion = infoDictionary?["CFBundleShortVersionString"] as? String
                if !(appStoreVersion == currentVersion) {
                    print("Need to update [\(appStoreVersion ?? "") != \(currentVersion ?? "")]")
                    return true
                }
            }
            
            
        }
        return false
    }
    
    func forceToUpdatePopUp(){
        
        alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView1.isRemove = false
        alertPopupView1.btnOK.layer.borderWidth = 2.0
        alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView1.lblTitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATETITLE) ?? "New Version Available"
        alertPopupView1.lblSubtitle.text = KUSERDEFAULTS.string(forKey: KFORCETOUPDATEDES) ?? "There is a newer version available for download! Please update the app by visiting the Apple Store."
        alertPopupView1.btnOK.setTitle(KUSERDEFAULTS.string(forKey: KUPGRADEBUTTON) ?? "Update", for: .normal)
        alertPopupView1.btnClose.isHidden = true
        
        alertPopupView1.btnOK.addTarget(self, action: #selector(btnForceToUpdateDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @IBAction func btnForceToUpdateDoneAction(_ sender: Any) {
        //https://apps.apple.com/us/app/beeja-meditation/id1453359245
        UIApplication.shared.open(URL.init(string: "https://apps.apple.com/is/app/beeja-meditation/id1453359245")!, options: [:], completionHandler: nil)
        
    }


    func getFirstEncryptesKey(param:String, key:String) {
        
        
        WWMWebServices.requestAPIRSAEncryption(param: param, urlString: URL_HANDSHAKE, headerType: kPOSTHeader, context: "WWMSplashLoaderVC") { (result, error, success) in
            if success {
                if let encryptedStr = result["_hsk"] as? String {
                    
                    
                    
                   let plainText = "Hello World"
                        let key1 = "your key"
                        
                        let cryptLib = CryptLib()
                        
                        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: plainText, key: key1)
                        print("cipherText \(cipherText! as String)")
                        print(encryptedStr)
                    
                    let decryp = cryptLib.decryptCipherText("k0bf8ZtxkzmTj5upXHT7lDM84xzn1MQi1G4q3yj+u7Cjw+NzKRrj9yJAI0nWa5Lkq26ncMGqizm+BuW4Wl5FXCqUol/wg9aP//20m1Iuiw4rrjRSnoEV1Qrb8gOw9Ynp", key: "fuckingsimplekey", iv: nil)
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
        WWMWebServices.requestAPIRSAEncryption(param: param, urlString: URL_HANDSHAKE, headerType: kPOSTHeader, context: "WWMSplashLoaderVC") { (result, error, success) in
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
            
            alertPopupView.lblTitle.text = kAlertTitle
            alertPopupView.lblSubtitle.text = internetConnectionLostMsg
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
                    levelDB.prepTime = Int32(dic.prepTime) ?? 0
                    levelDB.meditationTime = Int32(dic.meditationTime) ?? 0
                    levelDB.restTime = Int32(dic.restTime) ?? 0
                    levelDB.minPrep = Int32(dic.minPrep) ?? 0
                    levelDB.minRest = Int32(dic.minRest) ?? 0
                    levelDB.minMeditation = Int32(dic.minMeditation) ?? 0
                    levelDB.maxPrep = Int32(dic.maxPrep) ?? 0
                    levelDB.maxRest = Int32(dic.maxRest) ?? 0
                    levelDB.maxMeditation = Int32(dic.maxMeditation) ?? 0
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
            let alert = UIAlertController(title: kAlertTitle,
                                          message: internetConnectionLostMsg,
                                          preferredStyle: UIAlertController.Style.alert)
            
            
            let OKAction = UIAlertAction.init(title: KOK, style: .default) { (UIAlertAction) in
                self.getMeditationDataAPI()
            }
            alert.addAction(OKAction)
            UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }
    }
    // API Calling
    
    func getMoodMeterDataAPI() {
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMOODMETERDATA, context: "WWMSplashLoaderVC", headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            
            self.executionTime = Date().timeIntervalSince(self.startDate)

            if sucess {
                self.saveMoodMeterDataToDB(data: result)
            }else {
                self.getMoodMeterDataFromDB()
            }
        }
    }
    
    
    func getMeditationDataAPI() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMEDITATIONDATA, context: "WWMSplashLoaderVC", headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            
            self.executionTime = Date().timeIntervalSince(self.startDate)
            
            if sucess {
                self.saveMeditationDataToDB(data: result)
            }else {
               self.getMeditationDataFromDB()
            }
        }
    }

}
