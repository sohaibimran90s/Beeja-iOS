//
//  WWM21DayChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreData
import StoreKit

class WWM21DayChallengeVC: WWMBaseViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    
    @IBOutlet weak var viewBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var btnIntroTopConstraint: NSLayoutConstraint!
    
    var delegate: WWMGuidedDashboardDelegate?
    var category = ""
    var subCategory = ""
    var id = ""
    var name = ""

    var selectedIndex = 0
    var itemInfo: IndicatorInfo = "View"
    //var guidedData = WWMGuidedData()
    var type = ""
    var cat_name: String = ""
    var cat_id: Int = 0
    
    //upgrade beeja
    var selectedProductIndex = 2
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    var productIDs = ["get_108_gbp_lifetime_sub","get_42_gbp_annual_sub","get_6_gbp_monthly_sub","get_240_gbp_lifetime_sub"]
    var alertPopup = WWMAlertPopUp()
    var subscriptionAmount: String = "41.99"
    var subscriptionPlan: String = "annual"
    var responseArray: [[String: Any]] = []
    var buttonIndex = 1
    var continueRestoreValue: String = ""
    var boolGetIndex = false
    var restoreBool = false
    
    //21days
    let reachable = Reachabilities()
    var alertUpgradePopupView = WWMGuidedUpgradeBeejaPopUp()
    var stepToComplete = 0
    var isIntroCompleted = false
    var tile_type = ""
    var emotionId = 0
    var guided_id = 0
    var emotionKey = ""
    var guideTitleCount = 3
    var intro_url = ""
    
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = ""
    var arrGuidedList = [WWMGuidedData]()
    
    //to check if all the 21 steps completed
    var alertRetakePopupView = WWMAlertController()
    var retakeFlag = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewBannerHeightConstraint.constant = 0
        self.viewBanner.isHidden = true
        
        self.lblTitle.text = "\(self.category.capitalized): \(self.subCategory.capitalized)"
        self.setNavigationBar(isShow: false, title: "21Day Challenge: Practical")
        //print("guideTitleCount+++++++ \(guideTitleCount) id+++ \(id) self.category+++ \(self.category)")
        //self.appPreference.set21ChallengeName(value: self.category)
        self.fetchGuidedDataFromDB()
    }
    
    func showHidRetakeView(){
        //print("retakeFlag... \(self.retakeFlag) guided_id... \(self.id)")
        if self.retakeFlag == 21{
            self.btnIntroTopConstraint.constant = 30
            self.viewBannerHeightConstraint.constant = 58
            self.viewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 170)
            self.viewBanner.isHidden = false
        }else{
            self.btnIntroTopConstraint.constant = 10
            self.viewBannerHeightConstraint.constant = 0
            self.viewBanner.isHidden = true
            self.viewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 86)
        }
    }
    
    @IBAction func btnBack21DaysAction(_ sender: UIButton) {
        
        self.appPreference.set21ChallengeName(value: self.cat_name)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnRetakeAction(_ sender: UIButton) {
        
        //print("Retake button clicked")
        
        if reachable.isConnectedToNetwork() {
            self.xibRetake()
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func reloadTabs21DaysController(){
        self.navigationController?.isNavigationBarHidden = false
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationReloadGuidedTabs"), object: nil)
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 2 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK: Fetch Guided Data From DB
    func fetchGuidedDataFromDB() {
        let guidedEmotionsData = WWMHelperClass.fetchGuidedFilterDB(type: self.id, dbName: "DBGuidedEmotionsData", name: "guided_id")
        //print("self.type+++ \(self.type) self.id+++ \(self.id) guidedDataDB.count*** \(guidedEmotionsData.count)")
        
        if guidedEmotionsData.count == 0{
               singleGuidedAPI()
        }else{
           if self.appPreference.getLastTimeStamp21DaysBool(){
                singleGuidedAPI()
           }else{
                fetchGuidedDataFromDB1()
            }
        }
    }
    
    //MARK: Fetch Guided Data From DB
    func fetchGuidedDataFromDB1() {
        
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: self.id, dbName: "DBGuidedData", name: "guided_id")
        //print("self.type+++ \(self.type) self.id+++ \(self.id) guidedDataDB.count*** \(guidedDataDB.count)")
        
        if guidedDataDB.count > 0{
            //print("guidedDataDB count... \(guidedDataDB.count)")
            
            self.arrGuidedList.removeAll()
            
            var jsonString: [String: Any] = [:]
            var jsonEmotionsString: [String: Any] = [:]
            var jsonEmotions: [[String: Any]] = []
            var jsonAudiosString: [String: Any] = [:]
            var jsonAudios: [[String: Any]] = []
            
            for dict in guidedDataDB {
                
                if (dict as AnyObject).meditation_type as? String == "practical"{
                    if (dict as AnyObject).intro_completed{
                        self.appPreference.setPracticalChallenge(value: true)
                    }
                }
                
                if (dict as AnyObject).meditation_type as? String == "spiritual"{
                    if (dict as AnyObject).intro_completed{
                        self.appPreference.setSpiritualChallenge(value: true)
                    }
                }
                
                jsonString["id"] = Int((dict as AnyObject).guided_id ?? "0")
                jsonString["name"] = (dict as AnyObject).guided_name as? String
                jsonString["meditation_type"] = (dict as AnyObject).meditation_type as? String
                jsonString["mode"] = (dict as AnyObject).guided_mode as? String
                jsonString["min_limit"] = (dict as AnyObject).min_limit as? String ?? "95"
                jsonString["max_limit"] = (dict as AnyObject).max_limit as? String ?? "98"
                jsonString["meditation_key"] = (dict as AnyObject).meditation_key as? String ?? "practical"
                jsonString["complete_count"] = (dict as AnyObject).complete_count as? String ?? "0"
                jsonString["intro_url"] = (dict as AnyObject).intro_url as? String ?? ""
                
                let guidedEmotionsDataDB = WWMHelperClass.fetchGuidedFilterEmotionsDB(guided_id: (dict as AnyObject).guided_id ?? "0", dbName: "DBGuidedEmotionsData", name: "guided_id")
                
                for dict1 in guidedEmotionsDataDB{
                    
                    if (dict1 as AnyObject).completed{
                        self.retakeFlag = self.retakeFlag + 1
                    }
                    
                    if (dict as AnyObject).meditation_type as? String == "practical"{
                        if (dict1 as AnyObject).intro_completed{
                            self.appPreference.setPracticalChallenge(value: true)
                        }
                    }
                    
                    if (dict as AnyObject).meditation_type as? String == "spiritual"{
                        if (dict1 as AnyObject).intro_completed{
                            self.appPreference.setSpiritualChallenge(value: true)
                        }
                    }
                                        
                    jsonEmotionsString["emotion_id"] = Int((dict1 as AnyObject).emotion_id ?? "0")
                    jsonEmotionsString["emotion_name"] = (dict1 as AnyObject).emotion_name ?? ""
                    jsonEmotionsString["emotion_image"] = (dict1 as AnyObject).emotion_image ?? ""
                    jsonEmotionsString["tile_type"] = (dict1 as AnyObject).tile_type ?? ""
                    jsonEmotionsString["author_name"] = (dict1 as AnyObject).author_name ?? ""
                    jsonEmotionsString["emotion_body"] = (dict1 as AnyObject).emotion_body ?? ""
                    jsonEmotionsString["emotion_key"] = (dict1 as AnyObject).emotion_key ?? ""
                    jsonEmotionsString["intro_completed"] = (dict1 as AnyObject).intro_completed ?? false
                    jsonEmotionsString["completed"] = (dict1 as AnyObject).completed ?? false
                    jsonEmotionsString["completed_date"] = (dict1 as AnyObject).completed_date ?? ""
                    jsonEmotionsString["intro_url"] = (dict1 as AnyObject).intro_url ?? ""
                    jsonEmotionsString["emotion_type"] = (dict1 as AnyObject).emotion_type ?? ""
                    
                    let guidedAudiosDataDB = WWMHelperClass.fetchGuidedFilterAudiosDB(emotion_id: (dict1 as AnyObject).emotion_id ?? "0", dbName: "DBGuidedAudioData")
                    //print("guidedAudiosDataDB count... \(guidedAudiosDataDB.count)")
                    
                    for dict2 in guidedAudiosDataDB{
                        
                        //print("dict2.... \(dict2)")
                        jsonAudiosString["emotion_id"] = Int((dict2 as AnyObject).emotion_id ?? "0")
                        jsonAudiosString["id"] = Int((dict2 as AnyObject).audio_id ?? "0")
                        jsonAudiosString["audio_name"] = (dict2 as AnyObject).audio_name ?? ""
                        jsonAudiosString["duration"] = Int((dict2 as AnyObject).duration ?? "0")
                        jsonAudiosString["paid"] = (dict2 as AnyObject).paid ?? false
                        jsonAudiosString["audio_image"] = (dict2 as AnyObject).audio_image ?? ""
                        jsonAudiosString["audio_url"] = (dict2 as AnyObject).audio_url ?? ""
                        jsonAudiosString["vote"] = (dict2 as AnyObject).vote ?? false

                        jsonAudios.append(jsonAudiosString)
                    }
                    
                    jsonEmotionsString["audio_list"] = jsonAudios
                    jsonEmotions.append(jsonEmotionsString)
                    jsonAudios.removeAll()
                }
                
                jsonString["emotion_list"] = jsonEmotions
                jsonEmotions.removeAll()
                let guidedData = WWMGuidedData.init(json: jsonString)
                self.arrGuidedList.append(guidedData)
                
                self.showHidRetakeView()
            }
            print(self.arrGuidedList.count)
            if self.arrGuidedList.count > 0{
                self.expandableCellLogic()
                self.tableView.reloadData()
            }
        }
    }
    
    func singleGuidedAPI() {
        
        let param = ["user_id": self.appPreference.getUserID(), "id": self.id] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SINGLEGUIDED, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                
                if let result = result["result"] as? [String:Any] {
                    //print("success result... \(result)")
                    
                    var emotionId = ""
                    let guidedEmotionsData = WWMHelperClass.fetchGuidedFilterDB(type: self.id, dbName: "DBGuidedEmotionsData", name: "guided_id")
                    if guidedEmotionsData.count > 0{
                        for dict in guidedEmotionsData{
                            if let emotion_id = (dict as AnyObject).emotion_id{
                                emotionId = "\(emotion_id ?? "")"
                            }
                        }
                        WWMHelperClass.deleteRowfromDb(dbName: "DBGuidedEmotionsData", id: self.id, type: "guided_id")
                    }
                    
                    if emotionId != ""{
                        let guidedAudioData = WWMHelperClass.fetchGuidedFilterDB(type: emotionId, dbName: "DBGuidedAudioData", name: "emotion_id")
                        
                        if guidedAudioData.count > 0{
                            for dict in guidedAudioData{
                                if let _ = (dict as AnyObject).audio_id{
                                    WWMHelperClass.deleteRowfromDb(dbName: "DBGuidedAudioData", id: emotionId, type: "emotion_id")
                                }
                            }
                        }
                    }
                    
                    if let emotion_list = result["emotion_list"] as? [[String: Any]]{
                        for emotionsDict in emotion_list {
                            
                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                            
                            dbGuidedEmotionsData.guided_id = "\(self.id)"
                            
                            if let emotion_id = emotionsDict["emotion_id"]{
                                dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                            }
                            
                            if let author_name = emotionsDict["author_name"]{
                                dbGuidedEmotionsData.author_name = "\(author_name)"
                            }
                            
                            if let emotion_image = emotionsDict["emotion_image"] as? String{
                                dbGuidedEmotionsData.emotion_image = emotion_image
                            }
                            
                            if let emotion_name = emotionsDict["emotion_name"] as? String{
                                dbGuidedEmotionsData.emotion_name = emotion_name
                            }
                            
                            if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                dbGuidedEmotionsData.intro_completed = intro_completed
                            }else{
                                dbGuidedEmotionsData.intro_completed = false
                            }
                            
                            if let tile_type = emotionsDict["tile_type"] as? String{
                                dbGuidedEmotionsData.tile_type = tile_type
                            }
                            
                            if let emotion_key = emotionsDict["emotion_key"] as? String{
                                dbGuidedEmotionsData.emotion_key = emotion_key
                            }
                            
                            if let emotion_body = emotionsDict["emotion_body"] as? String{
                                dbGuidedEmotionsData.emotion_body = emotion_body
                            }
                            
                            if let completed = emotionsDict["completed"] as? Bool{
                                dbGuidedEmotionsData.completed = completed
                            }
                            
                            if let completed_date = emotionsDict["completed_date"] as? String{
                                dbGuidedEmotionsData.completed_date = completed_date
                            }
                            
                            if let intro_url = emotionsDict["intro_url"] as? String{
                                dbGuidedEmotionsData.intro_url = intro_url
                            }else{
                                dbGuidedEmotionsData.intro_url = ""
                            }
                            
                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                dbGuidedEmotionsData.emotion_type = emotion_type
                            }else{
                                dbGuidedEmotionsData.emotion_type = ""
                            }
                                                        
                            if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                for audioDict in audio_list {
                                    
                                    let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                    
                                    if let emotion_id = emotionsDict["emotion_id"]{
                                        dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                    }
                                    
                                    if let audio_id = audioDict["id"]{
                                        dbGuidedAudioData.audio_id = "\(audio_id)"
                                    }
                                    
                                    if let audio_image = audioDict["audio_image"] as? String{
                                        dbGuidedAudioData.audio_image = audio_image
                                    }
                                    
                                    if let audio_name = audioDict["audio_name"] as? String{
                                        dbGuidedAudioData.audio_name = audio_name
                                    }
                                    
                                    if let audio_url = audioDict["audio_url"] as? String{
                                        dbGuidedAudioData.audio_url = audio_url
                                    }
                                    
                                    if let author_name = audioDict["author_name"] as? String{
                                        dbGuidedAudioData.author_name = author_name
                                    }
                                    
                                    if let duration = audioDict["duration"]{
                                        dbGuidedAudioData.duration = "\(duration)"
                                    }
                                    
                                    if let paid = audioDict["paid"] as? Bool{
                                        dbGuidedAudioData.paid = paid
                                    }
                                    
                                    if let vote = audioDict["vote"] as? Bool{
                                        dbGuidedAudioData.vote = vote
                                    }
                                                                        
                                    WWMHelperClass.saveDb()
                                }
                            }
                            WWMHelperClass.saveDb()
                        }
                        self.fetchGuidedDataFromDB1()
                    }
                }
            }
        }
    }
    
    func expandableCellLogic(){
        
        //* logic for expanding the cell which we have to play
        
        var flag = 0
        
        for i in 0..<self.arrGuidedList[0].cat_EmotionList.count{
            //print("date_completed... \(self.arrGuidedList[0].cat_EmotionList[i].completed_date) completed... \(self.arrGuidedList[0].cat_EmotionList[i].completed)")
            
            if i !=  self.arrGuidedList[0].cat_EmotionList.count - 1{
                if self.arrGuidedList[0].cat_EmotionList[i].completed == true{
                    self.selectedIndex = i + 1
                    flag = 1
                }
            }
        }
        
        if flag == 0{
            self.selectedIndex = 0
        }
        //*end here
    }
        
    @IBAction func introBtnAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC

        vc.videoURL = self.intro_url
        vc.value = "21_days"
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension WWM21DayChallengeVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if self.cat_name.contains("21"){
        
        if self.arrGuidedList.count > 0{
            return self.arrGuidedList[0].cat_EmotionList.count
        }else{
            return 0
        }
           // return self.guidedData.cat_EmotionList.count
        //}else{
          //  return self.guidedData.cat_EmotionList.count/3
        //}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWM21DayChallengeTVC") as! WWM21DayChallengeTVC
        
        let data = self.arrGuidedList[0].cat_EmotionList[indexPath.row]
        
        if indexPath.row == 0{
            cell.upperLineLbl.isHidden = true
        }else{
            cell.upperLineLbl.isHidden = false
        }
        
        cell.daysLbl.text = "DAY \(data.step_id)"
        cell.titleLbl.text = data.emotion_Name
        cell.authorLbl.text = "Guided Meditation By \(data.author_name)"
        
        if data.completed{
            cell.imgTick.isHidden = false
            cell.stepLbl.isHidden = true
            cell.upperLineLbl.backgroundColor = UIColor.white
            cell.belowLineLbl.backgroundColor = UIColor.white
            
            stepToComplete = indexPath.row + 1
        }else if stepToComplete == indexPath.row{
            cell.stepLbl.layer.cornerRadius = 12
            cell.stepLbl.text = "\(data.step_id)"
            cell.imgTick.isHidden = true
            cell.stepLbl.isHidden = false
            
            cell.upperLineLbl.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.belowLineLbl.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.stepLbl.textColor = UIColor.black
            cell.stepLbl.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        }else{
            
            cell.stepLbl.layer.cornerRadius = 12
            cell.stepLbl.text = "\(data.step_id)"
            cell.imgTick.isHidden = true
            cell.stepLbl.isHidden = false
            
            cell.stepLbl.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            cell.upperLineLbl.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            cell.belowLineLbl.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            cell.stepLbl.textColor = UIColor.black.withAlphaComponent(0.5)
        }

        if selectedIndex == indexPath.row{
            cell.descLbl.isHidden = false
            cell.imgIcon.isHidden = false
            cell.imgBackView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 0.8)
            cell.arrowImg.image = UIImage(named: "upArrow")
            cell.collectionView.isHidden = false
        }else{
            cell.descLbl.isHidden = true
            cell.imgIcon.isHidden = true
            cell.imgBackView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            cell.arrowImg.image = UIImage(named: "downArrow")
            cell.collectionView.isHidden = true
            
        }
        
        //let collHeight = (44 * data.audio_list.count)
        let collHeight = (46 *  data.audio_list.count) + (10 * (data.audio_list.count - 1))
        cell.collectionViewHeightConstraint.constant = CGFloat(collHeight)
        
        //print("collHeight**** \(collHeight) self.arrGuidedList[0].cat_EmotionList.count*** \(data.audio_list.count)")
        cell.collectionView.tag = indexPath.row
        let layout = UICollectionViewFlowLayout()
        cell.collectionView.collectionViewLayout = layout
        layout.scrollDirection = .vertical
        cell.collectionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 74
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        //print(self.arrGuidedList[0].cat_EmotionList[selectedIndex].completed)
        //tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        self.tableView.reloadData()
    }
}

