//
//  WWMMeditationLevelVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMMeditationLevelVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate  {
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tblMeditationLevels: UITableView!
    @IBOutlet weak var lblNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblLetsMeditateTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblLetsMeditate: UILabel!
    
    var type = ""
    //let arrMeditationLevel = ["Beginner","Intermediate 1","Intermediate 2","Advanced"]
    var arrMeditationLevels = [DBLevelData]()
    
    var selectedMeditation_Id = ""
    var selectedLevel_Id = ""
    
    var player = AVAudioPlayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        if self.appPreference.getUserName().contains(" "){
            let userNameArr = self.appPreference.getUserName().components(separatedBy: " ")
            self.userName.text = "Ok \(userNameArr[0]),"
        }else{
             self.userName.text = "Ok \(self.appPreference.getUserName()),"
        }
        
        self.tblMeditationLevels.reloadData()
    }
    
    // MARK: UITableView Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.arrMeditationLevels.count)
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell = UITableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "levelCell")!
            let data = self.arrMeditationLevels[indexPath.row]
            let btn = cell.viewWithTag(101) as! UIButton
            btn.setTitle(data.levelName, for: .normal)
            btn.layer.borderWidth = 2.0
            btn.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        let lblPrep = cell.viewWithTag(105) as! UILabel
        lblPrep.text =  self.secondsToMinutesSeconds(second: Int(data.prepTime))
        let lblMed = cell.viewWithTag(103) as! UILabel
        lblMed.text = self.secondsToMinutesSeconds(second: Int(data.meditationTime))
        let lblRest = cell.viewWithTag(104) as! UILabel
        lblRest.text = self.secondsToMinutesSeconds(second: Int(data.restTime))
        
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        self.navigationController?.isNavigationBarHidden = true
        self.selectedLevel_Id = "\(arrMeditationLevels[indexPath.row].levelId)"
        self.meditationApi()
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) sec"
        }else {
            return String.init(format: "%d:%02d min", second/60,second%60)
        }
    }
    
    func meditationApi() {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : self.selectedMeditation_Id,
            "level_id"         : self.selectedLevel_Id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : self.type,
            "guided_type" : ""
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMMeditationLevelVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsProfileCompleted(value: true)
                
                self.appPreference.setGuideType(value: "")
                self.appPreference.setType(value: self.type)
                
                
                print("self.type.... \(self.type)")
                //MM_BEEJA_LETSMEDITATE_V2
                
                //MARK:- play sonic sound
                self.playSound(name: "MM_BEEJA_LETSMEDITATE_V2")
                
                
                UIView.transition(with: self.welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    
                    self.welcomeView.isHidden = false
                    self.userName.alpha = 0
                    self.lblLetsMeditate.alpha = 0
                    
                    UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.lblNameTopConstraint.constant = self.lblNameTopConstraint.constant - 15
                        self.userName.alpha = 1.0
                        self.view.layoutIfNeeded()
                        
                        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                            self.lblLetsMeditateTopConstraint.constant = self.lblLetsMeditateTopConstraint.constant - 15
                            self.lblLetsMeditate.alpha = 1.0
                            
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                        
                    }, completion: nil)
                }) { (Bool) in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
//                        UIApplication.shared.keyWindow?.rootViewController = vc
//                    }
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
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
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
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            player.delegate = self
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished")//It is working now! printed "finished"!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
             UIApplication.shared.keyWindow?.rootViewController = vc
        }

    }
}
