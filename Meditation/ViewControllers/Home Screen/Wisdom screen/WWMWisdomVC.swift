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
        self.present(playerViewController, animated: true) {
            self.playerViewController.player!.play()
            
            self.playerViewController.exitsFullScreenWhenPlaybackEnds = true
            self.playerViewController.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?){
        
        if self.playerViewController.view.frame.origin.y > 0.0  {
            self.playerViewController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
            
            print(self.playerViewController.player?.currentTime().seconds ?? 0)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomFeedbackVC") as! WWMWisdomFeedbackVC
            
            vc.completionTimeVideo = self.playerViewController.player?.currentTime().seconds ?? 0
            vc.cat_id = String(self.wisdomData.cat_Id)
            vc.video_id = self.video_id
            vc.videoURL = self.videoURL
            vc.delegate = self
            vc.flowType = "\(self.wisdomData.cat_Name) ~ \(self.videoTitle)"
            vc.meditationType = "Wisdom Meditation"
            self.navigationController?.pushViewController(vc, animated: true)
            
            //Double(String(format: "%.2f", self.playerViewController.player?.currentTime().seconds ?? 0.0)) ?? 0.0
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
        self.present(playerViewController, animated: false) {
            self.playerViewController.player!.play()
            
            self.playerViewController.player = player
            self.playerViewController.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
        }
    }
}
