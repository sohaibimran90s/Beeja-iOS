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
    var emotionData = WWMGuidedEmotionData()
    var cat_Id = "0"
    var cat_Name = ""
    var type = ""
    @IBOutlet weak var audioCollectionView: UICollectionView!
    var arrAudioList = [WWMGuidedAudioData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBarForAudioGuided(title: self.type)
        self.lblEmotionTitle.text = emotionData.emotion_Name
        self.getAudioListAPI()
        // Do any additional setup after loading the view.
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
        vc.audioData = self.arrAudioList[indexPath.row]
        vc.cat_id = self.cat_Id
        vc.cat_Name = self.cat_Name
        vc.emotion_Id = "\(self.emotionData.emotion_Id)"
        vc.emotion_Name = self.emotionData.emotion_Name
        self.navigationController?.pushViewController(vc, animated: true)
        
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
        WWMHelperClass.showSVHud()
        
        let param = ["emotion_id":emotionData.emotion_Id,
                     "user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDAudio, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    if let audioList = result["result"] as? [[String:Any]] {
                        for data in audioList {
                            let audioData = WWMGuidedAudioData.init(json: data)
                            self.arrAudioList.append(audioData)
                        }
                        self.audioCollectionView.reloadData()
                    }
                    
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as! String, title: kAlertTitle)
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
            WWMHelperClass.dismissSVHud()
        }
    }
}
