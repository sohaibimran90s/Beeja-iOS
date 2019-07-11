//
//  WWMHomeTabVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMHomeTabVC: WWMBaseViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartedText: UILabel!
    @IBOutlet weak var lblNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblStartedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblIntroText: UILabel!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var lblIntroTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgPlayIconTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.lblName.alpha = 0
        self.lblStartedText.alpha = 0
        self.lblIntroText.alpha = 0
        self.imgPlayIcon.alpha = 0
        
        self.animatedlblName()
    }
    
    func animatedlblName(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblName.alpha = 1
            //self.lblName.center.y = self.lblName.center.y - 70
            self.lblNameTopConstraint.constant =  self.lblNameTopConstraint.constant - 10
        
        }, completion: { _ in
            //self.animatedViewJournal()
        })
    }
    
    
    //  func animatedStartedText(){
    //      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
    //          self.journalView.lblEntryText.alpha = 1
    //          self.journalView.lblEntryText.center.y = self.journalView.lblEntryText.center.y - 70
    //      }, completion: { _ in
    //          self.animatedViewJournal()
    //      })
    //  }

    
//
//    func animatedIntroText(){
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
//            self.journalView.viewJournal.alpha = 1
//            self.journalView.viewJournal.center.y = self.journalView.viewJournal.center.y - 50
//            self.journalView.lblTextCount.alpha = 1
//            self.journalView.lblTextCount.center.y = self.journalView.lblTextCount.center.y - 50
//        }, completion: { _ in
//            self.animatedBtnSubmit()
//        })
//
//    }
//
//    func animatedimgPlayIcon(){
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
//            self.journalView.btnSubmit.alpha = 1
//            self.journalView.btnSubmit.center.y = self.journalView.btnSubmit.center.y - 50
//        }, completion: nil)
//    }
}
