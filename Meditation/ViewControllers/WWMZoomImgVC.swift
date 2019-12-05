//
//  WWMZoomImgVC.swift
//  Meditation
//
//  Created by Prema Negi on 05/12/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMZoomImgVC: WWMBaseViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var imgURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        self.imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton){
        self.dismiss(animated: false, completion: nil)
        //self.navigationController?.popViewController(animated: false)
    }
    
}
