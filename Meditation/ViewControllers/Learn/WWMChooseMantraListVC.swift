//
//  WWMChooseMantraListVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

protocol WWMChooseMantraListDelegate {
    func chooseAudio(audio: String)
}

class WWMChooseMantraListVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    var mantraData: [WWMMantraData] = []
    var settingData = DBSettings()
    var delegate: WWMChooseMantraListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        //getMantrasAPI()
        self.fetchMantrasDataFromDB()
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        
    }
    
    func fetchMantrasDataFromDB() {
        let mantrasDataDB = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
        if mantrasDataDB.count > 0 {
            print("mantrasDataDB.count WWMChooseMantraListVC... \(mantrasDataDB.count)")
            for dict in mantrasDataDB {
                if let jsonResult = self.convertToDictionary1(text: dict.data ?? "") {
                    let mantraData = WWMMantraData.init(json: jsonResult)
                    self.mantraData.append(mantraData)
                }
            }
            
            self.tableView.reloadData()
        }else{
            self.getMantrasAPI()
        }
    }

    
    //MARK: API call
     func getMantrasAPI() {
           
           WWMHelperClass.showLoaderAnimate(on: self.view)
           
           WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_MANTRAS, context: "WWMChooseMantraListVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
               if sucess {
                   if let data = result["data"] as? [[String: Any]]{
                       let mantrasData = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
                       if mantrasData.count > 0 {
                           WWMHelperClass.deletefromDb(dbName: "DBMantras")
                       }
                       for dict in data{
                           
                           print("mantras result... \(result)")
                           print("choosemantralist getmantras api")
                           
                           
                           let dbMantrasData = WWMHelperClass.fetchEntity(dbName: "DBMantras") as! DBMantras
                           let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                           let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                           dbMantrasData.data = myString
                           
                           let timeInterval = Int(Date().timeIntervalSince1970)
                           print("timeInterval.... \(timeInterval)")
                           
                           dbMantrasData.last_time_stamp = "\(timeInterval)"
                           WWMHelperClass.saveDb()
                           
                           self.fetchMantrasDataFromDB()
                           
                       }
                   }
               }else {
                   if error != nil {
                       if error?.localizedDescription == "The Internet connection appears to be offline."{
                           WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                       }else{
                           WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                       }
                   }
               }
               WWMHelperClass.hideLoaderAnimate(on: self.view)
           }
       }
}

extension WWMChooseMantraListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mantraData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMChooseMantraListTVC") as! WWMChooseMantraListTVC
        
        cell.lblStepDescription.text = self.mantraData[indexPath.row].Description
        cell.lblTitle.text = self.mantraData[indexPath.row].title
        
        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.btnProceed.isHidden = false
            cell.imgArraow.image = UIImage(named: "upArrow")
        
        }else{
            cell.lblStepDescription.isHidden = true
            cell.btnProceed.isHidden = true
            cell.imgArraow.image = UIImage(named: "downArrow")
        }
        
        cell.btnPlayMantra.addTarget(self, action: #selector(btnPlayMantraClicked), for: .touchUpInside)
        cell.btnPlayMantra.tag = indexPath.row
        
        cell.btnProceed.addTarget(self, action: #selector(btnProceedClicked), for: .touchUpInside)
        cell.btnProceed.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    @objc func btnPlayMantraClicked(_ sender: UIButton){
        delegate?.chooseAudio(audio: self.mantraData[sender.tag].mantra_audio)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnProceedClicked(_ sender: UIButton){
        
        if WWMHelperClass.value == "mantra"{
            self.settingData.mantraID = self.mantraData[sender.tag].id
            
            let arrVc = self.navigationController?.viewControllers
            for vc in arrVc! {
                if vc.isKind(of: WWMSettingsVC.classForCoder()){
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            
            if self.appPreference.isLogin(){
                DispatchQueue.global(qos: .background).async {
                    let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
                           if data.count > 0 {
                               self.settingAPI()
                    }
                }
            }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnLetsMeditateVC") as! WWMLearnLetsMeditateVC
            
            WWMHelperClass.mantra_id = self.mantraData[sender.tag].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK:- API Calling
    
    func settingAPI() {
        
        var meditation_data = [[String:Any]]()
        let meditationData = self.settingData.meditationData!.array as? [DBMeditationData]
        for dic in meditationData!{
            let levels = dic.levels?.array as? [DBLevelData]
            var levelDic = [[String:Any]]()
            for level in levels! {
                let leveldata = [
                    "level_id": level.levelId,
                    "isSelected": level.isLevelSelected,
                    "name": level.levelName!,
                    "prep_time": "\(level.prepTime)",
                    "meditation_time": "\(level.meditationTime)",
                    "rest_time": "\(level.restTime)",
                    "prep_min": "\(level.minPrep)",
                    "prep_max": "\(level.maxPrep)",
                    "med_min": "\(level.minMeditation)",
                    "med_max": "\(level.maxMeditation)",
                    "rest_min": "\(level.minRest)",
                    "rest_max": "\(level.maxRest)"
                    ] as [String : Any]
                levelDic.append(leveldata)
            }
            
            let data = ["meditation_id":dic.meditationId,
                        "meditation_name":dic.meditationName ?? "",
                        "isSelected":dic.isMeditationSelected,
                        "setmyown" : dic.setmyown,
                        "levels":levelDic] as [String : Any]
            meditation_data.append(data)
        }
        //"IsMilestoneAndRewards"
        let group = [
            "startChime": self.settingData.startChime!,
            "endChime": self.settingData.endChime!,
            "finishChime": self.settingData.finishChime!,
            "intervalChime": self.settingData.intervalChime!,
            "ambientSound": self.settingData.ambientChime!,
            "moodMeterEnable": self.settingData.moodMeterEnable,
            "IsMorningReminder": self.settingData.isMorningReminder,
            "IsMilestoneAndRewards":self.settingData.isMilestoneAndRewards,
            "MorningReminderTime": self.settingData.morningReminderTime!,
            "IsAfternoonReminder": self.settingData.isAfterNoonReminder,
            "AfternoonReminderTime": self.settingData.afterNoonReminderTime!,
            "MantraID":self.settingData.mantraID,
            "LearnReminderTime":self.settingData.learnReminderTime!,
            "IsLearnReminder":self.settingData.isLearnReminder,
            "meditation_data" : meditation_data
            ] as [String : Any]
        
        let param = [
            "user_id": self.appPreference.getUserID(),
            "isJson": true,
            "group": group
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMChooseMantraListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    print("WWMChooseMantraListVC")
                    
                }
            }
        }
    }
}
