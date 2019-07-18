//
//  WWMChooseMantraListVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMChooseMantraListVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension WWMChooseMantraListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMChooseMantraListTVC") as! WWMChooseMantraListTVC
        
        cell.lblStepDescription.text = "In this class we quickly get you setup with a mantric sound to play with. It will enable you to get to grips with this very easy, and effective practise. We will then guide you through the first steps of learning to become a self sufficient meditator. We will start with a simple exercise to get you in the zone, we’ll get you grounded in your body, and then teach how to work with the mantra in the most effective way."
        
        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.btnProceed.isHidden = false
            cell.imgArraow.image = UIImage(named: "upArrow")
        
        }else{
            cell.lblStepDescription.isHidden = true
            cell.btnProceed.isHidden = true
            cell.imgArraow.image = UIImage(named: "downArrow")
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnLetsMeditateVC") as! WWMLearnLetsMeditateVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
