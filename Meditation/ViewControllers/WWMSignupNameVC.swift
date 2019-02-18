//
//  WWMSignupNameVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSignupNameVC: WWMBaseViewController,UITextFieldDelegate{

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtViewName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    

    func setupView(){
        self.setNavigationBar(isShow: false, title: "")
        self.btnNext.layer.borderWidth = 2.0
        self.btnNext.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    //MARK:- UITextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        let strRegEx = "[A-Z a-z]"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", strRegEx)
        if !emailTest.evaluate(with: string) {
            return false
        }
        if  textField == txtViewName {
            
            let str = txtViewName.text! + string
            if str.count > 50 {
                return false
            }
        }
        return true
    }
    
    
    // MARK: - UIButton Action
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        if self.txtViewName.text == "" {
            vc.name = "You"
        }else {
            vc.name = self.txtViewName.text!
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
