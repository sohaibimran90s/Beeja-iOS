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
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        getLearnSetpsAPI()
    }
    
    @IBAction func btnIntroClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "learnStepList"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    ///api/v1/setps
    func getLearnSetpsAPI() {
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_STEPS, headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
//                if let data = result["data"] as? [String: Any]{
//                    if let records = data["records"] as? [[String: Any]]{
//                        for dict in records{
//                            let data = WWMMeditationHistoryListData(json: dict)
//                            self.data.append(data)
//                        }
//                    }
//
//                    if self.data.count > 0{
//                        self.medHisViewHeightConstraint.constant = 416
//                        self.collectionView.reloadData()
//                    }else{
//                        self.medHisViewHeightConstraint.constant = 0
//                    }
//                }
                
                
                print("url....setps****** \(URL_STEPS)")
                print("result....setps****** \(result)")
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
}

extension WWMLearnStepListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMLearnStepListTVC") as! WWMLearnStepListTVC
        
        cell.lblNoOfSteps.layer.cornerRadius = 12
        cell.lblStepDescription.text = "In this class we quickly get you setup with a mantric sound to play with. It will enable you to get to grips with this very easy, and effective practise. We will then guide you through the first steps of learning to become a self sufficient meditator. We will start with a simple exercise to get you in the zone, we’ll get you grounded in your body, and then teach how to work with the mantra in the most effective way."

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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnFlightModeVC") as! WWMLearnFlightModeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
