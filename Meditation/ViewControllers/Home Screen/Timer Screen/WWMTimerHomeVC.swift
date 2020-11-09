//
//  WWMTimerHomeVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. Allx rights reserved.
//

import UIKit
import CoreData

class WWMTimerHomeVC: WWMBaseViewController {
    
    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var layoutSliderPrepTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var sliderPrepTime: WWMSlider!
    @IBOutlet weak var layoutSliderMeditationTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblMeditationTime: UILabel!
    @IBOutlet weak var sliderMeditationTime: WWMSlider!
    @IBOutlet weak var layoutSliderRestTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var sliderRestTime: WWMSlider!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var btnChoosePreset: UIButton!
    @IBOutlet weak var viewPrePost: UIView!
    
    var selectedMeditationData  = DBMeditationData()
    var selectedLevelData = DBLevelData()
    var daysListData = ThirtyDaysListData()
    var settingData = DBSettings()
    let gradientLayer = CAGradientLayer()
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var min = 0
    var isChallengePreset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getSettingData),
            name: NSNotification.Name(rawValue: "GETSettingData"),
            object: nil)
        
        self.offlineDatatoServerCall()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Timer")
        self.getSettingData()
        
        if self.appPreference.get21ChallengeName() == "30 Day Challenge" || self.appPreference.get21ChallengeName() == "8 Weeks Challenge"{
            self.appPreference.setType(value: "timer")
            self.tabBarController?.tabBar.isHidden = true
            self.viewPrePost.isHidden = true
        }else{
            self.tabBarController?.tabBar.isHidden = false
            self.viewPrePost.isHidden = false
        }
    }
    
    //insert offline data to server
    func offlineDatatoServerCall(){

        let nintyFivePercentDB = WWMHelperClass.fetchDB(dbName: "DBNintyFiveCompletionData") as! [DBNintyFiveCompletionData]
        if nintyFivePercentDB.count > 0{
            
            for data in nintyFivePercentDB{
                
                //print("nintyFivePercentDB.count++++====== \(nintyFivePercentDB.count)")
                
                if let jsonResult = self.convertToDictionary1(text: data.data ?? "") {
                    
                    //print("data....++++++===== \(data.data) id++++++++==== \(data.id)")
                    
                    self.completeMeditationAPI(mood_id: jsonResult["mood_id"] as? String ?? "", user_id: jsonResult["user_id"] as? String ?? "", rest_time: "\(jsonResult["rest_time"] as? Int ?? 0)", emotion_id: jsonResult["emotion_id"] as? String ?? "", tell_us_why: jsonResult["tell_us_why"] as? String ?? "", prep_time: "\(jsonResult["prep_time"] as? Int ?? 0)", meditation_time: "\(jsonResult["meditation_time"] as? Int ?? 0)", watched_duration: jsonResult["watched_duration"] as? String ?? "", level_id: jsonResult["level_id"] as? String ?? "", complete_percentage: "\(jsonResult["complete_percentage"] as? Int ?? 0)", rating: jsonResult["rating"] as? String ?? "", meditation_type: jsonResult["meditation_type"] as? String ?? "", category_id: jsonResult["category_id"] as? String ?? "", meditation_id: jsonResult["meditation_id"] as? String ?? "", date_time: jsonResult["date_time"] as? String ?? "", type: jsonResult["type"] as? String ?? "", guided_type: jsonResult["guided_type"] as? String ?? "", audio_id: jsonResult["audio_id"] as? String ?? "", step_id: "\(jsonResult["step_id"] as? Int ?? 1)", mantra_id: "\(jsonResult["mantra_id"] as? Int ?? 1)", id: "\(data.id ?? "")", is_complete: jsonResult["is_complete"] as? String ?? "0", challenge_day_id: jsonResult["challenge_day_id"] as? String ?? "", challenge_type: jsonResult["challenge_type"] as? String ?? "")
                    
                }
            }
        }
    }
    
    func completeMeditationAPI(mood_id: String, user_id: String, rest_time: String, emotion_id: String, tell_us_why: String, prep_time: String, meditation_time: String, watched_duration: String, level_id: String, complete_percentage: String, rating: String, meditation_type: String, category_id: String, meditation_id: String, date_time: String, type: String, guided_type: String, audio_id: String, step_id: String, mantra_id: String, id: String, is_complete: String, challenge_day_id: String, challenge_type: String) {
        
        var param: [String: Any] = [:]
        param = [
            "type": type,
            "step_id": step_id,
            "mantra_id": mantra_id,
            "category_id": category_id,
            "emotion_id": emotion_id,
            "audio_id": audio_id,
            "guided_type": guided_type,
            "duration" : watched_duration,
            "watched_duration": watched_duration,
            "rating": rating,
            "user_id": user_id,
            "meditation_type": meditation_type,
            "date_time": date_time,
            "tell_us_why": tell_us_why,
            "prep_time": prep_time,
            "meditation_time": meditation_time,
            "rest_time": rest_time,
            "meditation_id": meditation_id,
            "level_id": level_id,
            "mood_id": Int(self.appPreference.getMoodId()) ?? 0,
            "complete_percentage": complete_percentage,
            "is_complete": is_complete,
            "title": "",
            "journal_type": "",
            "challenge_day_id":challenge_day_id,
            "challenge_type":challenge_type
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, context: "WWMTabBarVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if type == "guided"{
                    DispatchQueue.global(qos: .background).async {
                        self.getGuidedListAPI()
                    }
                }else if challenge_day_id != ""{
                    DispatchQueue.global(qos: .background).async {
                        self.getLearnAPI()
                    }
                }
                WWMHelperClass.deleteRowfromDb(dbName: "DBNintyFiveCompletionData", id: id, type: "id")
            }
        }
    }//insert offline data to server*
    
    private func updateGradientLayer() {
        gradientLayer.locations = [ 0.0, 1.2 ]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = [
            UIColor.green.cgColor,
            UIColor.yellow.cgColor ]
    }
    
    @objc func getSettingData() {
        //print(self.userData.name)
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
            if let meditationData = settingData.meditationData!.array as? [DBMeditationData]{
             for dic in meditationData{
                if dic.isMeditationSelected {
                    self.selectedMeditationData = dic
                    if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]{
                    for level in levels{
                        if level.isLevelSelected {
                            selectedLevelData = level
                            self.btnChoosePreset.setTitle("\(selectedLevelData.levelName ?? "")  ", for: .normal)
                            self.setUserDataFromPreference()
                            self.setUpSliderTimesAccordingToLevels()
                                }
                            }//end level
                        }
                    }
                }//end meditation
            }
        }
    }
    
    
    func setUpView() {
        self.btnStartTimer.layer.borderWidth = 2.0
        self.btnStartTimer.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
    }
    func setAnimationForExpressMood() {
        
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutExpressMoodViewWidth.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setUpSliderTimesAccordingToLevels() {
        if self.isChallengePreset{
            self.btnChoosePreset.setTitle("30 Day Challenge", for: .normal)
            self.sliderPrepTime.minimumValue = Float(Int(self.daysListData.prep_time) ?? 0)
            self.sliderPrepTime.maximumValue = Float(Int(self.daysListData.prep_max) ?? 0)
            self.sliderPrepTime.value = Float(Int(self.daysListData.prep_time) ?? 0)
            self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
            self.prepTime = Int(self.sliderPrepTime.value)
            
            self.sliderMeditationTime.minimumValue = Float(Int(self.daysListData.meditation_time) ?? 0)
            self.sliderMeditationTime.maximumValue = Float(Int(self.daysListData.med_max) ?? 0)
            self.sliderMeditationTime.value = Float(Int(self.daysListData.meditation_time) ?? 0)
            self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
            self.meditationTime = Int(self.sliderMeditationTime.value)
            
            self.sliderRestTime.minimumValue = Float(Int(self.daysListData.rest_time) ?? 0)
            self.sliderRestTime.maximumValue = Float(Int(self.daysListData.rest_max) ?? 0)
            self.sliderRestTime.value = Float(Int(self.daysListData.rest_time) ?? 0)
            self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
            self.restTime = Int(self.sliderRestTime.value)
        }else{
            
            if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
                self.sliderPrepTime.minimumValue = Float(selectedLevelData.prepTime)
                self.sliderMeditationTime.minimumValue = Float(selectedLevelData.meditationTime)
                self.sliderRestTime.minimumValue = Float(selectedLevelData.restTime)
            }else{
                self.sliderPrepTime.minimumValue = Float(selectedLevelData.minPrep)
                self.sliderMeditationTime.minimumValue = Float(selectedLevelData.minMeditation)
                self.sliderRestTime.minimumValue = Float(selectedLevelData.minRest)
            }
            
            self.sliderPrepTime.maximumValue = Float(selectedLevelData.maxPrep)
            self.sliderPrepTime.value = Float(selectedLevelData.prepTime)
            self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
            self.prepTime = Int(self.sliderPrepTime.value)
            
            self.sliderMeditationTime.maximumValue = Float(selectedLevelData.maxMeditation)
            self.sliderMeditationTime.value = Float(selectedLevelData.meditationTime)
            self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
            self.meditationTime = Int(self.sliderMeditationTime.value)
            
            self.sliderRestTime.maximumValue = Float(selectedLevelData.maxRest)
            self.sliderRestTime.value = Float(selectedLevelData.restTime)
            self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
            self.restTime = Int(self.sliderRestTime.value)
        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resetMeditationTime(){
        self.sliderMeditationTime.minimumValue = Float(selectedLevelData.minMeditation)
        self.sliderMeditationTime.maximumValue = Float(selectedLevelData.maxMeditation)
        self.sliderMeditationTime.value = Float(selectedLevelData.meditationTime)
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        self.meditationTime = Int(self.sliderMeditationTime.value)
    }

    
    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = (self.sliderPrepTime.superview?.frame.size.height)!-10
        self.layoutSliderRestTimeWidth.constant = (self.sliderRestTime.superview?.frame.size.height)!-10
        self.layoutSliderMeditationTimeWidth.constant = (self.sliderMeditationTime.superview?.frame.size.height)!-10
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
        
        gradientLayer.frame = view.bounds
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return String.init(format: "%d:%02d", second/60,second%60)
        }else {
            if self.min == 1{
                return String.init(format: "%d:%02d", second/60,second%60)
            }else{
                // Modified By Akram
                // return String.init(format: "%d mins", second/60)
                if self.min >= 5 {
                    //return String.init(format: "%d:%02d mins", second/60,second%60)
                    return String.init(format: "%d mins", second/60,second%60)
                }
                return String.init(format: "%d:%02d", second/60,second%60)
            }
        }
    }
    
    func secondsToMinutesSeconds1 (second : Int) -> String {
        if second<60 {
            return String.init(format: "%d:%02d", second/60,second%60)
        }else {
            if self.min >= 2{
                return String.init(format: "%d mins", second/60,second%60)
            }else{
                return String.init(format: "%d min", second/60)
            }
        }
    }
    
    // MARK: - UIButton Action
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
    
        //print("self.sliderPrepTime.value....\(Int(self.sliderPrepTime.value))")
        
        self.min = Int(self.sliderPrepTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.prepTime = Int(self.sliderPrepTime.value/15) * 15
            }else{
                //Modified By Akram
                self.prepTime = Int(self.sliderPrepTime.value/30) * 30
            }
        }else{
            self.prepTime = Int(self.sliderPrepTime.value/15) * 15
        }
        
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.prepTime))
    }
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        self.min = Int(self.sliderMeditationTime.value)/60
        
        if (self.min != 0){
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }else{
            self.meditationTime = Int(self.sliderMeditationTime.value/60) * 60
        }
        
        self.lblMeditationTime.text = self.secondsToMinutesSeconds1(second: Int(self.meditationTime))
    }
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        
        self.min = Int(self.sliderRestTime.value)/60
        
        if (self.min != 0){
            if self.min < 2{
                self.restTime = Int(self.sliderRestTime.value/15) * 15
            }else{
                self.restTime = Int(self.sliderRestTime.value/30) * 30
                if self.min >= 5{
                    self.restTime = Int(self.sliderRestTime.value/60) * 60
                }
            }
        }else{
            self.restTime = Int(self.sliderRestTime.value/15) * 15
        }
            
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.restTime))
    }
    
    @IBAction func btnStartTimerAction(_ sender: Any) {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count < 1{
            return
        }
        
        if self.prepTime == 0 && self.meditationTime == 0 && self.restTime == 0{
            self.setUpSliderTimesAccordingToLevels()
            return
        }
        
        if self.meditationTime == 0{
            self.resetMeditationTime()
            return
        }
        
        //print("prepTime... \(self.prepTime) meditationTime... \(self.meditationTime) restTime... \(self.restTime)")
        self.btnStartTimer.isUserInteractionEnabled = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMStartTimerVC") as! WWMStartTimerVC
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        vc.meditationID = "\(self.selectedMeditationData.meditationId)"
        vc.levelID = "\(self.selectedLevelData.levelId)"
        vc.meditationName = self.selectedMeditationData.meditationName ?? ""
        vc.levelName = self.selectedLevelData.levelName ?? ""
        
        //print("min_limit*** \(self.selectedMeditationData)")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnExpressMoodAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
        vc.type = "pre"
        
        vc.meditationID = "\(self.selectedMeditationData.meditationId)"
        vc.levelID = "\(self.selectedLevelData.levelId)"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    @IBAction func btnPresetLevelAction(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTimerPresetVC") as! WWMTimerPresetVC
        if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData] {
            vc.LevelData = levels
        }
        vc.delegate = self
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension WWMTimerHomeVC: WWMTimerPresetVCDelegate{
    func choosePresetName(index: Int, isChallengePreset: Bool) {
        if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]{
            for indexLevel in 0..<levels.count {
                let level = levels[indexLevel]
                if index == indexLevel {
                    selectedLevelData = level
                    self.btnChoosePreset.setTitle("\(selectedLevelData.levelName ?? "")  ", for: .normal)
                }
            }
            self.isChallengePreset = isChallengePreset
            self.setUpSliderTimesAccordingToLevels()
            //is30DaysPresetSelected
        }
    }
}
