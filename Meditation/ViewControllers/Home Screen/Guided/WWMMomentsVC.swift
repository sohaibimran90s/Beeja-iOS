//
//  WWMMomentsVC.swift
//  Meditation
//
//  Created by Prema Negi on 22/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMMomentsVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnMantra: UIButton!

    let reachable = Reachabilities()
    var itemInfo: IndicatorInfo = "View"
    var type = ""
    var subType = ""
    var guidedData = WWMGuidedData()
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    var arrOfGuidedEmotionData = [WWMGuidedEmotionData]()
    var arrToCheckSection: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(type)
        self.btnMantra.layer.cornerRadius = 20
        self.btnMantra.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnMantra.layer.borderWidth = 1.0
        
        self.storingDataForTableView()
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func storingDataForTableView(){
        arrOfGuidedEmotionData.removeAll()
        arrToCheckSection.removeAll()
        
        if self.guidedData.cat_EmotionList.count > 0{
            var name = ""
            for i in 0..<self.guidedData.cat_EmotionList.count{
                var flag = 0
                
                if arrOfGuidedEmotionData.count > 0{
                    
                    for j in 0..<arrOfGuidedEmotionData.count{
                        if self.guidedData.cat_EmotionList[i].emotion_type == arrOfGuidedEmotionData[j].emotion_type{
                            flag = 1
                        }
                    }
                }
                
                if flag == 0{
                    name = self.guidedData.cat_EmotionList[i].emotion_type
                    print("name.... \(name)")
                    self.arrToCheckSection.append("0")
                    arrOfGuidedEmotionData.append(self.guidedData.cat_EmotionList[i])
                    for i in 0..<self.guidedData.cat_EmotionList.count{
                        if self.guidedData.cat_EmotionList[i].emotion_type == name{
                            arrOfGuidedEmotionData.append(self.guidedData.cat_EmotionList[i])
                            self.arrToCheckSection.append("1")
                        }
                    }
                    
                }
            }
            
            self.tableView.reloadData()
        }
        
        print("self.guidedData.cat_EmotionList.count \(self.guidedData.cat_EmotionList.count) arra.count \(arrOfGuidedEmotionData.count)")
    }
    
    
    @IBAction func btnMantraAction(_ sender: UIButton){
        if self.guidedData.cat_EmotionList.count > 0{
            let randomIndex = Int(arc4random_uniform(UInt32(self.guidedData.cat_EmotionList.count)))
            print(randomIndex)
            
            let data = self.guidedData.cat_EmotionList[randomIndex]
            let guidedAudioDataDB = WWMHelperClass.fetchGuidedAudioFilterDB(emotion_id: "\(data.emotion_Id)", dbName: "DBGuidedAudioData")
            
            if guidedAudioDataDB.count > 1{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepAudioVC") as! WWMSleepAudioVC
                vc.emotionData = data
                vc.subTitle = self.subType
                vc.cat_Id = "\(self.guidedData.cat_Id)"
                vc.cat_Name = self.guidedData.cat_Name
                vc.type = data.emotion_Name
                vc.imgURL = data.emotion_Image
                vc.min_limit = self.min_limit
                vc.max_limit = self.max_limit
                vc.meditation_key = self.meditation_key
                self.navigationController?.pushViewController(vc, animated: true)
            }else if guidedAudioDataDB.count == 1{
                self.fetchGuidedAudioDataFromDB(emotion_id: "\(data.emotion_Id)", emotion_name: "\(data.emotion_Name)", min_limit: self.guidedData.min_limit, max_limit: self.guidedData.max_limit, meditation_key: self.guidedData.meditation_key)
            }
        }
    }
}

extension WWMMomentsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfGuidedEmotionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMMomentsTVC") as! WWMMomentsTVC
        
        let data = self.arrOfGuidedEmotionData[indexPath.row]
        cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.emotion_Name
        cell.lblSectionTitle.text = data.emotion_type.capitalized
        
        print("emotion_type moments... \(data.emotion_type)")
        
        if self.arrToCheckSection[indexPath.row] == "0"{
            cell.viewBack.isHidden = true
            cell.viewSection.isHidden = false
        }else{
            cell.viewBack.isHidden = false
            cell.viewSection.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.arrOfGuidedEmotionData[indexPath.row]
        
        if self.arrToCheckSection[indexPath.row] == "0"{
            print("section of tableView")
        }else{
            let guidedAudioDataDB = WWMHelperClass.fetchGuidedAudioFilterDB(emotion_id: "\(data.emotion_Id)", dbName: "DBGuidedAudioData")
            
            if guidedAudioDataDB.count > 1{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSleepAudioVC") as! WWMSleepAudioVC
                vc.emotionData = data
                vc.subTitle = self.subType
                vc.cat_Id = "\(self.guidedData.cat_Id)"
                vc.cat_Name = self.guidedData.cat_Name
                vc.type = data.emotion_Name
                vc.imgURL = data.emotion_Image
                vc.min_limit = self.guidedData.min_limit
                vc.max_limit = self.guidedData.max_limit
                vc.meditation_key = self.guidedData.meditation_key
                self.navigationController?.pushViewController(vc, animated: true)
            }else if guidedAudioDataDB.count == 1{
                self.fetchGuidedAudioDataFromDB(emotion_id: "\(data.emotion_Id)", emotion_name: "\(data.emotion_Name)", min_limit: self.guidedData.min_limit, max_limit: self.guidedData.max_limit, meditation_key: self.guidedData.meditation_key)
            }
        }
    }
    
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func fetchGuidedAudioDataFromDB(emotion_id: String, emotion_name: String, min_limit: String, max_limit: String, meditation_key: String){
        
        print("emotion_id \(emotion_id) emotion_name \(emotion_name) min_limit \(min_limit) max_limit \(max_limit) meditation_key \(meditation_key)")
        
        let guidedAudioDataDB = WWMHelperClass.fetchGuidedAudioFilterDB(emotion_id: "\(emotion_id)", dbName: "DBGuidedAudioData")
        if guidedAudioDataDB.count == 1{
            print("guidedAudioDataDB count... \(guidedAudioDataDB.count)")
            
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
    
                if reachable.isConnectedToNetwork() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMGuidedMeditationTimerVC") as! WWMGuidedMeditationTimerVC
                    
                    vc.audioData = audioData
                    vc.cat_id = "\(self.guidedData.cat_Id)"
                    vc.cat_Name = self.guidedData.cat_Name
                    vc.emotion_Id = "\(emotion_id)"
                    vc.emotion_Name = emotion_name
                    vc.min_limit = self.min_limit
                    vc.max_limit = self.max_limit
                    vc.meditation_key = self.meditation_key
                    
                    vc.seconds = audioData.audio_Duration
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                }
            }
        }
    }
}
