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
    var observers = [NSKeyValueObservation]()
    
    @IBOutlet weak var tblViewCommunity: UITableView!
    var strMonthYear = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: Date())
        self.getCommunityAPI()
        self.setUpNavigationBarForDashboard(title: "Community")
        // Do any additional setup after loading the view.
        
        
        
        if WWMSpotifyManager.sharedManager.authorize() {
            WWMSpotifyManager.sharedManager.connect();
        }
        
        self.observers = [
            WWMSpotifyManager.sharedManager.observe(\.currentPlaylist, options: [.initial]) { [weak self] (playlist, change) in
                self?.tblViewCommunity.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        ]
    }
    
    
    // MARK:- UITable View Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.communityData.events.count == 0 {
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = WWMCommunityTableViewCell()
        if self.communityData.events.count == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellFirst") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewSpotifyAction(_:)), for: .touchUpInside)
                
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellThird") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnUploadHashTagsAction(_:)), for: .touchUpInside)
            }
            cell.collectionViewCommunity.tag = indexPath.row
            cell.collectionViewCommunity.reloadData()
            return cell
        }else {
        if indexPath.row == 0 {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellFirst") as! WWMCommunityTableViewCell
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
            cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewSpotifyAction(_:)), for: .touchUpInside)
            
        }else if indexPath.row == 1 {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellSecond") as! WWMCommunityTableViewCell
            if self.communityData.events.count < 3 {
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)/2
            }
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)
            cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewAllEventsAction(_:)), for: .touchUpInside)
        }else {
             cell = tableView.dequeueReusableCell(withIdentifier: "CellThird") as! WWMCommunityTableViewCell
            cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
            cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnUploadHashTagsAction(_:)), for: .touchUpInside)
        }
        cell.collectionViewCommunity.tag = indexPath.row
        cell.collectionViewCommunity.reloadData()
        return cell
        }
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.communityData.events.count == 0 {
             if collectionView.tag == 1 {
                return self.communityData.hashtags.count
            }else {
                print(WWMSpotifyManager.sharedManager.currentPlaylist?.count ?? 0)
                return WWMSpotifyManager.sharedManager.currentPlaylist?.count ?? 0
            }
        }else {
            if collectionView.tag == 1 {
                if self.communityData.events.count > 4 {
                    return 4
                }
                return self.communityData.events.count
            }else if collectionView.tag == 2 {
                return self.communityData.hashtags.count
            }else {
                return WWMSpotifyManager.sharedManager.currentPlaylist?.count ?? 0
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        if self.communityData.events.count == 0 {
            if collectionView.tag == 0 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let playlist = WWMSpotifyManager.sharedManager.currentPlaylist![indexPath.row]
                cell.lblTitle.text = playlist["name"] as? String
                let images = playlist["images"] as! [Dictionary<String, Any>]
                for imageDictionary in images {
                    if let imageSize = imageDictionary["height"] as? Int {
                        if imageSize == 640 {
                            let imageUrl = imageDictionary["url"] as! String
                            print("\(imageUrl)")
                            cell.imgView.sd_setImage(with: URL.init(string: imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                            
                            /* var url:NSURL = NSURL.URLWithString("http://myURL/ios8.png")
                             var data:NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
                             
                             imageView.image = UIImage.imageWithData(data)*/
                        }
                    }
                    
                }
                
                
                
                
                
                
                
            }else if collectionView.tag == 1 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.hashtags[indexPath.row]
                cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            }
        }else {
            if collectionView.tag == 0 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCell", for: indexPath) as! WWMCommunityCollectionViewCell
            }else if collectionView.tag == 1 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.events[indexPath.row]
            
                cell.imgView.sd_setImage(with: URL.init(string: data.imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                cell.lblTitle.text = data.eventTitle
            
            }else if collectionView.tag == 2 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.hashtags[indexPath.row]
                cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            let playlist = WWMSpotifyManager.sharedManager.currentPlaylist![indexPath.row]
            print("\(playlist)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.communityData.events.count > 0 {
            if collectionView.tag == 1 {
                let width = (self.view.frame.size.width-14)/2
                return CGSize.init(width: width, height: width)
            }
        }
        
        let width = (self.view.frame.size.width-8)/2.5
        return CGSize.init(width: width, height: width)
    }
    
    
    @IBAction func btnViewSpotifyAction(_ sender: Any) {
        let url = URL.init(string: "spotify:")
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            
        }
    }
    
    @IBAction func btnViewAllEventsAction(_ sender: Any) {
        
    }
    
    @IBAction func btnUploadHashTagsAction(_ sender: Any) {
        
    }
    
    
    func uploadHashtagAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_Id":self.appPreference.getUserID(),
            "month":self.strMonthYear
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_UPLOADHASHTAG, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.communityData = WWMCommunityData.init(json: result["result"] as! [String : Any])
                self.tblViewCommunity.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    func getCommunityAPI() {
        WWMHelperClass.showSVHud()
        let param = [
                     "user_Id":self.appPreference.getUserID(),
                     "month":self.strMonthYear
                    ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMMUNITYDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.communityData = WWMCommunityData.init(json: result["result"] as! [String : Any])
                self.tblViewCommunity.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
}
