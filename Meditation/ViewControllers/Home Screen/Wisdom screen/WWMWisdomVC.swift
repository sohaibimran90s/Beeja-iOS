//
//  WWMWisdomVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import AVKit

class WWMWisdomVC: WWMBaseViewController,IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var itemInfo: IndicatorInfo = "View"
    var wisdomData = WWMWisdomData()
    var playerViewController = WWMVedioPlayerVC()
    var video_id: String = ""
    var videoURL: String = ""
    var videoTitle: String = ""
    let gradient = CAGradientLayer()
    var btnFavourite = UIButton()
    var isFavourite = false
    var rating = 0

    let reachable = Reachabilities()
    
    var wisdomData1 = [WWMWisdomVideoData]()
    
    //MARK:- Viewcontroller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 87.0/255.0, green: 50.0/255.0, blue: 163.0/255.0, alpha: 1.0).cgColor, UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0).cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        self.setFirstObjectIntroVideo()
    }
    
    func setFirstObjectIntroVideo(){
        self.wisdomData1.removeAll()
        for i in 0..<self.wisdomData.cat_VideoList.count{
            print(self.wisdomData.cat_VideoList[i].is_intro)
            if "\(self.wisdomData.cat_VideoList[i].is_intro)" == "1"{
                self.wisdomData1.append(self.wisdomData.cat_VideoList[i])
            }
        }
        
        for i in 0..<self.wisdomData.cat_VideoList.count{
            print(self.wisdomData.cat_VideoList[i].is_intro)
            if "\(self.wisdomData.cat_VideoList[i].is_intro)" == "0"{
                self.wisdomData1.append(self.wisdomData.cat_VideoList[i])
            }
        }
    }

    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {

        return itemInfo
    }
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wisdomData1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMCommunityCollectionViewCell
        let data = self.wisdomData1[indexPath.row]
        
        if indexPath.item == 0 {
            cell.contraintImageHeight.constant = 200
        } else {
            cell.contraintImageHeight.constant = 140
        }
        
        cell.imgView.sd_setImage(with: URL.init(string: data.video_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.video_Name
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if reachable.isConnectedToNetwork() {
            let data = self.wisdomData1[indexPath.row]
            self.video_id = String(data.video_Id)
            self.videoURL = data.video_Url
            self.videoTitle = data.video_Name
            let videoURL = URL(string: data.video_Url)
            let player = AVPlayer(url: videoURL!)
            playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "WWMVedioPlayerVC") as! WWMVedioPlayerVC
            playerViewController.vote = data.vote
            playerViewController.video_id = self.video_id
            playerViewController.cat_Id = "\(self.wisdomData.cat_Id)"
            playerViewController.video_Name = self.videoTitle
            playerViewController.player = player

             btnFavourite = UIButton.init(frame: CGRect.init(x: (self.view.frame.size.width/2)-50, y: 24, width: 48, height: 44))
            btnFavourite.layer.cornerRadius = 10
            btnFavourite.clipsToBounds = true
            btnFavourite.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 0.50)
            btnFavourite.contentMode = .scaleAspectFit
            btnFavourite.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
            btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
            if data.vote {
                self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
                self.isFavourite = true
                self.rating = 1
            }
            btnFavourite.isUserInteractionEnabled = true
            btnFavourite.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
            playerViewController.showsPlaybackControls = true
            self.playerViewController.videoGravity = .resizeAspect
            self.playerViewController.player!.play()
            
            self.playerViewController.exitsFullScreenWhenPlaybackEnds = true
            self.navigationController?.pushViewController(playerViewController, animated: true)
            
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    @objc func buttonTapped() {
        if !isFavourite {
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }else {
            isFavourite = false
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
            self.rating = 0
        }
    }
    @objc func onCustomTap(sender: UITapGestureRecognizer) {
        
        if btnFavourite.alpha > 0{
            UIView.animate(withDuration: 0.25, animations: {
               // self.btnFavourite.alpha = 0;
               //  self.playerViewController.showsPlaybackControls = false
            })
            
        } else {
            UIView.animate(withDuration: 0.25, animations: {
              //  self.btnFavourite.alpha = 1;
              //  self.playerViewController.showsPlaybackControls = true
            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?){
        
        if self.playerViewController.view.frame.origin.y > 0.0  {
            self.playerViewController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
            
            //print(self.playerViewController.player?.currentTime().seconds ?? 0)
            let watchDuration = self.playerViewController.player?.currentTime().seconds ?? 0
            let param = [
                "user_id": self.appPreference.getUserID(),
                "category_id": "\(self.wisdomData.cat_Id)",
                "video_id": self.video_id,
                "watched_duration": Int(watchDuration),
                "rating" : self.rating
                ] as [String : Any]
            
            print(param)
            self.wisdomFeedback(param: param as Dictionary<String, Any>)
        }else {
            //print("Prachi")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = self.wisdomData1[indexPath.row]
        
        if data.is_intro == "0" {
            let width = (self.view.frame.size.width-26)/2
            return CGSize.init(width: width, height: width + 60)
        }else {
            let width = (self.view.frame.size.width-16)
            let height = ((self.view.frame.size.width-26)/2) + 94
            return CGSize.init(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            return headerView
            
        }
        let footerView =
            collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)

        return footerView
        
    }
    
    func wisdomFeedback(param: [String: Any]) {
        //WWMHelperClass.showSVHud()
        //WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_WISHDOMFEEDBACK, context: "WWMWisdomVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.navigationController?.popToRootViewController(animated: true)
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                }
            }
        }
    }
}

extension WWMWisdomVC: WWMWisdomFeedbackDelegate{
    func refreshView() {
    }
    
    func videoURl(url: String) {
        print(url)
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            self.playerViewController.player!.play()
            
            self.playerViewController.player = player
            self.playerViewController.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
        }
    }
}


