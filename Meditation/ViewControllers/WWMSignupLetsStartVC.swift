//
//  WWMSignupLetsStartVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSignupLetsStartVC: WWMBaseViewController {

    
    @IBOutlet weak var btnKnowMeditation: UIButton!
    @IBOutlet weak var btnGuide: UIButton!
    @IBOutlet weak var btnLearn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        self.btnGuide.layer.borderWidth = 2.0
        self.btnGuide.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnLearn.layer.borderWidth = 2.0
        self.btnLearn.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnKnowMeditation.layer.borderWidth = 2.0
        self.btnKnowMeditation.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }

    @IBAction func btnKnowMeditationAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMeditationListVC") as! WWMMeditationListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnGuideAction(_ sender: UIButton) {
        
    }
    @IBAction func btnLearnAction(_ sender: UIButton) {
        
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
