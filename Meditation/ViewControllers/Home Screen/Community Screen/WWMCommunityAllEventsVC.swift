//
//  WWMCommunityAllEventsVC.swift
//  Meditation
//
//  Created by Prema Negi on 10/04/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMCommunityAllEventsVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var arrAllEvent = [WWMCommunityEventsData]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
    }
    
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrAllEvent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! WWMCommunityCollectionViewCell
        let data = self.arrAllEvent[indexPath.row]
                
        cell.imgView.sd_setImage(with: URL.init(string: data.imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.eventTitle
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.arrAllEvent[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        
            vc.strUrl = data.url
            vc.strType = data.eventTitle
       
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-36)/2
        return CGSize.init(width: width, height: width)
    }
    

}