extension WWM21DayChallengeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrGuidedList[0].cat_EmotionList[collectionView.tag].audio_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WWM21DayChallengeCVC", for: indexPath) as! WWM21DayChallengeCVC
        
        let data = self.arrGuidedList[0].cat_EmotionList[collectionView.tag]
        
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        DispatchQueue.main.async {
            cell.lblAudioTime.text = "\(self.secondToMinuteSecond(second: data.audio_list[indexPath.item].audio_Duration))"
            
            if self.appPreference.getIsSubscribedBool(){
                cell.lockImg.image = UIImage(named: "")
                cell.lockImg.isHidden = true
            }else{
                //print("data.audio_list[indexPath.item].audio_Duration... \(data.audio_list[indexPath.item].audio_Duration)")
                if data.audio_list[indexPath.item].audio_Duration <= 900{
                    cell.lockImg.image = UIImage(named: "")
                    cell.lockImg.isHidden = true
                }else{
                    cell.lockImg.image = UIImage(named: "lock1")
                    cell.lockImg.isHidden = false
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
        if self.retakeFlag == 21{
            //print("challenge completed")
        }else{
            let data = self.arrGuidedList[0].cat_EmotionList[collectionView.tag]
            if self.guideTitleCount > 3 && self.cat_name.contains("21"){
            }else{
                if self.appPreference.getIsSubscribedBool(){
                    
                    //to check if 7 days accepted than 21 days will not be cliced
                    if self.name == "21 Days challenge"{
                        if self.check7DaysChallenge(){
                            //print("7 days challenge accepted")
                            self.xibCall1(title1: "You have accepted 7 Days Challenge")
                        }else{
                            WWMHelperClass.sendEventAnalytics(contentType: "CHALLENGE", itemId: "CHALLENGE_ACTIONED_\(self.subCategory.uppercased())", itemName: "21DAYS")
                            self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
                        }
                    }else{
                        WWMHelperClass.sendEventAnalytics(contentType: "CHALLENGE", itemId: "CHALLENGE_ACTIONED_\(self.subCategory.uppercased())", itemName: "7DAYS")
                        self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
                    }
                    //*
                    
                }else{
                    if data.audio_list[indexPath.item].audio_Duration <= 900{
                        
                        //to check if 7 days accepted than 21 days will not be cliced
                        if self.name == "21 Days challenge"{
                            print(self.check7DaysChallenge())
                            if self.check7DaysChallenge(){
                                //print("7 days challenge accepted")
                                self.xibCall1(title1: "You have accepted 7 Days Challenge")
                            }else{
                                self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
                            }
                        }else{
                            self.pushViewController(table_cell_tag: collectionView.tag, collection_cell_tag: indexPath.item)
                        }
                        //*
                        
                    }else{
                        self.purchaseSubscription()
                        //*
                    }
                }
            }
            //print("data....+++++ \(data.emotion_Id) \(data.completed) \(data.completed_date) data.tile_type+++++++++ \(data.tile_type) cat_name++++++ \(self.cat_name)")
        }
    }
    
    func check7DaysChallenge() -> Bool{
        let guidedDataDB = WWMHelperClass.fetchGuidedFilterDB(type: "7 Days challenge", dbName: "DBGuidedData", name: "guided_name")
        //print("guidedDataDB.count*** \(guidedDataDB.count) 21 days")
        if guidedDataDB.count > 0{
            for dict in guidedDataDB {
                let meditation_type = ((dict as AnyObject).meditation_type) ?? "Spiritual"
                //print("subCategory \(subCategory) meditation_type \(meditation_type)")
                if subCategory == meditation_type{
                    return true
                }
            }
        }
        return false
    }
    
    func purchaseSubscription(){
        if reachable.isConnectedToNetwork() {
            xibCall()
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    
    func pushViewController(table_cell_tag: Int, collection_cell_tag: Int) {
        
        //print(self.cat_name)
        WWMHelperClass.sendEventAnalytics(contentType: "CHALLENGE", itemId: "CHALLENGE_21DAYS", itemName: "\(table_cell_tag)")
        if reachable.isConnectedToNetwork() {
            var flag = 0
            var position = 0
            
            let data = self.arrGuidedList[0].cat_EmotionList[table_cell_tag]
            
            if data.completed{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
                
                WWMHelperClass.stepsCompleted = data.completed
                vc.audioData = data.audio_list[collection_cell_tag]
                vc.cat_id = "\(self.cat_id)"
                vc.cat_Name = self.cat_name
                vc.emotion_Id = "\(data.emotion_Id)"
                vc.emotion_Name = data.emotion_Name
                vc.seconds = data.audio_list[collection_cell_tag].audio_Duration
                vc.min_limit = self.min_limit
                vc.max_limit = self.max_limit
                vc.meditation_key = self.meditation_key
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
                return
            }else{
                for i in 0..<table_cell_tag{
                    let date_completed = self.arrGuidedList[0].cat_EmotionList[i].completed_date
                    if date_completed != ""{
                        let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                        if dateCompare.0 == 1{
                            flag = 1
                            break
                        }
                    }
                }
            }
            
            if flag == 1{
                self.xibCall1(title1: KLEARNONESTEP)
                return
            }
            
            for i in 0..<table_cell_tag{
                if !self.arrGuidedList[0].cat_EmotionList[i].completed{
                    flag = 2
                    position = i
                    break
                }
            }
            
            if flag == 2{
                
                //print("first play the \(self.arrGuidedList[0].cat_EmotionList[position].emotion_Name) position+++ \(position)")
                
                self.xibCall1(title1: "\(KLEARNJUMPSTEP) \(self.arrGuidedList[0].cat_EmotionList[position].step_id)")
            }else{
                
                self.appPreference.setType(value: "guided")
                WWMHelperClass.days21StepNo = "Step \(data.step_id)"
                WWMHelperClass.stepsCompleted = data.completed
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
                vc.audioData = data.audio_list[collection_cell_tag]
                vc.cat_id = "\(self.cat_id)"
                vc.cat_Name = self.cat_name
                vc.emotion_Id = "\(data.emotion_Id)"
                vc.emotion_Name = data.emotion_Name
                vc.seconds = data.audio_list[collection_cell_tag].audio_Duration
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func xibCall1(title1: String){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertPopup.lblTitle.text = title1
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
            }
        }
    }
}


extension WWM21DayChallengeVC: SKProductsRequestDelegate,SKPaymentTransactionObserver{
    
    func xibCall(){
        alertUpgradePopupView = UINib(nibName: "WWMGuidedUpgradeBeejaPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMGuidedUpgradeBeejaPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertUpgradePopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.boolGetIndex = true
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)
        
        self.getSubscriptionPlanId()
        
        alertUpgradePopupView.viewAnnually.isHidden = false
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = true
        
        alertUpgradePopupView.viewMonthly.layer.borderWidth = 2.0
        alertUpgradePopupView.viewLifeTime.layer.borderWidth = 2.0
        alertUpgradePopupView.viewAnnually.layer.borderWidth = 2.0
        
        alertUpgradePopupView.viewMonthly.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertUpgradePopupView.viewLifeTime.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertUpgradePopupView.viewAnnually.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertUpgradePopupView.btnAnnually.addTarget(self, action: #selector(btnAnnuallyAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnMontly.addTarget(self, action: #selector(btnMontlyAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnLifeTime.addTarget(self, action: #selector(btnLifeTimeAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnRestore.addTarget(self, action: #selector(btnRestoreAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnContinue.addTarget(self, action: #selector(btnContinueAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        //redeem coupon
        alertUpgradePopupView.viewRedeemCoupon.isHidden = true
        alertUpgradePopupView.viewACoupon.isHidden = false
        alertUpgradePopupView.btnACoupon.addTarget(self, action: #selector(btnACouponAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnRCoupon.addTarget(self, action: #selector(btnRCouponAction(_:)), for: .touchUpInside)
        alertUpgradePopupView.btnCross.addTarget(self, action: #selector(btnCrossAction(_:)), for: .touchUpInside)
        
        //textfield delegate
        alertUpgradePopupView.textField1.delegate = self
        alertUpgradePopupView.textField2.delegate = self
        alertUpgradePopupView.textField3.delegate = self
        alertUpgradePopupView.textField4.delegate = self
        alertUpgradePopupView.textField5.delegate = self
        alertUpgradePopupView.textField6.delegate = self
        
        window.rootViewController?.view.addSubview(alertUpgradePopupView)
    }
    
    @objc func btnACouponAction(_ sender: Any){
        alertUpgradePopupView.viewRedeemCoupon.isHidden = false
        alertUpgradePopupView.viewACoupon.isHidden = true
    }
    
    @objc func btnRCouponAction(_ sender: Any){
        let obj = WWMUpgradeBeejaVC()
        let redeemCode = "\(alertUpgradePopupView.textField1.text ?? "")\(alertUpgradePopupView.textField2.text ?? "")\(alertUpgradePopupView.textField3.text ?? "")\(alertUpgradePopupView.textField4.text ?? "")\(alertUpgradePopupView.textField5.text ?? "")\(alertUpgradePopupView.textField6.text ?? "")"

        if redeemCode.count == 6{
            obj.getRedeemCodeAPI(redeemCode: redeemCode, type: "popUp", controller: alertUpgradePopupView)
        }else{
            WWMHelperClass.showPopupAlertController(sender: self, message: "Please enter correct coupon code", title: "")
        }
    }
    
     @objc func btnCrossAction(_ sender: Any){
        alertUpgradePopupView.viewRedeemCoupon.isHidden = true
        alertUpgradePopupView.viewACoupon.isHidden = false
    }//redeem coupon end*
    
    @objc func btnAnnuallyAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 1
        self.subscriptionPlan = "annual"
        self.subscriptionAmount = "41.99"
        alertUpgradePopupView.lblBilledText.text = KBILLEDTEXT
        alertUpgradePopupView.viewAnnually.isHidden = false
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_42_gbp_annual_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_42_gbp_annual_sub... \(self.selectedProductIndex)")
                
                Logger.logger.generateLogs(type: "Annually", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected index... \(self.selectedProductIndex)")
            }
            //print(product.productIdentifier)
        }
    }
    
    @objc func btnMontlyAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 0
        self.subscriptionPlan = "Monthly"
        self.subscriptionAmount = "5.99"
        alertUpgradePopupView.lblBilledText.text = ""
        alertUpgradePopupView.viewAnnually.isHidden = true
        alertUpgradePopupView.viewLifeTime.isHidden = true
        alertUpgradePopupView.viewMonthly.isHidden = false
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_6_gbp_monthly_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_6_gbp_monthly_sub... \(self.selectedProductIndex)")
                
                Logger.logger.generateLogs(type: "Monthly", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected index... \(self.selectedProductIndex )")
            }
            //print(product.productIdentifier)
        }
    }
    
    @objc func btnLifeTimeAction(_ sender: Any){
        self.boolGetIndex = false
        self.buttonIndex = 3
        self.subscriptionPlan = "Lifetime"
        self.subscriptionAmount = "239.99"
        alertUpgradePopupView.lblBilledText.text = ""
        alertUpgradePopupView.viewAnnually.isHidden = true
        alertUpgradePopupView.viewLifeTime.isHidden = false
        alertUpgradePopupView.viewMonthly.isHidden = true
        for index in 0..<self.productsArray.count {
            let product = self.productsArray[index]
            if product.productIdentifier == "get_240_gbp_lifetime_sub" {
                self.selectedProductIndex = index
                self.boolGetIndex = true
                //print("selectedProductIndex get_240_gbp_lifetime_sub... \(self.selectedProductIndex)")
                
                Logger.logger.generateLogs(type: "LifeTime", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected index... \(self.selectedProductIndex)")
            }
            //print(product.productIdentifier)
        }
    }
    
    @objc func btnRestoreAction(_ sender: Any){
        
        Logger.logger.generateLogs(type: "Restore", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected index... \(self.selectedProductIndex)")
        self.continueRestoreValue = "1"
        if (SKPaymentQueue.canMakePayments()){
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    @objc func btnContinueAction(_ sender: Any){
        if self.boolGetIndex{
            if self.selectedProductIndex == 3 {
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "MONTHLY")
            }else if self.selectedProductIndex == 2 {
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "ANNUAL")
            }else if self.selectedProductIndex == 1{
                WWMHelperClass.sendEventAnalytics(contentType: "BURGERMENU", itemId: "UPGRADE", itemName: "LIFETIME")
            }
            
            Logger.logger.generateLogs(type: "Continue", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected index... \(self.selectedProductIndex)")
            self.continueRestoreValue = "0"
            if reachable.isConnectedToNetwork() {
                self.showActions()
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
            }
        }
    }
    
    @objc func btnCloseAction(_ sender: Any){
    }
    
    // MARK:- Get Product Data from Itunes
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs as [Any])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as Set<NSObject> as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
            
            Logger.logger.generateLogs(type: "Request Product Info", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "productRequest…… \(productRequest)")
        }
        else {
            //print("Cannot perform In App Purchases.")
            Logger.logger.generateLogs(type: "Request Product Info", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "Cannot perform In App Purchases")
        }
    }
    
    func showActions() {
        if transactionInProgress {
            
            Logger.logger.generateLogs(type: "Transaction In Progress", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "transaction in progress return")
            return
        }
        
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = kAlertTitle
        alertPopupView.lblSubtitle.text = KBUYBOOKTITLE
        alertPopupView.btnOK.setTitle(KBUY, for: .normal)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if  self.productsArray.count > 0 {
            
            //print("self.productsArray[self.selectedProductIndex]... \(self.productsArray[self.selectedProductIndex])")
            
            let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] )
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
            //WWMHelperClass.showSVHud()
            WWMHelperClass.showLoaderAnimate(on: self.view)
            
             Logger.logger.generateLogs(type: "Purchase", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "selected product... \(self.productsArray[self.selectedProductIndex])")
        }else {
            self.requestProductInfo()
        }
    }
    
    // MARK:- Payment Delegate Methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product )
                //print(product.localizedTitle)
                //print(product.productIdentifier)
                
                Logger.logger.generateLogs(type: "SKProductsRequest", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "productsArray... \(productsArray)")
            }
        }
        else {
            //print("There are no products.")
            
            Logger.logger.generateLogs(type: "Error: SKProductsRequest", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            //print(response.invalidProductIdentifiers.description)
            
            Logger.logger.generateLogs(type: "SKProductsRequest", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "\(response.invalidProductIdentifiers.description)")
        }
        // WWMHelperClass.dismissSVHud()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased, .restored:
                //print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                print(transaction.transactionIdentifier as Any)
                
                var plan_id: Int = 2
                var subscriptionPlan: String = "annual"
                
                //print("responseArray.count..... \(responseArray.count) \(responseArray)")
                if responseArray.count > buttonIndex{
                    if let dict = self.responseArray[buttonIndex] as? [String: Any]{
                        if let id = dict["id"] as? Int{
                            plan_id = id
                        }
                        if let name = dict["name"] as? String{
                            subscriptionPlan = name
                        }
                    }
                }
                //"plan_id" : transaction.payment.productIdentifier
                //"subscription_plan" : self.subscriptionPlan
                
                Logger.logger.generateLogs(type: "Updated Transactions", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "subscriptionPlan \(subscriptionPlan) plan_id \(plan_id)")
                
                let param = [
                    "plan_id" : plan_id,
                    "user_id" : self.appPreference.getUserID(),
                    "subscription_plan" : subscriptionPlan,
                    "date_time" : transaction.transactionDate!.timeIntervalSince1970 * 1000,
                    "transaction_id" : transaction.transactionIdentifier! as Any,
                    "amount" : self.subscriptionAmount
                    ] as [String : Any]
                
                //print("param,,,,... \(param)")
                
                if !self.restoreBool{
                    self.subscriptionSucessAPI(param: param)
                }
                
                Logger.logger.generateLogs(type: "Success: Updated Transactions", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "plan_id \(param)")
                
            case SKPaymentTransactionState.failed:
                //print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                //WWMHelperClass.dismissSVHud()
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                
                Logger.logger.generateLogs(type: "Error: Transaction State Failed", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "transaction failed")
            default:
                //print(transaction.transactionState.rawValue)
                
                Logger.logger.generateLogs(type: "Default: Transaction State", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "transaction in default \(transaction.transactionState.rawValue)")
            }
        }
    }
    
    func getSubscriptionPlanId(){
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_GETSUBSCRIPTIONPPLANS, context: "WWMUpgradeBeejaVC", headerType: kGETHeader, isUserToken: false) { (response, error, sucess) in
            if sucess {
                if let result = response["result"] as? [[String: Any]]{
                    self.responseArray = result
                    //print("result.... \(result)")
                    
                    Logger.logger.generateLogs(type: "Success: getSubscriptionPlanId", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "responseArray \(self.responseArray)")
                }
            }else {
                
                //The Internet connection appears to be offline.
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                    Logger.logger.generateLogs(type: "Error: getSubscriptionPlanId", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "error?.localizedDescription \(error?.localizedDescription ?? "")")
                    
                }
                
                Logger.logger.generateLogs(type: "Error: getSubscriptionPlanId", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "response fail")
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func subscriptionSucessAPI(param : [String : Any]) {
        
        //print("param.....###### \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_SUBSCRIPTIONPURCHASE, context: "WWMUpgradeBeejaVC", headerType: kPOSTHeader, isUserToken: true) { (response, error, sucess) in
            if sucess {
                
                Logger.logger.generateLogs(type: "Success: SubscriptionSucessAPI", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "param \(param)")
                
                if self.continueRestoreValue == "1"{
                    
                    Logger.logger.generateLogs(type: "Success: continueRestoreValue: 1", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "param \(param)")
                    
                    if !self.restoreBool{
                        KUSERDEFAULTS.set("1", forKey: "restore")
                        self.restoreBool = true
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        
                        return
                    }
                }else{
                    
                    Logger.logger.generateLogs(type: "Success: continueRestoreValue: 0", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "param \(param)")
                    
                    if !self.restoreBool{
                        KUSERDEFAULTS.set("0", forKey: "restore")
                        self.restoreBool = true
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        
                        return
                    }
                }
            }else {
                
                //The Internet connection appears to be offline.
                if error != nil {
                    
                    Logger.logger.generateLogs(type: "Fail: SubscriptionSucessAPI", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "error?.localizedDescription \(error?.localizedDescription ?? "")")
                    
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                        return
                    }else{
                        
                        if self.continueRestoreValue == "1"{
                            WWMHelperClass.showPopupAlertController(sender: self, message: KRESTOREPROBTITLE, title: KRESTOREPROBSUBTITLE)
                        }else{
                            WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                        }
                        
                        return
                    }
                }
                
                 Logger.logger.generateLogs(type: "Fail: SubscriptionSucessAPI", user_id: self.appPreference.getUserID(), filePath: #file, line: #line, column: #column, function: #function, logText: "api fail")
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}

extension WWM21DayChallengeVC{
    
    func xibRetake(){
        self.alertRetakePopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertRetakePopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertRetakePopupView.btnOK.layer.borderWidth = 2.0
        alertRetakePopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        alertRetakePopupView.btnClose.setTitle(KCANCEL, for: .normal)
        alertRetakePopupView.btnOK.setTitle(KOK, for: .normal)
        alertRetakePopupView.lblSubtitle.text = "Retake Challenge"
        alertRetakePopupView.lblSubtitle.text = "Are you ready to retake challenge if you do it will remove the previous progress"
        alertRetakePopupView.btnClose.addTarget(self, action: #selector(btnRetakeCloseAction(_:)), for: .touchUpInside)
        alertRetakePopupView.btnOK.addTarget(self, action: #selector(btnRetakeDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertRetakePopupView)
    }
    
    @objc func btnRetakeCloseAction(_ sender: Any){
        self.alertPopup.removeFromSuperview()
    }
    
    @objc func btnRetakeDoneAction(_ sender: Any){
        self.alertPopup.removeFromSuperview()
        self.retakeChallengeApi(guided_id: self.id)
    }
    
    func retakeChallengeApi(guided_id: String) {
        self.view.endEditing(true)
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "user_id"       : self.appPreference.getUserID(),
            "guided_id"     : guided_id,
            "type"          : "",
            "action"        : "flushdata"
            ] as [String : Any]
        
        //print("retakeChallenge param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_RETAKE, context: "WWM21DayChallengeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //print("retake api... \(result)")
                self.appPreference.setType(value: "guided")
                self.appPreference.setGuideType(value: "21 Days challenge")
                self.appPreference.setGuideTypeFor3DTouch(value: "guided")
                
                self.getGuidedListAPI1()
            }else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
        }
    }
    
    func getGuidedListAPI1() {

        let param = ["user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWM21DayChallengeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success result... getGuidedListAPI \(result)")
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    self.appPreference.set21ChallengeName(value: "21 Days challenge")
                    if let result = result["result"] as? [[String:Any]] {
                        
                        //print("audioList... \(result)")
                        
                        let guidedData = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
                        if guidedData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                        }
                        
                        let guidedEmotionsData = WWMHelperClass.fetchDB(dbName: "DBGuidedEmotionsData") as! [DBGuidedEmotionsData]
                        if guidedEmotionsData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                        }
                        
                        let guidedAudioData = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                        if guidedAudioData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                        }
                        
                        for dict in result {
                            
                            if let meditation_list = dict["meditation_list"] as? [[String: Any]]{
                                
                                for meditationList in meditation_list {
                                    let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                                    
                                    let timeInterval = Int(Date().timeIntervalSince1970)
                                    
                                    dbGuidedData.last_time_stamp = "\(timeInterval)"
                                    dbGuidedData.cat_name = dict["name"] as? String
                                    
                                    if let id = meditationList["id"]{
                                        dbGuidedData.guided_id = "\(id)"
                                    }
                                    
                                    if let name = meditationList["name"] as? String{
                                        dbGuidedData.guided_name = name
                                    }
                                    
                                    if let meditation_type = meditationList["meditation_type"] as? String{
                                        dbGuidedData.meditation_type = meditation_type
                                    }
                                    
                                    if let guided_mode = meditationList["mode"] as? String{
                                        dbGuidedData.guided_mode = guided_mode
                                    }
                                    
                                    if let min_limit = meditationList["min_limit"] as? String{
                                        dbGuidedData.min_limit = min_limit
                                    }else{
                                        dbGuidedData.min_limit = "95"
                                    }
                                    
                                    if let max_limit = meditationList["max_limit"] as? String{
                                        dbGuidedData.max_limit = max_limit
                                    }else{
                                        dbGuidedData.max_limit = "98"
                                    }
                                    
                                    if let meditation_key = meditationList["meditation_key"] as? String{
                                        dbGuidedData.meditation_key = meditation_key
                                    }else{
                                        if let meditation_type = dict["meditation_type"] as? String{
                                            dbGuidedData.meditation_key = meditation_type
                                        }
                                    }
                                    
                                    if let complete_count = meditationList["complete_count"] as? Int{
                                        dbGuidedData.complete_count = "\(complete_count)"
                                    }else{
                                        dbGuidedData.complete_count = "0"
                                    }
                                    
                                    if let intro_url = meditationList["intro_url"] as? String{
                                        dbGuidedData.intro_url = intro_url
                                    }else{
                                        dbGuidedData.intro_url = ""
                                    }
                                    
                                    if let intro_completed = meditationList["intro_completed"] as? Bool{
                                        dbGuidedData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedData.intro_completed = false
                                    }
                                    
                                    if let emotion_list = meditationList["emotion_list"] as? [[String: Any]]{
                                        for emotionsDict in emotion_list {
                                            
                                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                            
                                            if let id = meditationList["id"]{
                                                dbGuidedEmotionsData.guided_id = "\(id)"
                                            }
                                            
                                            if let emotion_id = emotionsDict["emotion_id"]{
                                                dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                            }
                                            
                                            if let author_name = emotionsDict["author_name"]{
                                                dbGuidedEmotionsData.author_name = "\(author_name)"
                                            }
                                            
                                            if let emotion_image = emotionsDict["emotion_image"] as? String{
                                                dbGuidedEmotionsData.emotion_image = emotion_image
                                            }
                                            
                                            if let emotion_name = emotionsDict["emotion_name"] as? String{
                                                dbGuidedEmotionsData.emotion_name = emotion_name
                                            }
                                            
                                            if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                                dbGuidedEmotionsData.intro_completed = intro_completed
                                            }else{
                                                dbGuidedEmotionsData.intro_completed = false
                                            }
                                            
                                            if let tile_type = emotionsDict["tile_type"] as? String{
                                                dbGuidedEmotionsData.tile_type = tile_type
                                            }
                                            
                                            if let emotion_key = emotionsDict["emotion_key"] as? String{
                                                dbGuidedEmotionsData.emotion_key = emotion_key
                                            }
                                            
                                            if let emotion_body = emotionsDict["emotion_body"] as? String{
                                                dbGuidedEmotionsData.emotion_body = emotion_body
                                            }
                                            
                                            if let completed = emotionsDict["completed"] as? Bool{
                                                dbGuidedEmotionsData.completed = completed
                                            }
                                            
                                            if let completed_date = emotionsDict["completed_date"] as? String{
                                                dbGuidedEmotionsData.completed_date = completed_date
                                            }
                                            
                                            if let intro_url = emotionsDict["intro_url"] as? String{
                                                dbGuidedEmotionsData.intro_url = intro_url
                                            }else{
                                                dbGuidedEmotionsData.intro_url = ""
                                            }
                                            
                                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                                dbGuidedEmotionsData.emotion_type = emotion_type
                                            }else{
                                                dbGuidedEmotionsData.emotion_type = ""
                                            }
                                            
                                            if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                                for audioDict in audio_list {
                                                    
                                                    let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                                    
                                                    if let emotion_id = emotionsDict["emotion_id"]{
                                                        dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                                    }
                                                    
                                                    if let audio_id = audioDict["id"]{
                                                        dbGuidedAudioData.audio_id = "\(audio_id)"
                                                    }
                                                    
                                                    if let audio_image = audioDict["audio_image"] as? String{
                                                        dbGuidedAudioData.audio_image = audio_image
                                                    }
                                                    
                                                    if let audio_name = audioDict["audio_name"] as? String{
                                                        dbGuidedAudioData.audio_name = audio_name
                                                    }
                                                    
                                                    if let audio_url = audioDict["audio_url"] as? String{
                                                        dbGuidedAudioData.audio_url = audio_url
                                                    }
                                                    
                                                    if let author_name = audioDict["author_name"] as? String{
                                                        dbGuidedAudioData.author_name = author_name
                                                    }
                                                    
                                                    if let duration = audioDict["duration"]{
                                                        dbGuidedAudioData.duration = "\(duration)"
                                                    }
                                                    
                                                    if let paid = audioDict["paid"] as? Bool{
                                                        dbGuidedAudioData.paid = paid
                                                    }
                                                    
                                                    if let vote = audioDict["vote"] as? Bool{
                                                        dbGuidedAudioData.vote = vote
                                                    }
                                                    WWMHelperClass.saveDb()
                                                }
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                            
                                        }
                                    }
                                }
                            }
                            
                            WWMHelperClass.saveDb()
                            self.reloadTabs21DaysController()
                        }
                    }
                }
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }//end guided api*
}

extension WWM21DayChallengeVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // On inputing value to textfield
        if ((textField.text?.count)! < 1  && string.count > 0){
            if(textField == alertUpgradePopupView.textField1)
            {
                alertUpgradePopupView.textField2.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField2)
            {
                alertUpgradePopupView.textField3.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField3)
            {
                alertUpgradePopupView.textField4.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField4)
            {
                alertUpgradePopupView.textField5.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField5)
            {
                alertUpgradePopupView.textField6.becomeFirstResponder()
            }

            textField.text = string
            return false
        }
        else if ((textField.text?.count)! >= 1  && string.count == 0){
            // on deleting value from Textfield
            if(textField == alertUpgradePopupView.textField2)
            {
                alertUpgradePopupView.textField1.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField3)
            {
                alertUpgradePopupView.textField2.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField4)
            {
                alertUpgradePopupView.textField3.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField5)
            {
                alertUpgradePopupView.textField4.becomeFirstResponder()
            }
            if(textField == alertUpgradePopupView.textField6)
            {
                alertUpgradePopupView.textField5.becomeFirstResponder()
            }
            textField.text = ""
            return false
        }
        else if ((textField.text?.count)! >= 1  )
        {
            textField.text = string
            return false
        }
        return true
    }
}
