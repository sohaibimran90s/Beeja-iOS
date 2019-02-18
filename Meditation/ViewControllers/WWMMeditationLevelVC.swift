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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        self.userName.text = "Ok You"
        let meditationData = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        for  data in meditationData{
            if data.isMeditationSelected {
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
            }else {
                arrMeditationLevels[index].isLevelSelected = false
            }
        }
        
        self.appPreference.setUserData(value: [:])
        UIView.transition(with: welcomeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.welcomeView.isHidden = false
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
        
        }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) secs"
        }else {
            return String.init(format: "%d:%d mins", second/60,second%60)
        }
        
    }
//        UIView.animateWithDuration(0.5, delay: 0.5, options: .curveEaseOut, animations: {
//            self.uiImageView.alpha = 0.0
//        }, completion: nil)
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var cellHeight:CGFloat = tableView.frame.size.height
//        let numberOfCell = self.arrMeditationLevel.count
//        cellHeight = cellHeight / CGFloat(numberOfCell)
//        return cellHeight
//}
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
}
