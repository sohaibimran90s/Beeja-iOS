//
//  WWMCommunityAllHashTagsVC.swift
//  Meditation
//
//  Created by Prema Negi on 10/04/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMCommunityAllHashTagsVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var arrAllHashTag = [WWMCommunityHashtagsData]()
    
    var titleMAW: String = ""
    
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
        return self.arrAllHashTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
        let data = self.arrAllHashTag[indexPath.row]
        
        cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-36)/2
        return CGSize.init(width: width, height: width)
    }
    
}
