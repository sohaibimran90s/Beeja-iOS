//
//  WWMMeditationLevelVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMMeditationLevelVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tblMeditationLevels: UITableView!
    
    //let arrMeditationLevel = ["Beginner","Intermediate 1","Intermediate 2","Advanced"]
    var arrMeditationLevels = [DBLevelData]()
    
    var selectedMeditation_Id = ""
    var selectedLevel_Id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        self.userName.text = "Ok \(self.appPreference.getUserName())"
        let meditationData = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        for  data in meditationData{
            if data.isMeditationSelected {
                self.selectedMeditation_Id = "\(data.meditationId)"
                if let levels = data.levels?.array as? [DBLevelData] {
                    arrMeditationLevels = levels
                }
                
            }
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
        for index in 0..<arrMeditationLevels.count {
            if index == indexPath.row {
                arrMeditationLevels[index].isLevelSelected = true
                self.selectedLevel_Id = "\(arrMeditationLevels[index].levelId)"
            }else {
                arrMeditationLevels[index].isLevelSelected = false
            }
        }
        
        self.meditationApi()
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) secs"
        }else {
            return String.init(format: "%d:%d mins", second/60,second%60)
        }
        
    }
    
    func meditationApi() {
        self.view.endEditing(true)
        WWMHelperClass.showSVHud()
        let param = [
            "meditation_id" : self.selectedMeditation_Id,
            "level_id"         : self.selectedLevel_Id,
            "user_id"       : self.appPreference.getUserID()
        ]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.appPreference.setIsProfileCompleted(value: true)
                UIView.transition(with: self.welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.welcomeView.isHidden = false
                }) { (Bool) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
            }else {
                WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
            }
            WWMHelperClass.dismissSVHud()
        }
    }
}
