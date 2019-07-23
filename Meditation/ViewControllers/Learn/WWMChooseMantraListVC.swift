//
//  WWMChooseMantraListVC.swift
//  Meditation
//
//  Created by Prema Negi on 17/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

protocol WWMChooseMantraListDelegate {
    func chooseAudio(audio: String)
}

class WWMChooseMantraListVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    var mantraData: [WWMMantraData] = []
    
    var delegate: WWMChooseMantraListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        getMantrasAPI()
    }
    
    //MARK: API call
    func getMantrasAPI() {
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_MANTRAS, headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [[String: Any]]{
                    for json in data{
                        let mantraData = WWMMantraData.init(json: json)
                        self.mantraData.append(mantraData)
                    }
                    
                    self.tableView.reloadData()
                }
                
                print("mantras.... \(result)")
                
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}

extension WWMChooseMantraListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mantraData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMChooseMantraListTVC") as! WWMChooseMantraListTVC
        
        cell.lblStepDescription.text = self.mantraData[indexPath.row].Description
        cell.lblTitle.text = self.mantraData[indexPath.row].title
        
        if selectedIndex == indexPath.row{
            cell.lblStepDescription.isHidden = false
            cell.btnProceed.isHidden = false
            cell.imgArraow.image = UIImage(named: "upArrow")
        
        }else{
            cell.lblStepDescription.isHidden = true
            cell.btnProceed.isHidden = true
            cell.imgArraow.image = UIImage(named: "downArrow")
        }
        
        cell.btnPlayMantra.addTarget(self, action: #selector(btnPlayMantraClicked), for: .touchUpInside)
        cell.btnPlayMantra.tag = indexPath.row
        
        cell.btnProceed.addTarget(self, action: #selector(btnProceedClicked), for: .touchUpInside)
        cell.btnProceed.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row{
            return UITableView.automaticDimension
        }else{
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    @objc func btnPlayMantraClicked(_ sender: UIButton){
        delegate?.chooseAudio(audio: self.mantraData[sender.tag].mantra_audio)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnProceedClicked(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnLetsMeditateVC") as! WWMLearnLetsMeditateVC
        
        WWMHelperClass.mantra_id = self.mantraData[sender.tag].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
