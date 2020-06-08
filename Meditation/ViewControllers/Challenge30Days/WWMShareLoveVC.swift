//
//  WWMShareLoveVC.swift
//  Meditation
//
//  Created by Prema Negi on 05/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMShareLoveVC: WWMBaseViewController {
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var btnInviteFriends: UIButton!
    @IBOutlet weak var lblCopyCode: UILabel!
    @IBOutlet weak var lblNoOfInvites: UILabel!
    @IBOutlet weak var tableViewInvitesList: UITableView!
    @IBOutlet weak var tableViewInvitesListHC: NSLayoutConstraint!
    @IBOutlet weak var tableViewInvitesListTC: NSLayoutConstraint!
    
    var i = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView(){
        self.btnInviteFriends.layer.cornerRadius = 20
        self.lblCopyCode.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.lblCopyCode.layer.borderWidth = 1.0
        self.lblCopyCode.layer.cornerRadius = 20
        
        if i == 0{
            self.tableViewInvitesList.isHidden = true
            self.tableViewInvitesListHC.constant = 0
            self.tableViewInvitesListTC.constant = 0
        }else{
            self.tableViewInvitesList.isHidden = false
            self.tableViewInvitesListHC.constant = 50 * 5
            self.tableViewInvitesListTC.constant = 20
            
            self.tableViewInvitesList.delegate = self
            self.tableViewInvitesList.dataSource = self
        }
    }
    
    @IBAction func btnAlertCloseAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWM21DaySetReminder1VC") as! WWM21DaySetReminder1VC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnInviteFriendsAction(_ sender: UIButton){
        shareData()
    }
    
    @IBAction func btnCopyCodeAction(_ sender: UIButton){
        let board = UIPasteboard.general
        board.string = self.lblCopyCode.text
    }
    
    func shareData(){
        let text = self.lblCopyCode.text ?? ""
        let imageToShare = [text] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
        }
        
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension WWMShareLoveVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewInvitesList.dequeueReusableCell(withIdentifier: "cell")
        let lblEmail = cell?.viewWithTag(1) as! UILabel
        lblEmail.text = "abc@gmail.com"
        
        return cell!
    }
}
