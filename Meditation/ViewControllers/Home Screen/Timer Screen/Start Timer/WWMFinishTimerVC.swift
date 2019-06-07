//
//  WWMFinishTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 11/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMFinishTimerVC: UIViewController {

    @IBOutlet weak var lblPrep: UILabel!
    @IBOutlet weak var lblMeditation: UILabel!
    @IBOutlet weak var lblRest: UILabel!
    
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var type = ""   // Pre | Post
    var meditationID = ""
    var levelID = ""
    var settingData = DBSettings()
    var alertPrompt = WWMPromptMsg()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
    }
    
    func setUpUI() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        self.lblPrep.text = self.secondsToMinutesSeconds(second: prepTime)
        self.lblMeditation.text = self.secondsToMinutesSeconds(second: meditationTime)
        self.lblRest.text = self.secondsToMinutesSeconds(second: restTime)
        
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    func xibCall(){
        alertPrompt = UINib(nibName: "WWMPromptMsg", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMPromptMsg
        let window = UIApplication.shared.keyWindow!
        
        alertPrompt.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPrompt, duration: 0.8, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPrompt)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.alertPrompt.removeFromSuperview()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
                vc.type = "Post"
                vc.prepTime = self.prepTime
                vc.meditationTime = self.meditationTime
                vc.restTime = self.restTime
                vc.meditationID = self.meditationID
                vc.levelID = self.levelID
                vc.hidShowMoodMeter = "Hide"
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        
        if self.settingData.moodMeterEnable {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
            vc.type = "Post"
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            self.xibCall()
        }
    }
}
