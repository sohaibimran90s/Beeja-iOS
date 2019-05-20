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
    let playerViewController = AVPlayerViewController()
    var video_id: String = ""
    var videoURL: String = ""
    var videoTitle: String = ""
    let gradient = CAGradientLayer()
    var btnFavourite = UIButton()
    var isFavourite = false
    var rating = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 87.0/255.0, green: 50.0/255.0, blue: 163.0/255.0, alpha: 1.0).cgColor, UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0).cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    

    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wisdomData.cat_VideoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMCommunityCollectionViewCell
        let data = self.wisdomData.cat_VideoList[indexPath.row]
        
        cell.imgView.sd_setImage(with: URL.init(string: data.video_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.video_Name
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.wisdomData.cat_VideoList[indexPath.row]
        self.video_id = String(self.wisdomData.cat_VideoList[indexPath.row].video_Id)
        self.videoURL = self.wisdomData.cat_VideoList[indexPath.row].video_Url
        self.videoTitle = self.wisdomData.cat_VideoList[indexPath.row].video_Name
        let videoURL = URL(string: data.video_Url)
        let player = AVPlayer(url: videoURL!)
        
        playerViewController.player = player

         btnFavourite = UIButton.init(frame: CGRect.init(x: (self.view.frame.size.width/2)-50, y: 24, width: 48, height: 44))
        btnFavourite.layer.cornerRadius = 10
        btnFavourite.clipsToBounds = true
        btnFavourite.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 0.25)
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
        
        playerViewController.view.addSubview(btnFavourite)
    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCustomTap(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.delegate = self
        playerViewController.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.playerViewController.videoGravity = .resizeAspectFill
        self.present(playerViewController, animated: true) {
            self.playerViewController.player!.play()
        
            self.playerViewController.exitsFullScreenWhenPlaybackEnds = true
            self.playerViewController.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
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
                self.btnFavourite.alpha = 0;
            })
            
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.btnFavourite.alpha = 1;
            })
        }
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?){
        
        if self.playerViewController.view.frame.origin.y > 0.0  {
            self.playerViewController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
            
            print(self.playerViewController.player?.currentTime().seconds ?? 0)
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
            print("Prachi")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-19)/2
        return CGSize.init(width: width, height: width)
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
        WWMHelperClass.showSVHud()
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_WISHDOMFEEDBACK, headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.navigationController?.popToRootViewController(animated: true)
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "", title: kAlertTitle)
                }
            }else{
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
}

extension WWMWisdomVC: WWMWisdomFeedbackDelegate{
    func refreshView() {
        print("")
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


extension WWMWisdomVC: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let _touchView = touch.view {
            
            let screenRect:CGRect = UIScreen.main.bounds
            let screenWidth :CGFloat = screenRect.size.width;
            let screenHeight:CGFloat  = screenRect.size.height;
            
            if _touchView.bounds.height == screenHeight && _touchView.bounds.width == screenWidth{
                return true
            }
            
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
