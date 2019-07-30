//
//  WWMGuidedAudioListVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMGuidedAudioListVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lblEmotionTitle: UILabel!
    @IBOutlet weak var audioCollectionView: UICollectionView!

    var emotionData = WWMGuidedEmotionData()
    var cat_Id = "0"
    var cat_Name = ""
    var type = ""
    var arrAudioList = [WWMGuidedAudioData]()
    var alertPopupView1 = WWMAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBarForAudioGuided(title: self.type)
        self.lblEmotionTitle.text = emotionData.emotion_Name
        self.getAudioListAPI()
    }
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrAudioList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMCommunityCollectionViewCell
        let data = self.arrAudioList[indexPath.row]

        cell.imgView.sd_setImage(with: URL.init(string: data.audio_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.audio_Name
        cell.lblDuration.text = "(\(self.secondsToMinutesSeconds(second: data.audio_Duration)))"
        cell.lblAuthorName.text = data.author_name
        
        if !data.paid{
            if data.audio_Duration > 900{
                cell.lblFreeDuration.text = "(Free for 15:00 min)"
            }else{
                cell.lblFreeDuration.text = ""
            }
        }else{
            cell.lblFreeDuration.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.arrAudioList[indexPath.row]
        
        if data.paid{
            self.getFreeMoodMeterAlert(title: "Your subscription plan has expired.", subTitle: "Don't worry, we already have a new plan for you. Please purchase any subscription plan to listen this audio.")
            self.view.isUserInteractionEnabled = false
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
            
            vc.audioData = self.arrAudioList[indexPath.row]
            vc.cat_id = self.cat_Id
            vc.cat_Name = self.cat_Name
            vc.emotion_Id = "\(self.emotionData.emotion_Id)"
            vc.emotion_Name = self.emotionData.emotion_Name
            
            if data.audio_Duration > 900{
                vc.seconds = 900
            }else{
                vc.seconds = data.audio_Duration
            }
            self.navigationController?.pushViewController(vc, animated: true)

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
    
    func getFreeMoodMeterAlert(title: String, subTitle: String){
        self.alertPopupView1 = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
        let window = UIApplication.shared.keyWindow!
        
        self.alertPopupView1.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.alertPopupView1.lblTitle.numberOfLines = 0
        self.alertPopupView1.btnOK.layer.borderWidth = 2.0
        self.alertPopupView1.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        self.alertPopupView1.lblTitle.text = title
        self.alertPopupView1.lblSubtitle.text = subTitle
        self.alertPopupView1.btnClose.isHidden = true
        
        self.alertPopupView1.btnOK.addTarget(self, action: #selector(btnAlertDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertPopupView1)
    }
    
    @objc func btnAlertDoneAction(_ sender: Any){
        self.alertPopupView1.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        if second<60 {
            return "\(second) sec"
        }else {
            return String.init(format: "%d:%02d min", second/60,second%60)
        }
    }
    
    // MARK : API Calling
    
    func getAudioListAPI() {
        self.view.endEditing(true)

        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = ["emotion_id":emotionData.emotion_Id,
                     "user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDAudio, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    if let audioList = result["result"] as? [[String:Any]] {
                        
                        print("audioList... \(audioList)")
                        
                        for data in audioList {
                            let audioData = WWMGuidedAudioData.init(json: data)
                            self.arrAudioList.append(audioData)
                        }
                        self.audioCollectionView.reloadData()
                    }
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
                }
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }

            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}
