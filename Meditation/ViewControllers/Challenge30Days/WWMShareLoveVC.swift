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
    @IBOutlet weak var imgDArrow: UIImageView!
    @IBOutlet weak var imgDArrowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnInviteFriends: UIButton!
    @IBOutlet weak var lblCopyCode: UILabel!
    @IBOutlet weak var lblNoOfInvites: UILabel!
    @IBOutlet weak var tableViewInvitesList: UITableView!
    @IBOutlet weak var tableViewInvitesListHC: NSLayoutConstraint!
    @IBOutlet weak var tableViewInvitesListTC: NSLayoutConstraint!
    
    var data: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        setUpView()
    }
    
    func setUpView(){
        self.btnInviteFriends.layer.cornerRadius = 20
        self.lblCopyCode.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.lblCopyCode.layer.borderWidth = 1.0
        self.lblCopyCode.layer.cornerRadius = 20
        
        self.imgDArrow.isHidden = true
        self.imgDArrowWidthConstraint.constant = 0
        self.tableViewInvitesList.isHidden = true
        self.tableViewInvitesListHC.constant = 0
        self.tableViewInvitesListTC.constant = 0
        
        self.lblCopyCode.text = "Copy Code: \(self.appPreference.getInvitationCode())"
        
        self.getInviteAccept1API()
    }
    
    @IBAction func btnAlertCloseAction(_ sender: UIButton){
        self.navigationController?.navigationBar.isHidden = false
        self.appPreference.set21ChallengeName(value: "30 Day Challenge")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnInviteFriendsAction(_ sender: UIButton){
        shareData()
    }
    
    @IBAction func btnCopyCodeAction(_ sender: UIButton){
        let board = UIPasteboard.general
        board.string = self.lblCopyCode.text
    }
    
    func shareData(){
        
        let text = "Hey I love using the Beeja Meditation App and think you’d love its premium features too \(self.lblCopyCode.text?.replacingOccurrences(of: "Copy Code: ", with: "") ?? "")"
        
        let imageToShare = [text] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
        }
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func getInviteAccept1API() {
        
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        print("param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_INVITEACCEPTUSERS, context: "WWMShareLoveVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            if let _ = result["success"] as? Bool {
                self.data = result["result"] as? [String] ?? []
                
                self.lblNoOfInvites.text = "\(self.data.count)/5"
                if self.data.count == 0{
                    self.imgDArrow.isHidden = true
                    self.imgDArrowWidthConstraint.constant = 0
                    self.tableViewInvitesList.isHidden = true
                    self.tableViewInvitesListHC.constant = 0
                    self.tableViewInvitesListTC.constant = 0
                }else{
                    self.imgDArrow.isHidden = false
                    self.imgDArrowWidthConstraint.constant = 12
                    self.tableViewInvitesList.isHidden = false
                    self.tableViewInvitesListHC.constant = CGFloat(50 * self.data.count)
                    self.tableViewInvitesListTC.constant = 20
                    
                    self.tableViewInvitesList.delegate = self
                    self.tableViewInvitesList.dataSource = self
                }
                self.tableViewInvitesList.reloadData()
            }
        }
    }
}

extension WWMShareLoveVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewInvitesList.dequeueReusableCell(withIdentifier: "cell")
        let lblEmail = cell?.viewWithTag(1) as! UILabel
        lblEmail.text = self.data[indexPath.row]
        
        return cell!
    }
}
