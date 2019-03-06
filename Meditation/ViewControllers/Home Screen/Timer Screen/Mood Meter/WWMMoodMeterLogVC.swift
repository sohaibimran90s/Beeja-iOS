//
//  WWMMoodMeterLogVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodMeterLogVC: WWMBaseViewController {

    var moodData = WWMMoodMeterData()
    @IBOutlet weak var lblExpressMood: UILabel!
    @IBOutlet weak var btnBurnMood: UIButton!
    @IBOutlet weak var btnLogExperience: UIButton!
    @IBOutlet weak var txtViewLog: UITextView!
    
    var type = ""   // Pre | Post
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var backgroundvedioView = WWMBackgroundVedioView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        // Do any additional setup after loading the view.
    }

    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.btnBurnMood.layer.borderWidth = 2.0
        self.btnBurnMood.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLogExperience.layer.borderWidth = 2.0
        self.btnLogExperience.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.lblExpressMood.text = moodData.mood
        if !moodData.show_burn {
            btnBurnMood.isHidden = true
        }
        if moodData.mood != "" {
            self.txtViewLog.text = "I am feeling \(moodData.mood) because"
        }
        
        self.txtViewLog.layer.borderColor = UIColor.lightGray.cgColor
        self.txtViewLog.layer.borderWidth = 1.0
        self.txtViewLog.layer.cornerRadius = 2.0
    }
    
    // MARK:- Button Action
    
    @IBAction func btnSkipAction(_ sender: Any) {
        
    }
    
    @IBAction func btnBurnMoodAction(_ sender: Any) {
        if self.type == "Pre" {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            backgroundvedioView.frame = self.view.frame
            backgroundvedioView.createBackground(name: "Burn", type: "mp4")
            self.view.addSubview(backgroundvedioView)
            
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodJournalVC") as! WWMMoodJournalVC
//            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    @IBAction func btnLogExperienceAction(_ sender: Any) {
        if  txtViewLog.text == "" {
            WWMHelperClass.showPopupAlertController(sender: self, message: Validation_JournalMessage, title: kAlertTitle)
        }else {
            self.logExperience()
        }
    }
    
    func logExperience() {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let dict = [
            "dateTime" : "1548684842",
            "mood_color": self.moodData.color,
            "mood_text": self.moodData.mood,
            "tellUsWhy": self.txtViewLog.text,
            "prepTime": self.prepTime,
            "meditaionTime": self.meditationTime,
            "restTime": self.restTime,
            "meditationId": "2",
            "meditationType" : type
            ] as [String : Any]
        meditationDB.meditationData = dict.description
        WWMHelperClass.saveDb()
        let alert = UIAlertController.init(title: "Your Meditation experienced has been logged", message: nil, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismiss(animated: true, completion: {
                if self.type == "Pre" {
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.popToRootViewController(animated: false)
                }else {
                    
                    if !self.moodData.show_burn {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodShareVC") as! WWMMoodShareVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        self.navigationController?.isNavigationBarHidden = false
                        
                        if let tabController = self.tabBarController as? WWMTabBarVC {
                            tabController.selectedIndex = 4
                        }
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                    
                    
                }
            })
            
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
