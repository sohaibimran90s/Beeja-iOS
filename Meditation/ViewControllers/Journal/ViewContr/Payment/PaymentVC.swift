//
//  PaymentVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 12/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {

    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var annualView: UIView!
    @IBOutlet weak var lifetimeView: UIView!

    @IBOutlet weak var updateNowBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        view.insetsLayoutMarginsFromSafeArea = false

        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = UIColor.clear.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
        self.updateNowBtn.layer.borderColor = Constant.Light_Green.cgColor
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func monthlyAction(sender: UIButton) {
        self.monthlyView.layer.borderColor = Constant.Light_Green.cgColor
        self.annualView.layer.borderColor = UIColor.clear.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
    }

    @IBAction func anualAction(sender: UIButton) {
        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = Constant.Light_Green.cgColor
        self.lifetimeView.layer.borderColor = UIColor.clear.cgColor
    }

    @IBAction func lifetimeAction(sender: UIButton) {
        self.monthlyView.layer.borderColor = UIColor.clear.cgColor
        self.annualView.layer.borderColor = UIColor.clear.cgColor
        self.lifetimeView.layer.borderColor = Constant.Light_Green.cgColor
    }



}
