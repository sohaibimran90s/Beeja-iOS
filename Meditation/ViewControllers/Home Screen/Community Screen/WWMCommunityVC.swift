//
//  WWMCommunityVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import SDWebImage

class WWMCommunityVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var communityData = WWMCommunityData()
    
    @IBOutlet weak var tblViewCommunity: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getCommunityAPI()
        self.setUpNavigationBarForDashboard(title: "Community")
        // Do any additional setup after loading the view.
    }
    

    
    
    // MARK:- UITable View Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = WWMCommunityTableViewCell()
        if indexPath.row == 0 {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellFirst") as! WWMCommunityTableViewCell
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
            
        }else if indexPath.row == 1 {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellSecond") as! WWMCommunityTableViewCell
            if self.communityData.events.count < 3 {
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)/2
            }
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)
        }else {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellThird") as! WWMCommunityTableViewCell
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
        }
        cell.collectionViewCommunity.tag = indexPath.row
        cell.collectionViewCommunity.reloadData()
        return cell
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return self.communityData.events.count
        }else if collectionView.tag == 2 {
            return self.communityData.hashtags.count
        }else {
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        if collectionView.tag == 0 {
             cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCell", for: indexPath) as! WWMCommunityCollectionViewCell
        }else if collectionView.tag == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! WWMCommunityCollectionViewCell
            let data = self.communityData.events[indexPath.row]
            
            cell.imgView.sd_setImage(with: URL.init(string: data.imageUrl), placeholderImage: UIImage.init(named: ""), options: .scaleDownLargeImages, completed: nil)
            cell.lblTitle.text = data.eventTitle
            
        }else if collectionView.tag == 2 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
            let data = self.communityData.hashtags[indexPath.row]
            cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: ""), options: .scaleDownLargeImages, completed: nil)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            let width = (self.view.frame.size.width-14)/2
            return CGSize.init(width: width, height: width)
        }
        let width = (self.view.frame.size.width-8)/2.5
        return CGSize.init(width: width, height: width)
    }
    
    
    func getCommunityAPI() {
        let param = ["user_Id":1,
                     "month":"201905"] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMMUNITYDATA, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                self.communityData = WWMCommunityData.init(json: result["result"] as! [String : Any])
                self.tblViewCommunity.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
        }
    }
}
