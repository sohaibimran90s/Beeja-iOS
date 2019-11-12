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
    var selectedIndex = 0
    let arrStaticImages = ["atease","tranquil","upbeat"]
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var btnSkip: UIButton!
    
    var alertJournalPopup = WWMJouranlPopUp()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSKIP,
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.btnShare.layer.borderWidth = 2.0
        self.btnShare.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.fetchGetVibesDataFromDB(mood_id: "\(self.moodData.id)")
    }
    
    func xibJournalPopupCall(){
        alertJournalPopup = UINib(nibName: "WWMJouranlPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMJouranlPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertJournalPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertJournalPopup.lblTitle.text = KNICEONE
        alertJournalPopup.lblSubtitle.text = KMSGSHARED
        UIView.transition(with: alertJournalPopup, duration: 2.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertJournalPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertJournalPopup.removeFromSuperview()
                self.movetoDashboard()
                //self.getJournalList()
            }
        }
    }

    
    @IBAction func btnSkipAction(_ sender: Any) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "VIBES", itemId: "SKIPPED", itemName: "IOS")
        self.movetoDashboard()
    }
    
    func movetoDashboard() {
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 4
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 4 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    // MARK:- UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrImages.count == 0 {
           self.pageControl.numberOfPages = self.arrStaticImages.count
            return self.arrStaticImages.count
        }
        self.pageControl.numberOfPages = self.arrImages.count
        return self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if  let imgView = cell.viewWithTag(101) as? UIImageView{
            if self.arrImages.count == 0 {
                imgView.image = UIImage.init(named: self.arrStaticImages[indexPath.row])
            }else {
                let data = self.arrImages[indexPath.row]
                
                imgView.sd_setImage(with: URL.init(string: data), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            }
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
        
        return CGSize.init(width: self.imageCollectionView.frame.size.width, height: 300)
    }
    
    // MARK:- Button Action
    
    @IBAction func btnSendToFriendAction(_ sender: Any) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "VIBES", itemId: "EMOTION", itemName: "IOS")
            if self.arrImages.count == 0 {
                let image = UIImage.init(named: self.arrStaticImages[self.selectedIndex])
                let text = "Feeling \(self.moodData.name) with Beeja. Download the app here: http://itunes.com/apps/com.beejameditation.beeja"
                let imageToShare = [text,image!] as [Any]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.setValue("Feeling \(self.moodData.name) with Beeja", forKey: "subject")
                
                activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                    print(success ? "SUCCESS!" : "FAILURE")
                    
                    if success{
                        self.xibJournalPopupCall()
                    }
                }
                
                
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                self.present(activityViewController, animated: true, completion: nil)
            }else {
                if let url = URL.init(string: self.arrImages[self.selectedIndex]){
                    
                    self.downloadImageWithUrl(url: url)
                }
                //self.downloaded(url: url!)
                
            }
    }
    
    func downloadImageWithUrl(url: URL) {
        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestwithImageUrl(url: url) { (image, error, success) in
            if success {
                let text = "Feeling \(self.moodData.name) with Beeja. Download the app here: http://itunes.com/apps/com.beejameditation.beeja"
                let imageToShare = [text,image] as [Any]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.setValue("Feeling \(self.moodData.name) with Beeja", forKey: "subject")
                
                activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                    print(success ? "SUCCESS!" : "FAILURE")
                    if success{
                        self.xibJournalPopupCall()
                    }
                }
                
                DispatchQueue.main.async {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                        self.present(activityViewController, animated: true, completion: nil)
                    }else {
                    
                         activityViewController.popoverPresentationController?.sourceView = self.view 
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
                
            }
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func downloaded(url: URL) {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        URLSession.shared.dataTask(with: url) { data, response, error in
        
                if  let data = data, error == nil{
                if let image = UIImage(data: data) {
                    let text = "Feeling \(self.moodData.name) with Beeja. Download the app here: http://itunes.com/apps/com.beejameditation.beeja"
                    let imageToShare = [text,image] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.setValue("Feeling \(self.moodData.name) with Beeja", forKey: "subject")
                    
                    activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                        print(success ? "SUCCESS!" : "FAILURE")
                        if success{
                            self.xibJournalPopupCall()
                        }
                    }
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                        self.present(activityViewController, animated: true, completion: nil)
                    }else {
                        
                       self.present(activityViewController, animated: true, completion: nil)
                    }
                }else {
                    let image = UIImage.init(named: "AppIcon")
                    let text = "Feeling \(self.moodData.name) with Beeja. Download the app here: http://itunes.com/apps/com.beejameditation.beeja"
                    let imageToShare = [text,image!] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    activityViewController.setValue("Feeling \(self.moodData.name) with Beeja", forKey: "subject")
                    
                    activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                        print(success ? "SUCCESS!" : "FAILURE")
                        if success{
                            self.xibJournalPopupCall()
                        }
                    }
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                        self.present(activityViewController, animated: true, completion: nil)
                    }else {
                       self.present(activityViewController, animated: true, completion: nil)
                    }
                    }
            
            } else { return }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
            }.resume()
    }
    
    //MARK: fetch GetVibes Data From DB
    func fetchGetVibesDataFromDB(mood_id: String) {
        print("mood_id... \(mood_id)")
        let getVibesDataDB = WWMHelperClass.fetchDB(dbName: "DBGetVibesImages") as! [DBGetVibesImages]
        
        if getVibesDataDB.count > 0 {
            print("self.getVibesDataDB... \(getVibesDataDB.count)")
            self.arrImages.removeAll()
            for dict in getVibesDataDB {
                if dict.mood_id == mood_id{
                    self.arrImages.append(dict.images ?? "atease")
                }
            }
            print("self.arrImages... \(arrImages.count) \(arrImages)")
            self.imageCollectionView.reloadData()
        }else{
            self.imageCollectionView.reloadData()
        }
    }

}
