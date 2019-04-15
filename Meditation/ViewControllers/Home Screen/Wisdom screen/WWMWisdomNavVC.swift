//
//  WWMWisdomNavVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 15/04/2019.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMWisdomNavVC: WWMBaseViewController {

    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBarForDashboard(title: "Wisdom")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWisdomDashboardVC") as! WWMWisdomDashboardVC
        self.addChild(vc)
        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview((vc.view)!)
        vc.didMove(toParent: self)
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
