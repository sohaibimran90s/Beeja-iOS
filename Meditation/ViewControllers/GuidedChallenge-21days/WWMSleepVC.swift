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
    var guidedData = WWMGuidedData()
    var type = ""
    var min_limit = "94"
    var max_limit = "97"
    var meditation_key = "practical"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}