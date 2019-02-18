//
//  WWMEditMeditationTimeVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMEditMeditationTimeVC: WWMBaseViewController {

    
    @IBOutlet weak var layoutSliderPrepTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var sliderPrepTime: WWMSlider!
    @IBOutlet weak var layoutSliderMeditationTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblMeditationTime: UILabel!
    @IBOutlet weak var sliderMeditationTime: WWMSlider!
    @IBOutlet weak var layoutSliderRestTimeWidth: NSLayoutConstraint!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var sliderRestTime: WWMSlider!
    
    @IBOutlet weak var btnSaveSettings: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var settingData = DBSettings()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setUpViewAndDataFetch()
        // Do any additional setup after loading the view.
    }
    
    func setUpViewAndDataFetch() {
        self.setUpNavigationBarForDashboard(title: "Settings")
        self.btnSaveSettings.layer.borderWidth = 2.0
        self.btnSaveSettings.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        self.setUpSliderTimesAccordingToLevels()
        
    }

    override func viewDidLayoutSubviews() {
        self.layoutSliderPrepTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderRestTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
        self.layoutSliderMeditationTimeWidth.constant = self.sliderPrepTime.superview?.frame.size.height ?? 0.0
    }
    
    func setUpSliderTimesAccordingToLevels() {
        self.sliderPrepTime.minimumValue = 10
        self.sliderPrepTime.maximumValue = 600
        self.sliderPrepTime.value = Float(settingData.prepTime!)!
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
        
        self.sliderMeditationTime.minimumValue = 60
        self.sliderMeditationTime.maximumValue = 3600
        self.sliderMeditationTime.value = Float(settingData.meditationTime!)!
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
        
        self.sliderRestTime.minimumValue = 10
        self.sliderRestTime.maximumValue = 600
        self.sliderRestTime.value = Float(settingData.restTime!)!
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    // MARK: - UIButton Action
    
    
    @IBAction func sliderPrepTimeValueChangedAction(_ sender: Any) {
        self.lblPrepTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderPrepTime.value))
    }
    @IBAction func sliderMeditationTimeValueChangedAction(_ sender: Any) {
        self.lblMeditationTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderMeditationTime.value))
    }
    @IBAction func sliderRestTimeValueChangedAction(_ sender: Any) {
        self.lblRestTime.text = self.secondsToMinutesSeconds(second: Int(self.sliderRestTime.value))
    }
    
    @IBAction func btnSaveSettingAction(_ sender: Any) {
        self.settingData.prepTime = "\(Int(self.sliderPrepTime.value))"
        self.settingData.restTime = "\(Int(self.sliderRestTime.value))"
        self.settingData.meditationTime = "\(Int(self.sliderMeditationTime.value))"
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) secs"
        }else {
            return String.init(format: "%d:%d mins", second/60,second%60)
        }
        
    }
}
