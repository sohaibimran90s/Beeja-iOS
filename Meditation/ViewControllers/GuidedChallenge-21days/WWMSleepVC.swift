//
//  WWMSleepVC.swift
//  Meditation
//
//  Created by Prema Negi on 08/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMSleepVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnMantra: UIButton!
    
    var itemInfo: IndicatorInfo = "View"
    var type = ""
    var subType = ""
    var guidedData = WWMGuidedData()
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(type)
        self.btnMantra.layer.cornerRadius = 20
        self.btnMantra.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnMantra.layer.borderWidth = 1.0
    }
    
    @IBAction func btnMantraAction(_ sender: UIButton){
        if self.guidedData.cat_EmotionList.count > 0{
            let randomIndex = Int(arc4random_uniform(UInt32(self.guidedData.cat_EmotionList.count)))
            print(randomIndex)
            
            let data = self.guidedData.cat_EmotionList[randomIndex]
            
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
        }
    }

    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension WWMSleepVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guidedData.cat_EmotionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMSleepTVC") as! WWMSleepTVC
        
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        cell.imgView.sd_setImage(with: URL.init(string: data.emotion_Image), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
        cell.lblTitle.text = data.emotion_Name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.guidedData.cat_EmotionList[indexPath.row]
        
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
    }
    
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
