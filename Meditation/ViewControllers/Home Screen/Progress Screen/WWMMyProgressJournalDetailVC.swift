//
//  WWMMyProgressJournalDetailVC.swift
//  Meditation
//
//  Created by Prema Negi on 21/01/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressJournalDetailVC: WWMBaseViewController {

    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UITextView!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    
    var lblTitle: String = ""
    var lblDesc: String = ""
    var lblDateDay1: String = ""
    var lblDateMonth1: String = ""
    var lblWeekDayAndTime1: String = ""
    
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
}
