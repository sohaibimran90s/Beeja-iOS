//
//  WWMSettingsVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleSignIn
import FBSDKLoginKit

class WWMSettingsVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    let arrChimes = [kChimes_HARP,kChimes_CHIME,kChimes_CHIME2,kChimes_CONCH,kChimes_SITAR,kChimes_THRUSH,kChimes_SPARROW,kChimes_SUN_KOSHI,kChimes_MOON_KOSHI,kChimes_BURMESE_BELL,kChimes_CRYSTAL_BOWL,kChimes_HIMALAYAN_BELL,kChimes_JaiGuruDev]
    
    let arrAmbientSound = [kAmbient_BIRDSONG_1,kAmbient_BIRDSONG_2,kAmbient_WAVES_ONLY,kAmbient_CHIMES_ONLY,kAmbient_WAVES_CHIMES,kAmbient_JUNGLE_AT_DAWN]
    
    var arrPickerSound = [String]()
    
    let arrTimeChimes = ["Prep Time","Start Chime","Meditation Time","End Chime","Rest Time","Completion Chime","Interval Chime","Ambient Sound"]
    let arrPreset = ["Beginner","Rounding","Advanced","Adv. Rounding"]
    
    let arrLearn = ["Mantra","Enable Learn Reminder","Learn Reminder Time"]
    let arrLearn1 = ["Enable Learn Reminder","Learn Reminder Time"]
    
    let arrSettings = ["Enable Morning Reminder","Morning Reminder Time","Enable Afternoon Reminder","Afternoon Reminder Time","Mood Meter","Milestones & Rewards","Rate Review","Tell A Friend","Reset Password","Help","Privacy Policy","Terms & Conditions","Logout"]

    @IBOutlet weak var tblViewSetting: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    //var alertPopupView = WWMAlertController()
    
    var pickerStartChimes = UIPickerView()
    var player: AVAudioPlayer?
    
    var settingData = DBSettings()
    var arrMeditationData = [DBMeditationData]()
    var selectedMeditationData  = DBMeditationData()
    var isPlayerPlay = false
    var isSetMyOwn = false
    let appPreffrence = WWMAppPreference()
    
    var min_limit = ""
    var max_limit = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerStartChimes.delegate = self
        pickerStartChimes.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Settings")
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            print("... settingData... \(settingData)")
            if let meditationData = settingData.meditationData?.array as?  [DBMeditationData] {
                arrMeditationData = meditationData
            }
        }
        self.tblViewSetting.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        WWMHelperClass.saveDb()
        if self.appPreference.isLogin(){
            DispatchQueue.global(qos: .background).async {
                let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
                       if data.count > 0 {
                           self.settingAPI()
                }
            }
        }
    }
    
    func secondsToMinutesSeconds(second : Int) -> String {
        print("secinndnddd... \(second)")
        if second<60 {
            return "\(second) sec"
        }else {
            let x = String.init(format: "%d:%02d min", second/60,second%60)
            return x
        }
        
    }
    func playAudioFile(fileName:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            player?.play()
            isPlayerPlay = true
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK:- UITextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isPlayerPlay {
            self.player?.stop()
            self.isPlayerPlay = false
        }
        if isSetMyOwn {
            self.isSetMyOwn = false
            self.tblViewSetting.reloadData()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSetMyOwnVC") as! WWMSetMyOwnVC
            vc.isFromSetting = true
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            callPushNotification()
            //self.settingAPI()
            self.tblViewSetting.reloadData()
        }
    }
    
    // MARK:- UIPickerView Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerStartChimes.tag == 10  {
            
            for dic in self.arrMeditationData {
                if dic.setmyown == 1{
                  return arrMeditationData.count
                }
            }
            return arrMeditationData.count+1
        }else {
            return arrPickerSound.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerStartChimes.tag == 10 {
            if row == arrMeditationData.count {
                return "Set My Own"
            }
            return arrMeditationData[row].meditationName
        }
        return arrPickerSound[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.pickerStartChimes.tag == 10 {
            if row == arrMeditationData.count  {
                self.isSetMyOwn = true
            }else {
                self.isSetMyOwn = false
                for indexs in 0..<arrMeditationData.count {
                    if indexs == row {
                        
                        var i = 0
                        if arrMeditationData[indexs].meditationName == "Beeja"{
                            i = indexs
                        }
                        
                        if arrMeditationData[indexs].min_limit == "" || arrMeditationData[indexs].min_limit == nil{
                            self.appPreference.setTimerMin_limit(value: arrMeditationData[i].min_limit ?? "94")
                            self.appPreference.setTimerMax_limit(value: arrMeditationData[i].max_limit ?? "97")
                            self.appPreference.setMeditation_key(value: arrMeditationData[indexs].meditationName ?? "Beeja")
                        }else{
                            self.appPreference.setTimerMin_limit(value: arrMeditationData[indexs].min_limit ?? "94")
                            self.appPreference.setTimerMax_limit(value: arrMeditationData[indexs].max_limit ?? "97")
                            self.appPreference.setMeditation_key(value: arrMeditationData[indexs].meditationName ?? "Beeja")
                        }
                        
                        print("min_limit*** \(self.appPreffrence.getTimerMin_limit() ) max_limit*** \(self.appPreffrence.getTimerMax_limit()) name*** \(self.appPreffrence.getMeditation_key())")
                        
                        
                        self.selectedMeditationData = arrMeditationData[indexs]
                        arrMeditationData[indexs].isMeditationSelected = true
                        if arrMeditationData[indexs].meditationName == "Beeja" || arrMeditationData[indexs].meditationName == "Vedic/Transcendental" {
                            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "END_CHIME", itemName: kChimes_JaiGuruDev.uppercased().replacingOccurrences(of: " ", with: "_"))
                            settingData.endChime = kChimes_JaiGuruDev
                        }else {
                            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "END_CHIME", itemName: kChimes_HIMALAYAN_BELL.uppercased().replacingOccurrences(of: " ", with: "_"))
                            settingData.endChime = kChimes_HIMALAYAN_BELL
                        }
                        if let levels = arrMeditationData[indexs].levels?.array as? [DBLevelData] {
                            for index in 0..<levels.count {
                                if index == 0 {
                                    levels[index].isLevelSelected = true
                                    self.settingData.prepTime = "\(levels[index].prepTime)"
                                    self.settingData.meditationTime = "\(levels[index].meditationTime)"
                                    self.settingData.restTime = "\(levels[index].restTime)"
                                    
                                    // Analytics
                                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MEDITATION_TIME", itemName: "\(levels[index].meditationTime)")
                                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "PREP_TIME", itemName: "\(levels[index].prepTime)")
                                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "REST_TIME", itemName: "\(levels[index].restTime)")
                                    
                                    
                                    var analyticsName = arrMeditationData[indexs].meditationName?.uppercased() ?? ""
                                    analyticsName = analyticsName.replacingOccurrences(of: " ", with: "_")
                                    
                                    var levelName = levels[index].levelName?.uppercased() ?? ""
                                    levelName = levelName.replacingOccurrences(of: " ", with: "_")
                                    
                                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "PRESET_\(analyticsName)", itemName: levelName)
                                    
                                }else {
                                    levels[index].isLevelSelected = false
                                }
                            }
                        }
                        
                    }else {
                        arrMeditationData[indexs].isMeditationSelected = false
                    }
                }
            }
            
        }else {
            let fileName = arrPickerSound[row]
            self.playAudioFile(fileName: fileName)
            var analyticsName = fileName.uppercased()
            analyticsName = analyticsName.replacingOccurrences(of: " ", with: "_")
            if self.pickerStartChimes.tag == 8 {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "AMBIENT_SOUND", itemName: analyticsName)
                self.settingData.ambientChime = arrPickerSound[row]
            }else if self.pickerStartChimes.tag == 2 {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "START_CHIME", itemName: analyticsName)
                self.settingData.startChime = arrPickerSound[row]
            }else if self.pickerStartChimes.tag == 4 {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "END_CHIME", itemName: analyticsName)
                self.settingData.endChime = arrPickerSound[row]
            }else if self.pickerStartChimes.tag == 6 {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "COMPLETION_CHIME", itemName: analyticsName)
                self.settingData.finishChime = arrPickerSound[row]
            }else if self.pickerStartChimes.tag == 7 {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "INTERVAL_CHIME", itemName: analyticsName)
                self.settingData.intervalChime = arrPickerSound[row]
            }
        }
        
    }

    // MARK:- UITableView Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        print("....userdate.... \(self.userData.type)")
        
        
        if self.appPreffrence.getType() == "timer" {
            return 3
        }else if self.appPreffrence.getType() == "learn" {
            return 2
        }else {
            return 1
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.appPreffrence.getType() == "timer" {
            if section == 0 {
                for data in self.arrMeditationData {
                    if data.isMeditationSelected {
                        if data.meditationName == "Beeja" || data.meditationName == "Vedic/Transcendental" {
                            return arrTimeChimes.count-1
                        }
                        
                    }
                }
                return arrTimeChimes.count+1
            }else if section == 1 {
                for data in self.arrMeditationData {
                    if data.isMeditationSelected {
                        selectedMeditationData = data
                        return ((data.levels?.count)!+1)
                    }
                }
                return 0
            }else {
                return arrSettings.count+1
            }
        }else if self.appPreffrence.getType() == "learn" {
            
            if self.appPreffrence.getIsSubscribedBool(){
                if section == 0 {
                    return arrLearn.count+1
                }else {
                    return arrSettings.count+1
                }
            }else{
                if section == 0 {
                    return arrLearn1.count+1
                }else {
                    return arrSettings.count+1
                }
            }
            
        }else {
            return arrSettings.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = WWMSettingTableViewCell()
        if self.appPreffrence.getType() == "timer" {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                    cell.lblTitle.text = KTIMESCHIMES
                    cell.lblDropDown.isHidden = true
                    cell.imgViewDropDown.isHidden = true
                }else {
                    if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellTime") as! WWMSettingTableViewCell
                        cell.checkImage.isHidden = true
                        cell.lblTitle.text = self.arrTimeChimes[indexPath.row-1]
                        cell.lblTime.isHidden = false
                        if indexPath.row == 1 {
                            cell.lblTime.text = self.secondsToMinutesSeconds(second: Int(settingData.prepTime ?? "0") ?? 0)
                        }else if indexPath.row == 3 {                            
                            if let meditationTime = settingData.meditationTime{
                                print("meditationTime====== \(meditationTime)")
                                cell.lblTime.text = self.secondsToMinutesSeconds(second: Int(meditationTime)!)
                            }else{
                                cell.lblTime.text = self.secondsToMinutesSeconds(second: 0)
                            }
                           
                            
                        }else if indexPath.row == 5 {
                            cell.lblTime.text = self.secondsToMinutesSeconds(second: Int(settingData.restTime ?? "0") ?? 0)
                        }
                        
                    }else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellDropDown") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrTimeChimes[indexPath.row-1]
                        
                        cell.txtView.inputView = pickerStartChimes
                        cell.btnPicker.indexPath = indexPath
                        cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                        if indexPath.row == 2 {
                            cell.lblDropDown.text = settingData.startChime
                        }else if indexPath.row == 4 {
                            cell.lblDropDown.text = settingData.endChime
                        }else if indexPath.row == 6 {
                            cell.lblDropDown.text = settingData.finishChime
                        }else if indexPath.row == 7 {
                            cell.lblDropDown.text = settingData.intervalChime
                        }else if indexPath.row == 8 {
                            cell.lblDropDown.text = settingData.ambientChime
                        }
                    }
                    
                }
            }else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                    cell.lblTitle.text = KPRESET
                    cell.lblDropDown.text = selectedMeditationData.meditationName
                    cell.txtView.inputView = pickerStartChimes
                    cell.txtView.isUserInteractionEnabled = true
                    cell.btnPicker.isUserInteractionEnabled = true
                    cell.btnPicker.indexPath = indexPath
                    cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                }else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellTime") as! WWMSettingTableViewCell
                    cell.lblTime.isHidden = false
                    let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]
                    var level = DBLevelData()
                    if (levels?.count)! > 0 {
                        level = levels![indexPath.row-1]
                        cell.lblTitle.text = level.levelName
                        cell.lblTime.text = "\(self.secondsToMinutesSeconds(second: Int(level.prepTime))) | \(self.secondsToMinutesSeconds(second: Int(level.meditationTime))) | \(self.secondsToMinutesSeconds(second: Int(level.restTime)))"
                        cell.checkImage.isHidden = true
                        if level.isLevelSelected {
                            cell.checkImage.isHidden = false
                        }
                        
                    }
                    
                }
            }else if indexPath.section == 2{
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                    cell.lblTitle.text = KREMINDERS
                    cell.lblDropDown.isHidden = true
                    cell.imgViewDropDown.isHidden = true
                }else if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                    cell.btnSwitch.tag = indexPath.row
                    if indexPath.row == 1 {
                        cell.btnSwitch.isOn = settingData.isMorningReminder
                    }else if indexPath.row == 3 {
                        cell.btnSwitch.isOn = settingData.isAfterNoonReminder
                    }else if indexPath.row == 5 {
                        cell.btnSwitch.isOn = settingData.moodMeterEnable
                    }else if indexPath.row == 6 {
                        cell.btnSwitch.isOn = settingData.isMilestoneAndRewards
                    }
                    
                }else if indexPath.row == 2 || indexPath.row == 4  {
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellLabel") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    cell.lblTime.isHidden = false
                    cell.checkImage.isHidden = true
                    if indexPath.row == 2 {
                        cell.lblTime.text = settingData.morningReminderTime
                        
                        if !settingData.isMorningReminder {
                            cell.lblTime.isHidden = true
                            cell.btnPicker.isUserInteractionEnabled = false
                            cell.txtView.isUserInteractionEnabled = false
                            
                        }else {
                            cell.btnPicker.isUserInteractionEnabled = true
                            cell.txtView.isUserInteractionEnabled = true
                            cell.btnPicker.indexPath = indexPath
                            cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                        }
                    }else if indexPath.row == 4 {
                        cell.lblTime.text = settingData.afterNoonReminderTime
                        if !settingData.isAfterNoonReminder {
                            cell.lblTime.isHidden = true
                            cell.btnPicker.isUserInteractionEnabled = false
                            cell.txtView.isUserInteractionEnabled = false
                        }else {
                            cell.btnPicker.isUserInteractionEnabled = true
                            cell.txtView.isUserInteractionEnabled = true
                            cell.btnPicker.indexPath = indexPath
                            cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                        }
                    }
                }else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                }
            }
        }else if self.appPreffrence.getType() == "learn" {
            
            if self.appPreffrence.getIsSubscribedBool(){
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                        cell.lblTitle.text = KLEARNTOMEDITATE
                        cell.lblDropDown.isHidden = true
                        cell.imgViewDropDown.isHidden = true
                    }else if indexPath.row == 1 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrLearn[indexPath.row-1]
                    }else if indexPath.row == 2 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrLearn[indexPath.row-1]
                        cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                        cell.btnSwitch.tag = 101
                        cell.btnSwitch.isOn = settingData.isLearnReminder
                    }else if indexPath.row == 3 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellTime") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrLearn[indexPath.row-1]
                        cell.lblTime.isHidden = false
                        cell.checkImage.isHidden = true
                        cell.lblTime.text = settingData.learnReminderTime
                            
                            if !settingData.isLearnReminder {
                                cell.lblTime.isHidden = true
                            }
                    }
                }else if indexPath.section == 1 {
                    
                    if indexPath.row == 0 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                        cell.lblTitle.text = KREMINDERS
                        cell.lblDropDown.isHidden = true
                        cell.imgViewDropDown.isHidden = true
                    }else if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6{
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                        cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                        cell.btnSwitch.tag = indexPath.row
                        if indexPath.row == 1 {
                            cell.btnSwitch.isOn = settingData.isMorningReminder
                        }else if indexPath.row == 3 {
                            cell.btnSwitch.isOn = settingData.isAfterNoonReminder
                        }else if indexPath.row == 5 {
                            cell.btnSwitch.isOn = settingData.moodMeterEnable
                        }else if indexPath.row == 6 {
                            cell.btnSwitch.isOn = settingData.isMilestoneAndRewards
                        }
                        
                    }else if indexPath.row == 2 || indexPath.row == 4  {
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellLabel") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                        cell.lblTime.isHidden = false
                        cell.checkImage.isHidden = true
                        if indexPath.row == 2 {
                            cell.lblTime.text = settingData.morningReminderTime
                            
                            if !settingData.isMorningReminder {
                                cell.lblTime.isHidden = true
                                cell.btnPicker.isUserInteractionEnabled = false
                                cell.txtView.isUserInteractionEnabled = false
                                
                            }else {
                                cell.btnPicker.isUserInteractionEnabled = true
                                cell.txtView.isUserInteractionEnabled = true
                                cell.btnPicker.indexPath = indexPath
                                cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                            }
                        }else if indexPath.row == 4 {
                            cell.lblTime.text = settingData.afterNoonReminderTime
                            if !settingData.isAfterNoonReminder {
                                cell.lblTime.isHidden = true
                                cell.btnPicker.isUserInteractionEnabled = false
                                cell.txtView.isUserInteractionEnabled = false
                            }else {
                                cell.btnPicker.isUserInteractionEnabled = true
                                cell.txtView.isUserInteractionEnabled = true
                                cell.btnPicker.indexPath = indexPath
                                cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                            }
                        }
                    }else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    }
                }
            }else{
                
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                        cell.lblTitle.text = KLEARNTOMEDITATE
                        cell.lblDropDown.isHidden = true
                        cell.imgViewDropDown.isHidden = true
                    }else if indexPath.row == 1 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrLearn1[indexPath.row-1]
                        cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                        cell.btnSwitch.tag = 101
                        cell.btnSwitch.isOn = settingData.isLearnReminder
                    }else if indexPath.row == 2 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellTime") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrLearn1[indexPath.row-1]
                        cell.lblTime.isHidden = false
                        cell.checkImage.isHidden = true
                        cell.lblTime.text = settingData.learnReminderTime
                        
                        if !settingData.isLearnReminder {
                            cell.lblTime.isHidden = true
                        }
                    }
                }else if indexPath.section == 1 {
                    
                    if indexPath.row == 0 {
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                        cell.lblTitle.text = KREMINDERS
                        cell.lblDropDown.isHidden = true
                        cell.imgViewDropDown.isHidden = true
                    }else if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6{
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                        cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                        cell.btnSwitch.tag = indexPath.row
                        if indexPath.row == 1 {
                            cell.btnSwitch.isOn = settingData.isMorningReminder
                        }else if indexPath.row == 3 {
                            cell.btnSwitch.isOn = settingData.isAfterNoonReminder
                        }else if indexPath.row == 5 {
                            cell.btnSwitch.isOn = settingData.moodMeterEnable
                        }else if indexPath.row == 6 {
                            cell.btnSwitch.isOn = settingData.isMilestoneAndRewards
                        }
                        
                    }else if indexPath.row == 2 || indexPath.row == 4  {
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "CellLabel") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                        cell.lblTime.isHidden = false
                        cell.checkImage.isHidden = true
                        if indexPath.row == 2 {
                            cell.lblTime.text = settingData.morningReminderTime
                            
                            if !settingData.isMorningReminder {
                                cell.lblTime.isHidden = true
                                cell.btnPicker.isUserInteractionEnabled = false
                                cell.txtView.isUserInteractionEnabled = false
                                
                            }else {
                                cell.btnPicker.isUserInteractionEnabled = true
                                cell.txtView.isUserInteractionEnabled = true
                                cell.btnPicker.indexPath = indexPath
                                cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                            }
                        }else if indexPath.row == 4 {
                            cell.lblTime.text = settingData.afterNoonReminderTime
                            if !settingData.isAfterNoonReminder {
                                cell.lblTime.isHidden = true
                                cell.btnPicker.isUserInteractionEnabled = false
                                cell.txtView.isUserInteractionEnabled = false
                            }else {
                                cell.btnPicker.isUserInteractionEnabled = true
                                cell.txtView.isUserInteractionEnabled = true
                                cell.btnPicker.indexPath = indexPath
                                cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                            }
                        }
                    }else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WWMSettingTableViewCell
                        cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    }
                }
            }
        }else {
            if indexPath.section == 0{
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! WWMSettingTableViewCell
                    cell.lblTitle.text = KREMINDERS
                    cell.lblDropDown.isHidden = true
                    cell.imgViewDropDown.isHidden = true
                }else if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellToggle") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    cell.btnSwitch.addTarget(self, action: #selector(btnSwitchAction(_:)), for: .valueChanged)
                    cell.btnSwitch.tag = indexPath.row
                    if indexPath.row == 1 {
                        cell.btnSwitch.isOn = settingData.isMorningReminder
                    }else if indexPath.row == 3 {
                        cell.btnSwitch.isOn = settingData.isAfterNoonReminder
                    }else if indexPath.row == 5 {
                        cell.btnSwitch.isOn = settingData.moodMeterEnable
                    }else if indexPath.row == 6 {
                        cell.btnSwitch.isOn = settingData.isMilestoneAndRewards
                    }
                    
                }else if indexPath.row == 2 || indexPath.row == 4  {
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "CellLabel") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                    cell.lblTime.isHidden = false
                    cell.checkImage.isHidden = true
                    if indexPath.row == 2 {
                        cell.lblTime.text = settingData.morningReminderTime
                        
                        if !settingData.isMorningReminder {
                            cell.lblTime.isHidden = true
                            cell.btnPicker.isUserInteractionEnabled = false
                            cell.txtView.isUserInteractionEnabled = false
                            
                        }else {
                            cell.btnPicker.isUserInteractionEnabled = true
                            cell.txtView.isUserInteractionEnabled = true
                            cell.btnPicker.indexPath = indexPath
                            cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                        }
                    }else if indexPath.row == 4 {
                        cell.lblTime.text = settingData.afterNoonReminderTime
                        if !settingData.isAfterNoonReminder {
                            cell.lblTime.isHidden = true
                            cell.btnPicker.isUserInteractionEnabled = false
                            cell.txtView.isUserInteractionEnabled = false
                        }else {
                            cell.btnPicker.isUserInteractionEnabled = true
                            cell.txtView.isUserInteractionEnabled = true
                            cell.btnPicker.indexPath = indexPath
                            cell.btnPicker.addTarget(self, action: #selector(btnPickerAction(_:)), for: .touchUpInside)
                        }
                    }
                }else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WWMSettingTableViewCell
                    cell.lblTitle.text = self.arrSettings[indexPath.row-1]
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.appPreffrence.getType() == "timer" {
            if indexPath.section == 0 {
                if indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5{
                    self.moveToEditMeditationTimeScreen()
                }
            }else if indexPath.section == 1 {
                if indexPath.row != 0 {
                    let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]
                    let level = levels![indexPath.row-1]
                    settingData.prepTime = "\(level.prepTime)"
                    settingData.meditationTime = "\(level.meditationTime)"
                    settingData.restTime = "\(level.restTime)"
                    for data in self.arrMeditationData {
                        if data.isMeditationSelected {
                            for index in 0..<(data.levels?.count)! {
                                let level1 = data.levels?.array as? [DBLevelData]
                                if index == indexPath.row-1 {
                                    level1![index].isLevelSelected =  true
                                }else {
                                    level1![index].isLevelSelected =  false
                                }
                            }
                        }
                    }
//                  self.settingAPI()
                    self.tblViewSetting.reloadData()
                }
                
            }else if indexPath.section == 2 {
                if indexPath.row == 7 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RATE_REVIEW", itemName: "")
                    
                    let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/app/1453359245"
                    //let iOSAppStoreURLFormat = "http://itunes.com/apps/com.beejameditation.beeja"
                    
                    let url = URL.init(string: iOSAppStoreURLFormat)
                    
                    if UIApplication.shared.canOpenURL(url!){
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                }else if indexPath.row == 8 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "TELL_FRIEND", itemName: "")
                    let url = URL.init(string: "http://itunes.com/apps/com.beejameditation.beeja")
                    let textToShare = "\(KBEMORECONNECTED) \(url!.absoluteString)"
                    let imageToShare = [textToShare] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }else if indexPath.row == 9 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RESET_PASSWORD", itemName: "")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMResetPasswordVC") as! WWMResetPasswordVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 10{
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "HELP", itemName: "")
                    print("help...")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                    
                    vc.value = "help"
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 11 || indexPath.row == 12 {
                    self.openWebView(index: indexPath.row)
                    
                }else if indexPath.row == 13{
                    self.logout()
                }
            }
        }else if self.appPreffrence.getType() == "learn"{
            
            if self.appPreffrence.getIsSubscribedBool(){
                if indexPath.section == 0{
                    if indexPath.row == 1{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMChooseMantraVC") as! WWMChooseMantraVC
                        vc.value = "mantra"
                        self.navigationController?.pushViewController(vc, animated: false)
                    }else if indexPath.row == 3{
                        if settingData.isLearnReminder {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnReminderVC") as! WWMLearnReminderVC
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                }else if indexPath.section == 1{
                    if indexPath.row == 7 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RATE_REVIEW", itemName: "")
                        
                        let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/app/1453359245"
                        //let iOSAppStoreURLFormat = "http://itunes.com/apps/com.beejameditation.beeja"
                        
                        let url = URL.init(string: iOSAppStoreURLFormat)
                        
                        if UIApplication.shared.canOpenURL(url!){
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }else if indexPath.row == 8 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "TELL_FRIEND", itemName: "")
                        let url = URL.init(string: "http://itunes.com/apps/com.beejameditation.beeja")
                        let textToShare = "\(KBEMORECONNECTED) \(url!.absoluteString)"
                        let imageToShare = [textToShare] as [Any]
                        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    }else if indexPath.row == 9 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RESET_PASSWORD", itemName: "")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMResetPasswordVC") as! WWMResetPasswordVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if indexPath.row == 10{
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "HELP", itemName: "")
                        print("help...")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                        
                        vc.value = "help"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if indexPath.row == 11 || indexPath.row == 12 {
                        self.openWebView(index: indexPath.row)
                        
                    }else if indexPath.row == 13{
                        self.logout()
                    }
                }
            }else{
                if indexPath.section == 0{
                    if indexPath.row == 2{
                        if settingData.isLearnReminder {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnReminderVC") as! WWMLearnReminderVC
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                    }
                }else if indexPath.section == 1{
                    if indexPath.row == 7 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RATE_REVIEW", itemName: "")
                        
                        let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/app/1453359245"
                        //let iOSAppStoreURLFormat = "http://itunes.com/apps/com.beejameditation.beeja"
                        
                        let url = URL.init(string: iOSAppStoreURLFormat)
                        
                        if UIApplication.shared.canOpenURL(url!){
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }else if indexPath.row == 8 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "TELL_FRIEND", itemName: "")
                        let url = URL.init(string: "http://itunes.com/apps/com.beejameditation.beeja")
                        let textToShare = "\(KBEMORECONNECTED) \(url!.absoluteString)"
                        let imageToShare = [textToShare] as [Any]
                        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    }else if indexPath.row == 9 {
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RESET_PASSWORD", itemName: "")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMResetPasswordVC") as! WWMResetPasswordVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if indexPath.row == 10{
                        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "HELP", itemName: "")
                        print("help...")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                        
                        vc.value = "help"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if indexPath.row == 11 || indexPath.row == 12 {
                        self.openWebView(index: indexPath.row)
                        
                    }else if indexPath.row == 13{
                        self.logout()
                    }
                }
            }
        }else {
            if indexPath.section == 0 {
                if indexPath.row == 7 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RATE_REVIEW", itemName: "")
                    
                    let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/app/1453359245"
                    //let iOSAppStoreURLFormat = "http://itunes.com/apps/com.beejameditation.beeja"
                    
                    let url = URL.init(string: iOSAppStoreURLFormat)
                    
                    if UIApplication.shared.canOpenURL(url!){
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                }else if indexPath.row == 8 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "TELL_FRIEND", itemName: "")
                    let url = URL.init(string: "http://itunes.com/apps/com.beejameditation.beeja")
                    let textToShare = "\(KBEMORECONNECTED) \(url!.absoluteString)"
                    let imageToShare = [textToShare] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }else if indexPath.row == 9 {
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "RESET_PASSWORD", itemName: "")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMResetPasswordVC") as! WWMResetPasswordVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 10{
                    WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "HELP", itemName: "")
                    print("help...")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                    
                    vc.value = "help"
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 11 || indexPath.row == 12 {
                    self.openWebView(index: indexPath.row)
                    
                }else if indexPath.row == 13{
                    self.logout()
                }
            }
        }
    }
    
    // MARK: Button Action
    
    @IBAction func btnPickerAction(_ sender: WWMCustomButton) {
        if let cell = tblViewSetting.cellForRow(at: sender.indexPath) as? WWMSettingTableViewCell {
            if self.appPreffrence.getType() == "timer" {
                if sender.indexPath.section == 0{
                    if sender.indexPath.row == 8{
                        self.arrPickerSound = self.arrAmbientSound
                    }else {
                        self.arrPickerSound = self.arrChimes
                    }
                    self.pickerStartChimes.tag = sender.indexPath.row
                    self.pickerStartChimes.reloadAllComponents()
                }else if sender.indexPath.section == 1{
                    self.pickerStartChimes.tag = 10
                    self.pickerStartChimes.reloadAllComponents()
                }else if sender.indexPath.section == 2 {
                    let datePickerView = UIDatePicker()
                    datePickerView.datePickerMode = .time
                    cell.txtView.inputView = datePickerView
                    datePickerView.tag = sender.indexPath.row
                    datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
                }
            }else if self.appPreffrence.getType() == "learn" {
                
                if self.appPreffrence.getIsSubscribedBool() {
                    if sender.indexPath.section == 1{
                        let datePickerView = UIDatePicker()
                        datePickerView.datePickerMode = .time
                        cell.txtView.inputView = datePickerView
                        datePickerView.tag = sender.indexPath.row
                        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
                    }
                }else{
                    //if sender.indexPath.section == 0{
                        let datePickerView = UIDatePicker()
                        datePickerView.datePickerMode = .time
                        cell.txtView.inputView = datePickerView
                        datePickerView.tag = sender.indexPath.row
                        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
                    //}
                }
                
            }else {
                if sender.indexPath.section == 0{
                    let datePickerView = UIDatePicker()
                    datePickerView.datePickerMode = .time
                    cell.txtView.inputView = datePickerView
                    datePickerView.tag = sender.indexPath.row
                    datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
                }
            }
            if sender.indexPath.section == 0{
                if sender.indexPath.row == 8{
                    self.arrPickerSound = self.arrAmbientSound
                }else {
                    self.arrPickerSound = self.arrChimes
                }
                self.pickerStartChimes.tag = sender.indexPath.row
                self.pickerStartChimes.reloadAllComponents()
            }else if sender.indexPath.section == 1{
                self.pickerStartChimes.tag = 10
                self.pickerStartChimes.reloadAllComponents()
            }else if sender.indexPath.section == 2 {
                let datePickerView = UIDatePicker()
                datePickerView.datePickerMode = .time
                cell.txtView.inputView = datePickerView
                datePickerView.tag = sender.indexPath.row
                datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            }
            cell.txtView.becomeFirstResponder()
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if sender.tag == 2 {
           settingData.morningReminderTime = dateFormatter.string(from: sender.date)
            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MORNING_REMINDER_TIME", itemName: "\(dateFormatter.string(from: sender.date))")
        }else if sender.tag == 4 {
            settingData.afterNoonReminderTime = dateFormatter.string(from: sender.date)
            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "AFTERNOON_REMINDER_TIME", itemName: "\(dateFormatter.string(from: sender.date))")
        }
    }
    
    func logout() {
        self.xibCall()
    }
    
    
    func xibCall(){
        alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertPopupView.btnOK.layer.borderWidth = 2.0
        alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertPopupView.lblTitle.text = kAlertTitle
        alertPopupView.lblSubtitle.text = KSAYGOODBYE
        alertPopupView.btnOK.setTitle(KSAYGOODBYEYES, for: .normal)
        alertPopupView.btnClose.setTitle(KSAYGOODBYENO, for: .normal)
        alertPopupView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
        
        alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.alertPopupView.removeFromSuperview()
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        DispatchQueue.main.async {
         self.logoutAPI()
        }
        self.alertPopupView.removeFromSuperview()
    }
    
    func moveToEditMeditationTimeScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMEditMeditationTimeVC") as! WWMEditMeditationTimeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openWebView(index:Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        switch index {
        case 11:
            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "PRIVACY_POLICY", itemName: "")
            vc.strUrl = URL_PrivacyPolicy
            vc.strType = KPRIVACYPOLICY
        case 12:
            WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "TERMS_CONDITIONS", itemName: "")
            vc.strUrl = URL_TermsnCondition
            vc.strType = KTERMSCONDITION
        case 10:
            vc.strUrl = URL_Help
            vc.strType = KHELP
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    
    func callPushNotification() {
        AppDelegate.sharedDelegate().setLocalPush()
    }
    
    // MARK: - UIButton Action
    
    
    
    
    @IBAction func btnSwitchAction(_ sender: Any) {
        let btn = sender as! UISwitch
        if btn.tag == 1 {
            if btn.isOn {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "ENABLE_MORNING_REMINDER", itemName: "ON")
            }else {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "ENABLE_MORNING_REMINDER", itemName: "OFF")
            }
            settingData.isMorningReminder = btn.isOn
            callPushNotification()
        }else if btn.tag == 3 {
            if btn.isOn {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "ENABLE_AFTERNOON_REMINDER", itemName: "ON")
            }else {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "ENABLE_AFTERNOON_REMINDER", itemName: "OFF")
            }
            settingData.isAfterNoonReminder = btn.isOn
            callPushNotification()
        }else if btn.tag == 5 {
            if btn.isOn {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MOOD_METER", itemName: "ON")
            }else {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MOOD_METER", itemName: "OFF")
            }
            settingData.moodMeterEnable = btn.isOn
        }else if btn.tag == 6 {
            if btn.isOn {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MILESTONES_REWARDS", itemName: "ON")
            }else {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "MILESTONES_REWARDS", itemName: "OFF")
            }
            
            settingData.isMilestoneAndRewards = btn.isOn
        }else if btn.tag == 101 {
            if btn.isOn {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "LEARN_REMINDER", itemName: "ON")
            }else {
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "LEARN_REMINDER", itemName: "OFF")
            }
            settingData.isLearnReminder = btn.isOn
            if settingData.learnReminderTime == "" || settingData.learnReminderTime == nil {
                settingData.learnReminderTime = "08:00"
                WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "LEARN_REMINDER_TIME", itemName: "08:00")
            }
            // Enable Learn Reminder
        }
