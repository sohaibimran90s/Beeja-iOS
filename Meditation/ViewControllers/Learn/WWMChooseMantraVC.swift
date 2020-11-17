//
//  WWMChooseMantraVC.swift
//  Meditation
//
//  Created by Prema Negi on 15/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMChooseMantraVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnMantra: UIButton!
    var value: String = ""
    let reachable = Reachabilities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar(isShow: false, title: "")
        WWMHelperClass.value = self.value
        self.setupView()
    }
    
    func setupView(){
        
        if value == "mantra"{
            self.btnSkip.setBackgroundImage(UIImage(named: "Close_Icon"), for: .normal)
            btnSkip.setTitle("", for: .normal)
        }else{
            let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
            
            let attributeString = NSMutableAttributedString(string: KSKIP,
                                                            attributes: attributes)
            btnSkip.setAttributedTitle(attributeString, for: .normal)
        }
        
        self.btnMantra.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func btnMantraClicked(_ sender: UIButton) {
        
        if reachable.isConnectedToNetwork() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMListenMantraVC") as! WWMListenMantraVC
            vc.value = self.value
            self.navigationController?.pushViewController(vc, animated: true)
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {

        if value == "mantra"{
            self.navigationController?.popViewController(animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnLetsMeditateVC") as! WWMLearnLetsMeditateVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
