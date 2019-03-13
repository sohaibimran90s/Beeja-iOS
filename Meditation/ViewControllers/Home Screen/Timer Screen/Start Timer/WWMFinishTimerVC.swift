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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
            vc.type = "Post"
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            self.navigationController?.pushViewController(vc, animated: false)
        }
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
