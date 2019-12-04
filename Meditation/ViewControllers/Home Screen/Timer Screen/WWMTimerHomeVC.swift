//
//  WWMTimerHomeVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. Allx rights reserved.
//

import UIKit

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
    
    var selectedMeditationData  = DBMeditationData()
    var selectedLevelData  = DBLevelData()
    var settingData = DBSettings()
    
    let gradientLayer = CAGradientLayer()
    
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var min = 0

    //var alertPopupView = WWMAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getSettingData),
            name: NSNotification.Name(rawValue: "GETSettingData"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Timer")
        self.getSettingData()
    }
    
    private func updateGradientLayer() {
        gradientLayer.locations = [ 0.0, 1.2 ]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = [
            UIColor.green.cgColor,
            UIColor.yellow.cgColor ]
    }
    
    @objc func getSettingData() {
        print(self.userData.name)
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
        self.sliderPrepTime.minimumValue = Float(selectedLevelData.minPrep)
        self.sliderPrepTime.maximumValue = Float(selectedLevelData.maxPrep)
        self.sliderPrepTime.value = Float(selectedLevelData.prepTime)
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        self.prepTime = Int(self.sliderPrepTime.value)
        
        self.sliderMeditationTime.minimumValue = Float(selectedLevelData.minMeditation)
        self.sliderMeditationTime.maximumValue = Float(selectedLevelData.maxMeditation)
        self.sliderMeditationTime.value = Float(selectedLevelData.meditationTime)
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        self.meditationTime = Int(self.sliderMeditationTime.value)
        
        self.sliderRestTime.minimumValue = Float(selectedLevelData.minRest)
        self.sliderRestTime.maximumValue = Float(selectedLevelData.maxRest)
        self.sliderRestTime.value = Float(selectedLevelData.restTime)
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
        self.restTime = Int(self.sliderRestTime.value)
        
//        if !self.userData.is_subscribed {
//
//            alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
//            let window = UIApplication.shared.keyWindow!
//
//            alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
//            alertPopupView.btnOK.layer.borderWidth = 2.0
//            alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//
//            alertPopupView.lblTitle.text = kAlertTitle
//            alertPopupView.lblSubtitle.text = "Your subscription plan is expired to continue please upgrade."
//            alertPopupView.btnClose.isHidden = true
//
//            alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
//            window.rootViewController?.view.addSubview(alertPopupView)
//        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMUpgradeBeejaVC") as! WWMUpgradeBeejaVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = (self.sliderPrepTime.superview?.frame.size.height)!-10
        self.layoutSliderRestTimeWidth.constant = (self.sliderRestTime.superview?.frame.size.height)!-10
        self.layoutSliderMeditationTimeWidth.constant = (self.sliderMeditationTime.superview?.frame.size.height)!-10
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
        
        gradientLayer.frame = view.bounds
        
       //self.sliderPrepTime.minimumTrackImage(for: <#T##UIControl.State#>)
       // self.sliderPrepTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
      //  self.sliderRestTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)
      //  self.sliderMeditationTime.setMinimumTrackImage(UIImage.init(named: "minSlider_Icon"), for: .normal)

        //self.sliderPrepTime.setMaximumTrackImage(UIImage.init(named: "maxSlider_Icon"), for: .normal)
        
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
    
        print("self.sliderPrepTime.value....\(Int(self.sliderPrepTime.value))")
        
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
        self.btnStartTimer.isUserInteractionEnabled = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMStartTimerVC") as! WWMStartTimerVC
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        vc.meditationID = "\(self.selectedMeditationData.meditationId)"
        vc.levelID = "\(self.selectedLevelData.levelId)"
        vc.meditationName = self.selectedMeditationData.meditationName ?? ""
        vc.levelName = self.selectedLevelData.levelName ?? ""
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
        
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        for index in 0..<selectedMeditationData.levels!.count+1 {
//            if index == selectedMeditationData.levels!.count {
//                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//            }else {
//                let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]
//                alert.addAction(UIAlertAction.init(title: levels![index].levelName, style: .default, handler: { (UIAlertAction) in
//                self.ActionSheetAction(index: index)
//            }))
//            }
//        }
//
//        alert.view.tintColor = UIColor.black
//        self.present(alert, animated: true, completion: {
//            print("completion block")
//        })
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTimerPresetVC") as! WWMTimerPresetVC
        if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData] {
            vc.LevelData = levels
        }
        vc.delegate = self
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func ActionSheetAction(index:Int) {
        let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]
        for indexLevel in 0..<levels!.count {
            let level = levels![indexLevel]
                if index == indexLevel {
                    selectedLevelData = level
                    self.btnChoosePreset.setTitle("\(selectedLevelData.levelName ?? "")  ", for: .normal)
                }
        }
        self.setUpSliderTimesAccordingToLevels()
                
    }
}

extension WWMTimerHomeVC: WWMTimerPresetVCDelegate{
    func choosePresetName(index: Int) {
        if let levels = self.selectedMeditationData.levels?.array as? [DBLevelData]{
            for indexLevel in 0..<levels.count {
                let level = levels[indexLevel]
                if index == indexLevel {
                    selectedLevelData = level
                    self.btnChoosePreset.setTitle("\(selectedLevelData.levelName ?? "")  ", for: .normal)
                }
            }
            self.setUpSliderTimesAccordingToLevels()
        }
    }
}
