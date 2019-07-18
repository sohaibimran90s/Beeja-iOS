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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnGotIt.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func btnGotItClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnReminderVC") as! WWMLearnReminderVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WWMFAQsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMFAQsTVC") as! WWMFAQsTVC
        
        cell.lblTitle.text = "Lorem ipsum dolor sit amet?"
        cell.lblStepDescription.text = "In this class we quickly get you setup with a mantric sound to play with. It will enable you to get to grips with this very easy, and effective practise. We will then guide you through the first steps of learning to become a self sufficient meditator. We will start with a simple exercise to get you in the zone, we’ll get you grounded in your body, and then teach how to work with the mantra in the most effective way."
        
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