//      self.settingAPI()
        self.tblViewSetting.reloadData()
    }
    
    
    // MARK:- API Calling
    
    func settingAPI() {
        
        var meditation_data = [[String:Any]]()
        let meditationData = self.settingData.meditationData?.array as? [DBMeditationData]
        
        if meditationData?.count ?? 0 > 0{
            for dic in meditationData!{
                
                if dic.meditationName == "Beeja"{
                    self.min_limit = dic.min_limit ?? "94"
                    self.max_limit = dic.max_limit ?? "97"
                }
                
                let levels = dic.levels?.array as? [DBLevelData]
                var levelDic = [[String:Any]]()
                for level in levels! {
                    let leveldata = [
                        "level_id": level.levelId,
                        "isSelected": level.isLevelSelected,
                        "name": level.levelName ?? "",
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
                
                if dic.min_limit == "" || dic.min_limit == nil{
                    print("++++++ \(self.min_limit) \(self.max_limit)")
                    
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "min_limit" : self.min_limit,
                                "max_limit" : self.max_limit,
                                "setmyown" : dic.setmyown,
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }else{
                    //print("++++++ \(String(describing: dic.min_limit)) +++++ \(dic.max_limit)")
                    
                    let data = ["meditation_id":dic.meditationId,
                                "meditation_name":dic.meditationName ?? "",
                                "isSelected":dic.isMeditationSelected,
                                "min_limit" : dic.min_limit ?? "94",
                                "max_limit" : dic.max_limit ?? "97",
                                "setmyown" : dic.setmyown,
                                "levels":levelDic] as [String : Any]
                    meditation_data.append(data)
                }
            }
            
            //"IsMilestoneAndRewards"
            
            if self.settingData.startChime == "JAY GURU DEVA"{
                self.settingData.startChime = "JAI GURU DEVA"
            }
            
            if self.settingData.endChime == "JAY GURU DEVA"{
                self.settingData.endChime = "JAI GURU DEVA"
            }
            
            if self.settingData.finishChime == "JAY GURU DEVA"{
                self.settingData.finishChime = "JAI GURU DEVA"
            }
            
            if self.settingData.ambientChime == "JAY GURU DEVA"{
                self.settingData.ambientChime = "JAI GURU DEVA"
            }
            
            if self.settingData.intervalChime == "JAY GURU DEVA"{
                self.settingData.intervalChime = "JAI GURU DEVA"
            }
            
            let group = [
                "startChime": self.settingData.startChime ?? kChimes_BURMESE_BELL,
                "endChime": self.settingData.endChime ?? kChimes_BURMESE_BELL,
                "finishChime": self.settingData.finishChime ?? kChimes_BURMESE_BELL,
                "intervalChime": self.settingData.intervalChime ?? kChimes_BURMESE_BELL,
                "ambientSound": self.settingData.ambientChime ?? kAmbient_WAVES_CHIMES,
                "moodMeterEnable": self.settingData.moodMeterEnable,
                "IsMorningReminder": self.settingData.isMorningReminder,
                "IsMilestoneAndRewards":self.settingData.isMilestoneAndRewards,
                "MorningReminderTime": self.settingData.morningReminderTime ?? "8:00",
                "IsAfternoonReminder": self.settingData.isAfterNoonReminder,
                "AfternoonReminderTime": self.settingData.afterNoonReminderTime ?? "13:30",
                "MantraID":self.settingData.mantraID,
                "LearnReminderTime":self.settingData.learnReminderTime ?? "14:00",
                "IsLearnReminder":self.settingData.isLearnReminder,
                "meditation_data" : meditation_data
                ] as [String : Any]
            
            let param = [
                "user_id": self.appPreference.getUserID(),
                "isJson": true,
                "group": group
                ] as [String : Any]
            
            print("settings param... \(param)")
            
            WWMWebServices.requestAPIWithBody(param:param, urlString: URL_SETTINGS, context: "WWMSettingsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
                if sucess {
                    if let success = result["success"] as? Bool {
                        print(success)
                        print("settingVC... \(result)")
                        //self.tblViewSetting.reloadData()
                    }
                }else {
                    if error != nil {
                        //                     WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                    }
                }
            }
        }
    }
    
    func logoutAPI() {

        WWMHelperClass.sendEventAnalytics(contentType: "SETTINGS", itemId: "LOGOUT", itemName: "")
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "token" : appPreference.getToken(),
            "user_id": self.appPreference.getUserID()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_LOGOUT, context: "WWMSettingsVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsLogin(value: false)
                self.appPreference.setUserToken(value: "")
                self.appPreference.setUserID(value: "")
                self.appPreference.setUserName(value: "")
                self.appPreference.setIsProfileCompleted(value: false)
                self.appPreffrence.setPrePostJournalBool(value: false)
                self.appPreffrence.setExpiryDate(value: false)
                self.appPreference.setGetProfile(value: true)
                self.appPreffrence.setCheckEnterSignupLogin(value: false)
                self.appPreffrence.setEmail(value: "")
                KUSERDEFAULTS.set("0", forKey: "restore")

                // Delete the Database :
                WWMHelperClass.deletefromDb(dbName: "DBJournalData")
                WWMHelperClass.deletefromDb(dbName: "DBContactUs")
                WWMHelperClass.deletefromDb(dbName: "DBJournalList")
                WWMHelperClass.deletefromDb(dbName: "DBMeditationComplete")
                WWMHelperClass.deletefromDb(dbName: "DBSettings")
                WWMHelperClass.deletefromDb(dbName: "DBAddSession")
                WWMHelperClass.deletefromDb(dbName: "DBMeditationHistory")
                WWMHelperClass.deletefromDb(dbName: "DBWisdomData")
                WWMHelperClass.deletefromDb(dbName: "DBWisdomVideoData")
                WWMHelperClass.deletefromDb(dbName: "DBCommunityData")
                WWMHelperClass.deletefromDb(dbName: "DBStepFaq")
                WWMHelperClass.deletefromDb(dbName: "DBGetVibesImages")
                WWMHelperClass.deletefromDb(dbName: "DBSteps")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                WWMHelperClass.deletefromDb(dbName: "DBNintyFiveCompletionData")
                WWMHelperClass.deletefromDb(dbName: "DBNinetyFivePercent")
                WWMHelperClass.challenge7DayCount = 0
                WWMHelperClass.selectedType = ""
                self.appPreffrence.setLastTimeStamp21DaysBool(value: false)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                
                let loginManager = LoginManager()
                AccessToken.current = nil
                loginManager.logOut()
                GIDSignIn.sharedInstance()?.signOut()
                GIDSignIn.sharedInstance()?.disconnect()
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                let vcc = UINavigationController.init(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController = vcc
                
                
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
