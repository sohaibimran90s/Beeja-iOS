//
//  WWMGuidedAudioListVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import CoreData

class WWMGuidedAudioListVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lblEmotionTitle: UILabel!
    @IBOutlet weak var audioCollectionView: UICollectionView!

    var emotionData = WWMGuidedEmotionData()
    var cat_Id = "0"
    var cat_Name = ""
    var type = ""
    var arrAudioList = [WWMGuidedAudioData]()
    var alertPopupView1 = WWMAlertController()
    let appPreffrence = WWMAppPreference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBarForAudioGuided(title: self.type)
        self.lblEmotionTitle.text = emotionData.emotion_Name
        
        self.fetchGuidedAudioDataFromDB()
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
        
        print("data.paid... \(data.paid)")
        print("data.audio_Duration... \(data.audio_Duration)")
        
        if self.appPreffrence.getExpiryDate(){
            cell.lblFreeDuration.text = ""
        }else{
            if !data.paid{
                if data.audio_Duration > 900{
                    cell.lblFreeDuration.text = KFREEAUDIO
                }else{
                    cell.lblFreeDuration.text = ""
                }
            }else{
                cell.lblFreeDuration.text = ""
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.arrAudioList[indexPath.row]
        
//        if data.paid{
//            self.getFreeMoodMeterAlert(title: KSUBSPLANEXP, subTitle: KSUBSPLANEXPDES)
//            self.view.isUserInteractionEnabled = false
//        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
            
            vc.audioData = self.arrAudioList[indexPath.row]
            vc.cat_id = self.cat_Id
            vc.cat_Name = self.cat_Name
            vc.emotion_Id = "\(self.emotionData.emotion_Id)"
            vc.emotion_Name = self.emotionData.emotion_Name
            
            
            if self.appPreffrence.getExpiryDate(){
                vc.seconds = data.audio_Duration
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                if !data.paid{
                    if data.audio_Duration > 900{
                        vc.seconds = 900
                    }else{
                        vc.seconds = data.audio_Duration
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.getFreeMoodMeterAlert(title: KSUBSPLANEXP, subTitle: KSUBSPLANEXPDES)
                    self.view.isUserInteractionEnabled = false
                }
            }

        
        //}
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
    
    //MARK: Fetch Guided Audio Data From DB
    
    func fetchGuidedAudioDataFromDB() {
        
        let guidedAudioDataDB = self.fetchGuidedAudioFilterDB(emotion_id: "\(emotionData.emotion_Id)", dbName: "DBGuidedAudioData")
        if guidedAudioDataDB.count > 0{
            print("guidedAudioDataDB count... \(guidedAudioDataDB.count)")
            
            self.arrAudioList.removeAll()
            
            var jsonString: [String: Any] = [:]
            for dict in guidedAudioDataDB {
                
                jsonString["id"] = Int((dict as AnyObject).audio_id ?? "0")
                jsonString["duration"] = Int((dict as AnyObject).duration ?? "0")
                jsonString["audio_name"] = (dict as AnyObject).audio_name as? String
                jsonString["audio_image"] = (dict as AnyObject).audio_image as? String
                jsonString["audio_url"] = (dict as AnyObject).audio_url as? String
                jsonString["author_name"] = (dict as AnyObject).author_name as? String
                jsonString["vote"] = (dict as AnyObject).vote
                jsonString["paid"] = (dict as AnyObject).paid
                
                let audioData = WWMGuidedAudioData.init(json: jsonString)
                self.arrAudioList.append(audioData)
            }
            
            self.audioCollectionView.reloadData()
            
        }
    }
    
    func fetchGuidedAudioFilterDB(emotion_id: String, dbName: String) -> [Any]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: dbName)
        fetchRequest.predicate = NSPredicate.init(format: "emotion_id == %@", emotion_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let param = try? appDelegate.managedObjectContext.fetch(fetchRequest)
        print("No of Object in database : \(param!.count)")
        return param!

    }
}
