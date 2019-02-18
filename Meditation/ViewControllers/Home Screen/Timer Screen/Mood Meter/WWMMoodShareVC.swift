//
//  WWMMoodShareVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 18/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodShareVC: UIViewController {

    @IBOutlet weak var btnShare: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        self.btnShare.layer.borderWidth = 2.0
        self.btnShare.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }

    // MARK:- Button Action
    
    @IBAction func btnSendToFriendAction(_ sender: Any) {
        
        if !self.btnShare.isSelected {
            // image to share
            let img = UIImage.init(named: "vibe_images.jpg")
            let url = URL.init(string: "https://itunes.apple.com/gb/app/meditation-timer/id1185954064?mt=8")
            let imageToShare = [img!, url!] as [Any]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            self.btnShare.isSelected = true
            self.btnShare.setTitle("Done", for: .normal)
        }else {
            self.navigationController?.isNavigationBarHidden = false
            
            if let tabController = self.tabBarController as? WWMTabBarVC {
                tabController.selectedIndex = 4
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
