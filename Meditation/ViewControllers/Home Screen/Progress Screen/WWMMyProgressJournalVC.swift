//
//  WWMMyProgressJournalVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressJournalVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableViewJournal: UITableView!
    
    var addJournalView = WWMAddJournalVC()
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = WWMHelperClass.fetchDB(dbName: "DBMeditationComplete") as! [DBMeditationComplete]
        getJournalList()
       // print(data[0].meditationData!)
        // Do any additional setup after loading the view.
    }
    
    // MARK:- UITableView Delegates Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WWMJournalTableViewCell {
            cell.viewShadow.layer.shadowColor = UIColor.black.cgColor
            cell.viewShadow.layer.shadowOpacity = 0.3
            cell.viewShadow.layer.shadowRadius = 5.0
            cell.viewShadow.layer.cornerRadius = 5.0
            cell.viewShadow.layer.masksToBounds = false
            
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Roshan")
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func getJournalList() {
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_JOURNALMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                print(result)
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
        }
    }

    @IBAction func btnAddJournalAction(_ sender: Any) {
        
        self.addJournalView = self.storyboard?.instantiateViewController(withIdentifier: "WWMAddJournalVC") as! WWMAddJournalVC
        
        UIApplication.shared.keyWindow?.rootViewController!.present(self.addJournalView, animated: true,completion: nil)
       // addJournalView.btnClose.addTarget(self, action: #selector(btnCloseAction(_:)), for: .touchUpInside)
       // addJournalView.btnSubmit.addTarget(self, action: #selector(btnSubmitJournalAction(_:)), for: .touchUpInside)
       // addJournalView.view.frame = (UIApplication.shared.keyWindow?.rootViewController?.view.bounds)!
        //UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(addJournalView.view)
    }
    
    
}
