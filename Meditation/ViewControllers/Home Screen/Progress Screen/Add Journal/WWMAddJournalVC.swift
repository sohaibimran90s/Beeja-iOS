//
//  WWMAddJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/02/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMAddJournalVC: WWMBaseViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var txtViewJournal: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }

    func setupView(){
        self.setNavigationBar(isShow: false, title: "")
        self.btnSubmit.layer.borderWidth = 2.0
        self.btnSubmit.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSubmitJournalAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnEditTextAction(_ sender: Any) {
        self.txtViewJournal.isEditable = true
        self.txtViewJournal.becomeFirstResponder()
    }
    
}
