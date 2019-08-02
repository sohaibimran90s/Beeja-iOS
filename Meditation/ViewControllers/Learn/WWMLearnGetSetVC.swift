//
//  WWMLearnGetSetVC.swift
//  Meditation
//
//  Created by Prema Negi on 13/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnGetSetVC: WWMBaseViewController {

    @IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var lblGetComfy: UILabel!
    @IBOutlet weak var lblGetSet: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblGetComfy.alpha = 0
        self.lblGetSet.alpha = 0
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)
        
        self.animateLblGetComfy()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.lblGetComfy.alpha = 0
        self.lblGetSet.alpha = 0
        
        self.lblGetComfy.center.y = self.lblGetComfy.center.y + 50
        self.lblGetSet.center.y = self.lblGetSet.center.y + 30
    }
    
    
    //MARK: animated Views
    func animateLblGetComfy(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblGetComfy.alpha = 1.0
            self.lblGetComfy.center.y = self.lblGetComfy.center.y - 50
        }, completion: { _ in
            self.animatedLblGetSet()
        })
    }
    
    func animatedLblGetSet(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblGetSet.alpha = 1
            self.lblGetSet.center.y = self.lblGetSet.center.y - 30
        }, completion: { _ in
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnPlayPauseAudioVC") as! WWMLearnPlayPauseAudioVC
                self.navigationController?.pushViewController(vc, animated: true)
            //})
        })
    }
    
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnPlayPauseAudioVC") as! WWMLearnPlayPauseAudioVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
