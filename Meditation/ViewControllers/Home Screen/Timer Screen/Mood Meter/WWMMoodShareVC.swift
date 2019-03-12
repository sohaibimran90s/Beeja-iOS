//
//  WWMMoodShareVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import SDWebImage

class WWMMoodShareVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    

    var moodData = WWMMoodMeterData()
    var arrImages = [String]()
    var isselected = false
    var selectedIndex = 0
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        self.btnShare.layer.borderWidth = 2.0
        self.btnShare.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.getVibesAPI()
    }

    
    // MARK:- UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = self.arrImages.count
        return self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if  let imgView = cell.viewWithTag(101) as? UIImageView{
            let data = self.arrImages[indexPath.row]
            
            imgView.sd_setImage(with: URL.init(string: data), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
        self.selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: 300, height: 300)
    }

    
    
    
    
    
    
    
    
    
    // MARK:- Button Action
    
    @IBAction func btnSendToFriendAction(_ sender: Any) {
        
        if !isselected {
            // image to share
            self.btnShare.setTitle("Done", for: .normal)
            isselected = true
            let url = URL.init(string: self.arrImages[self.selectedIndex])
            self.downloaded(url: url!)
//            let img = UIImage.init(named: "vibe_images.jpg")
//            let url = URL.init(string: "https://itunes.apple.com/gb/app/meditation-timer/id1185954064?mt=8")
//            let imageToShare = [img!, url!] as [Any]
//            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//            self.btnShare.setTitle("Done", for: .normal)
//            isselected = true
//            self.present(activityViewController, animated: true, completion: nil)
            
        }else {
            self.navigationController?.isNavigationBarHidden = false
            
            if let tabController = self.tabBarController as? WWMTabBarVC {
                tabController.selectedIndex = 4
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    func downloaded(url: URL) {
        WWMHelperClass.showSVHud()
        URLSession.shared.dataTask(with: url) { data, response, error in
        
                if  let data = data, error == nil{
                if let image = UIImage(data: data) {
                    let imageToShare = [image] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                    
                    self.present(activityViewController, animated: true, completion: nil)
                }else {
                    let image = UIImage.init(named: "AppIcon")
                    let imageToShare = [image!] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                    
                    self.present(activityViewController, animated: true, completion: nil)
                    }
            
            } else { return }
            WWMHelperClass.dismissSVHud()
            }.resume()
    }
    
    func getVibesAPI() {
        WWMHelperClass.showSVHud()
        let param = [
                "mood_id":self.moodData.id
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETVIBESIMAGES, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.arrImages.removeAll()
                    self.arrImages = result["result"] as! [String]
                }
                self.imageCollectionView.reloadData()
                
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }

}
