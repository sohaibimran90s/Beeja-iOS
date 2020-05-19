//
//  WWMPlayListVC.swift
//  Meditation
//
//  Created by Prema Negi on 19/05/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WWMPlayListVC: WWMBaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLearn: UIButton!
    @IBOutlet weak var btnGuided: UIButton!

    var itemInfo: IndicatorInfo = "View"
    var type = ""
    var subType = ""
    var guidedData = WWMGuidedData()
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnLearn.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnLearn.layer.borderWidth = 1.0
        self.btnLearn.layer.cornerRadius = 20
        
        self.btnGuided.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnGuided.layer.borderWidth = 1.0
        self.btnGuided.layer.cornerRadius = 20
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @IBAction func btnLearnClicked(_ sender: UIButton){
        
    }
    
    @IBAction func btnGuidedClicked(_ sender: UIButton){
        
    }
}

extension WWMPlayListVC: UITableViewDelegate, UITableViewDataSource{
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
            
            vc.vcType = "WWMPlayListVC"
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
