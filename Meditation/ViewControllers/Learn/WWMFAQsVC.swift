//
//  WWMFAQsVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMFAQsVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnGotIt: UIButton!
    var selectedIndex = 0
    
    var faqsData: [WWMFAQsData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnGotIt.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        self.fetchStepFAQDataFromDB(step_id: "\(WWMHelperClass.step_id)")
    }

    
    @IBAction func btnGotItClicked(_ sender: UIButton) {
        
        if WWMHelperClass.step_id == 12{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnDiscountVC") as! WWMLearnDiscountVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            //self.navigationController?.isNavigationBarHidden = false
            
            if let tabController = self.tabBarController as? WWMTabBarVC {
                tabController.selectedIndex = 4
                for index in 0..<tabController.tabBar.items!.count {
                    let item = tabController.tabBar.items![index]
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                    if index == 4 {
                        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                    }
                }
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    //MARK: Fetch StepFAQ Data from DB
    func fetchStepFAQDataFromDB(step_id: String) {
        let stepFaqDataDB = WWMHelperClass.fetchDB(dbName: "DBStepFaq") as! [DBStepFaq]
        
        var jsonString: [String: Any] = [:]
        if stepFaqDataDB.count > 0 {
            print("self.stepFaqDataDB... \(stepFaqDataDB.count)")
            for dict in stepFaqDataDB {
                
                if dict.step_id == step_id{
                    jsonString["answers"] = dict.answers
                    jsonString["question"] = dict.question
                    
                    let faqsData = WWMFAQsData.init(json: jsonString)
                    self.faqsData.append(faqsData)
                }
                
                print("self.faqsData... \(self.faqsData.count)")
            }
        }
    }
}

extension WWMFAQsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faqsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMFAQsTVC") as! WWMFAQsTVC
        
        cell.lblTitle.text = self.faqsData[indexPath.row].question
        cell.lblStepDescription.text = self.faqsData[indexPath.row].answers
        
        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.imgArraow.image = UIImage(named: "upArrow")
        }else{
            cell.lblStepDescription.isHidden = true
            cell.imgArraow.image = UIImage(named: "downArrow")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
}

