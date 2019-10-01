//
//  WWMLearnStepListVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnStepListVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var layoutMoodWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutExpressMoodViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblExpressMood: UILabel!

    let appPreffrence = WWMAppPreference()
    var selectedIndex = 0
    var total_paid: Int = 0
    
    var learnStepsListData: [LearnStepsListData] = []
    var alertPopup = WWMAlertPopUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar(isShow: false, title: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAnimationForExpressMood()
        }
        
        self.selectedIndex = 0
        getLearnSetpsAPI()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
        self.lblExpressMood.transform = CGAffineTransform(rotationAngle:CGFloat(+Double.pi/2))
        self.layoutMoodWidth.constant = 90
    }
    
    func setAnimationForExpressMood() {
        
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.layoutExpressMoodViewWidth.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func btnExpressMoodAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterVC") as! WWMMoodMeterVC
        vc.type = "pre"
        vc.meditationID = "0"
        vc.levelID = "0"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnIntroClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "learnStepList"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: API call
    func getLearnSetpsAPI() {
        
        self.learnStepsListData.removeAll()        
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        //let param = ["user_id": "747"] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STEPS, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            print("learn result... \(result)")
            if sucess {
                if let total_paid = result["total_paid"] as? Double{
                    print("total_paid double.. \(total_paid)")
                    self.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    for json in data{
                        let learnStepsListData = LearnStepsListData.init(json: json)
                        self.learnStepsListData.append(learnStepsListData)
                    }
                }
                
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                
                self.tableView.reloadData()
                
                print("self.total_paid......\(self.total_paid)")
                print("self.learnStepsListData......\(self.learnStepsListData.count)")
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    @IBAction func btnSideMenuClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSideMenuVC") as! WWMSideMenuVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func xibCall(title1: String){
        alertPopup = UINib(nibName: "WWMAlertPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertPopup.lblTitle.text = title1
        alertPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPopup, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertPopup.removeFromSuperview()
            }
        }
    }
}

extension WWMLearnStepListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.learnStepsListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMLearnStepListTVC") as! WWMLearnStepListTVC
        
        cell.lblNoOfSteps.layer.cornerRadius = 12
        cell.lblStepDescription.text = self.learnStepsListData[indexPath.row].Description
        cell.lblNoOfSteps.text = "\(self.learnStepsListData[indexPath.row].id)"
        cell.lblSteps.text = self.learnStepsListData[indexPath.row].step_name
        cell.lblStepsTitle.text = self.learnStepsListData[indexPath.row].title

        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.btnProceed.isHidden = false
            
            cell.backImgView.backgroundColor = UIColor(red: 14.0/255.0, green: 31.0/255.0, blue: 104.0/255.0, alpha: 0.7)
            cell.imgArraow.image = UIImage(named: "upArrow")
            
            cell.lblNoOfSteps.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.lblUprLine.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            cell.lblBelowLine.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
            
        }else{
            cell.lblStepDescription.isHidden = true
            cell.btnProceed.isHidden = true
            
            cell.backImgView.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            cell.imgArraow.image = UIImage(named: "downArrow")
            
            cell.lblNoOfSteps.backgroundColor = UIColor.white
            cell.lblUprLine.backgroundColor = UIColor.white
            cell.lblBelowLine.backgroundColor = UIColor.white
        }
        
        if indexPath.row == 0{
            cell.lblUprLine.isHidden = true
        }
        
        
        cell.btnProceed.addTarget(self, action: #selector(btnProceedClicked), for: .touchUpInside)
        cell.btnProceed.tag = indexPath.row
        
        print("self.total_paid... \(self.total_paid)")
        if self.appPreffrence.getExpiryDate(){
            cell.imgLock.image = UIImage(named: "")
            cell.isUserInteractionEnabled = true
        }else{
            if indexPath.row > 2{
                cell.imgLock.image = UIImage(named: "lock")
            }else{
                cell.imgLock.image = UIImage(named: "")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    @objc func btnProceedClicked(_ sender: UIButton){
        
        WWMHelperClass.step_audio = self.learnStepsListData[sender.tag].step_audio
        WWMHelperClass.timer_audio = self.learnStepsListData[sender.tag].timer_audio
        WWMHelperClass.outro_audio = self.learnStepsListData[sender.tag].outro_audio
        WWMHelperClass.step_id = self.learnStepsListData[sender.tag].id
        WWMHelperClass.step_title = self.learnStepsListData[sender.tag].title
        WWMHelperClass.total_paid = self.total_paid
        
        var flag = 0
        var position = 0
        var dateCompareLoopCount = 0
        var senderTag = -1

        if self.appPreffrence.getExpiryDate(){
            dateCompareLoopCount = self.learnStepsListData.count - 1
        }else{
            dateCompareLoopCount = 2
            if sender.tag > 2{
                self.xibCall(title1: KLEARNANNUALSUBS)
                return
            }
        }
        
        for i in 0...dateCompareLoopCount{
            
            let date_completed = self.learnStepsListData[i].date_completed
            if date_completed != ""{
                let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                if dateCompare.0 == 1{
                    senderTag = i
                    flag = 1
                    break
                }
            }
        }
        
        if flag == 1{
            
            print("sender.Tag.... \(sender.tag) senderTag.... \(senderTag)")
            
            if sender.tag == senderTag{
                WWMHelperClass.selectedType = "learn"
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.xibCall(title1: KLEARNONESTEP)
            }
            print("already played the step")
            
        }else{
            for i in 0..<sender.tag{
                if !self.learnStepsListData[i].completed{
                    flag = 2
                    position = i
                    break
                }
            }
                
            if flag == 2{
                print("first play the \(self.learnStepsListData[position].step_name)")
                
                self.xibCall(title1: "\(KLEARNJUMPSTEP) \(self.learnStepsListData[position].step_name) \(KLEARNJUMPSTEP1)")
            }else{
                WWMHelperClass.selectedType = "learn"
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnGetSetVC") as! WWMLearnGetSetVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
