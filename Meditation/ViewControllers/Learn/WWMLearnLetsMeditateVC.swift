//
//  WWMLearnLetsMeditateVC.swift
//  Meditation
//
//  Created by Prema Negi on 15/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnLetsMeditateVC: WWMBaseViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblLetsMeditate: UILabel!
    
    var settingData = DBSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userName.alpha = 0
        self.lblLetsMeditate.alpha = 0
        self.setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.userName.alpha = 0
        self.lblLetsMeditate.alpha = 0
        
        self.userName.center.y = self.userName.center.y + 50
        self.lblLetsMeditate.center.y = self.lblLetsMeditate.center.y + 30
    }
    
    func setupView(){
        
        let userName: String = self.appPreference.getUserName()
        if userName != ""{
            if userName.contains(" "){
                let userNameArr = userName.components(separatedBy: " ")
                self.userName.text = "\(KOK) \(userNameArr[0]),"
            }else{
                self.userName.text = "\(KOK) \(self.appPreference.getUserName()),"
            }
        }else{
            self.userName.text = KOKYOU
        }
        
        self.animateUserName()
    }
    
    //MARK: animated Views
    func animateUserName(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.userName.alpha = 1.0
            self.userName.center.y = self.userName.center.y - 50
            }, completion: { _ in
            self.animatedlblName()
        })
    }
    
    func animatedlblName(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblLetsMeditate.alpha = 1
            self.lblLetsMeditate.center.y = self.lblLetsMeditate.center.y - 30
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnTimerVC") as! WWMLearnTimerVC
                self.navigationController?.pushViewController(vc, animated: false)
            })
        })
    }
}
