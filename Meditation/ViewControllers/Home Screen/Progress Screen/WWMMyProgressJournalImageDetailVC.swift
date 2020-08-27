//
//  WWMMyProgressJournalImageDetailVC.swift
//  Meditation
//
//  Created by Prashant Tayal on 16/07/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressJournalImageDetailVC: WWMBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UILabel!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    @IBOutlet weak var tblImages: UITableView!
    
    var lblTitle: String = ""
    var lblDesc: String = ""
    var lblDateDay1: String = ""
    var lblDateMonth1: String = ""
    var lblWeekDayAndTime1: String = ""
    var arrImages = [WWMJournalMediaData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        
        self.lblMeditationType.text = self.lblTitle
        self.lblJournalDesc.text = self.lblDesc
        self.lblDateDay.text = self.lblDateDay1
        self.lblDateMonth.text = self.lblDateMonth1
        self.lblWeekDayAndTime.text = self.lblWeekDayAndTime1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMJournalImagesTableViewCell") as! WWMJournalImagesTableViewCell
        cell.imgJournal.sd_setImage(with: URL(string: arrImages[indexPath.row].name), placeholderImage: UIImage(named: "guidedPopUpBg"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        180.0
    }
}
