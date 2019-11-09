//
//  WWMFinishTimerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 11/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMFinishTimerVC: UIViewController {

//    @IBOutlet weak var lblPrep: UILabel!
//    @IBOutlet weak var lblMeditation: UILabel!
//    @IBOutlet weak var lblRest: UILabel!
    
    private var finishedLoadingInitialTableCells = false
    
    @IBOutlet weak var lblTodaysSession: UILabel!
    @IBOutlet weak var tablView: UITableView!
    @IBOutlet weak var btnDoneOutlet: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblTodaySessionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnTopConstraint: NSLayoutConstraint!
    
    var rowHeight: CGFloat = 0
    
    var prepTime = 0
    var meditationTime = 0
    var meditationMaxTime = 0
    var restTime = 0
    var type = ""   // Pre | Post
    var meditationID = ""
    var levelID = ""
    var meditationName = ""
    var levelName = ""
    var settingData = DBSettings()
    var alertPrompt = WWMPromptMsg()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnDoneOutlet.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUpUI()
        }
    }
    
    func setUpUI() {
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        
        self.lblTodaysSession.text = "Today’s session"
        self.btnDoneOutlet.isHidden = false
        
        self.tablView.delegate = self
        self.tablView.dataSource = self
        
        self.btnDoneOutlet.alpha = 0.0
        self.lblTodaysSession.alpha = 0.0
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                rowHeight = 110
            case 1334:
                print("iPhone 6/6S/7/8")
                rowHeight = 130
            case 2208:
                print("iPhone 6+/6S+/7+/8+")
                rowHeight = 150
            case 2436:
                print("iPhone X, XS")
                rowHeight = 180
            case 2688:
                print("iPhone XS Max")
                rowHeight = 200
            case 1792:
                print("iPhone XR")
                rowHeight = 180
            default:
                print("unknown")
                rowHeight = 150
            }
        }
        
        self.tableViewHeightConstraint.constant = 3 * rowHeight
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
                vc.type = "post"
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
    
    func convertDurationIntoPercentage(duration:Int) -> String  {
        if self.meditationMaxTime > 0 {
            
            var per = (Double(duration)/Double(self.meditationMaxTime))*100
            per = per/10
            per = per.rounded()
            per = per*10
            
            guard !(per.isNaN || per.isInfinite) else {
                return "0%" // or do some error handling
            }
            
            return "\(Int(per))%"
        }
        return "0%"
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        var analyticMedName = self.meditationName.uppercased()
        analyticMedName = analyticMedName.replacingOccurrences(of: " ", with: "_")
        var analyticLevelName = self.levelName.uppercased()
        analyticLevelName = analyticLevelName.replacingOccurrences(of: " ", with: "_")
        
        WWMHelperClass.sendEventAnalytics(contentType: "TIMER", itemId: "\(analyticMedName)_\(analyticLevelName)", itemName:self.convertDurationIntoPercentage(duration:self.meditationTime))
        
        if self.settingData.moodMeterEnable {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
            vc.type = "post"
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

extension WWMFinishTimerVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tablView.dequeueReusableCell(withIdentifier: "WWMFinishTimerTVC") as! WWMFinishTimerTVC
        
        if indexPath.row == 0{
            cell.lblPrepMedRestPrep.text = "Prep"
            cell.lblPrepMedRestText.text = self.secondsToMinutesSeconds(second: prepTime)
        }else if indexPath.row == 1{
            cell.lblPrepMedRestPrep.text = "Meditation"
            cell.lblPrepMedRestText.text = self.secondsToMinutesSeconds(second: meditationTime)
        }else{
            cell.lblPrepMedRestPrep.text = "Rest"
            cell.lblPrepMedRestText.text = self.secondsToMinutesSeconds(second: restTime)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if 3 > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        
        if !finishedLoadingInitialTableCells {
            
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight/2)
            cell.alpha = 0
            
            // UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations:
            
            UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseInOut, animations: {
                self.lblTodaysSession.alpha = 1.0
                self.lblTodaySessionTopConstraint.constant = self.lblTodaySessionTopConstraint.constant - 14
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            UIView.animate(withDuration: 0.7, delay: 0.1*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.btnDoneOutlet.alpha = 1.0
                    self.btnTopConstraint.constant = self.btnTopConstraint.constant - 20
                }, completion: nil)
            })
            
            
        }
    }
}

