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

class WWMSplashLoaderVC: WWMBaseViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var lblLogo: UILabel!
    var animationView = AnimationView()
    var executionTime: Double = 0.0
    let startDate = Date()
    var alertPopupView1 = WWMAlertController()
    var animationSonicLogoView = AnimationView()
    var player: AVAudioPlayer?
    var playerLoaderAudio:  AVAudioPlayer?
    
    
    //to check which audio is play
    var flag = false
    
    //to run for sonic logo
    var stopLoaderAudio = false
    
    var loadSplashScreenafterDelayFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KUSERDEFAULTS.set("0", forKey: "restore")

        //WWMHelperClass.selectedType = ""
        self.lblLogo.isHidden = true
        self.setNavigationBar(isShow: false, title: "")
        //imageViewLoader.image = UIImage.gifImageWithName("SplashLoader")
        //self.saveMeditationDataToDB(data: ["":""])
        
        animationView = AnimationView(name: "loader")
        animationView.frame = CGRect(x: view.frame.size.width/2 - 200, y: view.frame.size.height/2 - 200, width: 400, height: 400)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        self.view.addSubview(animationView)
        
        //self.playSound(name: "LOADERSOUND")
        self.showForceUpdate()
    }
    
    func showForceUpdate() {
        WWMWebServices.requestAPIWithBodyForceUpdate(urlString: "https://beeja.s3.eu-west-2.amazonaws.com/mobile/config/update.json", context: "WWMSplashLoaderVC") { (result, error, success) in
            if success {
                
                //set url from backend using constant*
                if kBETA_ENABLED{
                    
                    print("I'm running in a non-DEBUG mode")
                    
                    if let baseUrl = result["base_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                    }
                }else{
                    
                    print("I'm running in DEBUG mode")
                    
                    if let baseUrl = result["staging_url"] as? String{
                        KUSERDEFAULTS.set(baseUrl, forKey: KBASEURL)
                    }else {
                        KUSERDEFAULTS.set("https://beta.beejameditation.com", forKey: KBASEURL)
                    }
                }//*end
                
                if let title = result["title"] as? String{
                    KUSERDEFAULTS.set(title, forKey: KFORCETOUPDATETITLE)
                }
                
                if let content = result["content"] as? String{
                    KUSERDEFAULTS.set(content, forKey: KFORCETOUPDATEDES)
                }
                
                if let button = result["button"] as? String{
                    KUSERDEFAULTS.set(button, forKey: KUPGRADEBUTTON)
                }
                
                if let version_name = result["version_name"] as? String{
                    KUSERDEFAULTS.set(version_name, forKey: kVERSION_NAME)
                }
                
                if let force_update = result["force_update"] as? Bool{
                    if force_update{
                        if self.needsUpdate(){
                            self.forceToUpdatePopUp()
                            //self.getMoodMeterDataAPI()
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
                
                print("appStoreVersion... \(String(describing: appStoreVersion)) currentVersion... \(String(describing: currentVersion)) AWS appVersion... \(KUSERDEFAULTS.string(forKey: kVERSION_NAME) ?? "")")
                
                if KUSERDEFAULTS.string(forKey: kVERSION_NAME) ?? "" != "" && currentVersion != ""{
                    
                    let awsVersionArray = (KUSERDEFAULTS.string(forKey: kVERSION_NAME)?.components(separatedBy: "."))!
                    let currentVersionArray = (currentVersion?.components(separatedBy: "."))!
                    
                    if awsVersionArray.count > 2 && currentVersionArray.count > 2{
                        
                        if Int(awsVersionArray[1])! < Int(currentVersionArray[1])!{
                            return false
                        }else if Int(awsVersionArray[0])! > Int(currentVersionArray[0])!{
                            return true
                        }else if Int(awsVersionArray[0])! < Int(currentVersionArray[0])!{
                            return false
                        }else if Int(awsVersionArray[2])! > Int(currentVersionArray[2])!{
                            return true
                        }
                    }
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
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSplashAnimationVC") as! WWMSplashAnimationVC
        //self.navigationController?.pushViewController(vc, animated: false)
        
        self.stopPlayer()
        self.pushToViewController()
    }
    
    func stopPlayer() {
        if let play = self.player {
            print("stopped")
            play.pause()
            player = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
        }
    }
    
    func pushToViewController(){
        if self.appPreference.isLogin() {
            if !self.appPreference.isProfileComplete() {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if self.appPreference.isLogout() {
                
                self.appPreference.setGetProfile(value: true)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }else if self.appPreference.isLogout() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        return
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
            
            self.stopLoaderAudio = false
            
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
                self.stopLoaderAudio = true
        
                print("excution..... \(self.executionTime)")
        }
    
    //MARK: Sonic
    func animateSonicLogo(){
        self.animationSonicLogoView = AnimationView(name: "sonicLogo")
        self.animationSonicLogoView.frame = CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 200, width: 300, height: 300)
        self.animationSonicLogoView.contentMode = .scaleAspectFit
        self.animationSonicLogoView.loopMode = .playOnce
        self.view.addSubview(self.animationSonicLogoView)
        self.playAudioFile(fileName: "SonicLogo")
    }
    
    func playAudioFile(fileName:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            player?.delegate = self
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            self.flag = true
            player?.play()
            
            if loadSplashScreenafterDelayFlag{
                return
            }
            
            self.animationSonicLogoView.play(completion: {animationFinished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.loadSplashScreenafterDelay()
                    self.loadSplashScreenafterDelayFlag = true
                    self.animationSonicLogoView.pause()
                }
            })
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getMeditationDataFromDB() {
        let dbData = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        if dbData.count > 0 {
            print("dbData... \(dbData) excution..... \(self.executionTime)")
            
            self.stopLoaderAudio = true
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
        
        if self.stopLoaderAudio{
                print("less....")
                            
                self.animationView.stop()
                self.animationView.isHidden = true
                self.lblLogo.isHidden = false
                                
                self.animateSonicLogo()
                
            //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // self.loadSplashScreenafterDelay()
            //}
                            
                
            return
        }
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETMOODMETERDATA, context: "WWMSplashLoaderVC", headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
            print("URL_GETMOODMETERDATA result... \(result)")
            self.executionTime = Date().timeIntervalSince(self.startDate)

            if sucess {
                self.saveMoodMeterDataToDB(data: result)
            }else {
                self.getMoodMeterDataFromDB()
            }
        }
    }
    
    
    func getMeditationDataAPI() {
        
        self.playSound(name: "LOADERSOUND")
        
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

extension WWMSplashLoaderVC{
    func playSound(name: String ) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            playerLoaderAudio = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            playerLoaderAudio?.delegate = self
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            playerLoaderAudio?.play()
            animationView.play(completion: {animationFinished in
                self.playerLoaderAudio?.pause()
                self.getMoodMeterDataAPI()
            })
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}

