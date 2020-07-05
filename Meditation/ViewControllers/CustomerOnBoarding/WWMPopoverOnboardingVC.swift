//
//  WWMPopoverOnboardingVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMPopoverOnboardingVC: WWMBaseViewController {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var popoverBoardTable: UITableView!
    @IBOutlet weak var yPosTableConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableBottmConstraints: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: UIButton!
    //@IBOutlet weak var challengeImgView: UIImageView!

    var dataObj = GetData()
    var optionList: [OptionsData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 0/255, green: 18/255, blue: 82/255, alpha: 1.0)
        popoverBoardTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.optionList = self.dataObj.options ?? []
        
        self.nameLbl.text = self.dataObj.name
        self.titleLbl.text = self.dataObj.title
        
        self.setTableHeight()
    }
    
    func setTableHeight() {
        
        let titleLblBottomPos = self.titleLbl.frame.size.height + self.titleLbl.frame.origin.y
        let tableBottomPos = self.popoverBoardTable.frame.size.height + self.popoverBoardTable.frame.origin.y

        let disBWTableBtmAndTitleLblBtm = Int(tableBottomPos - titleLblBottomPos)
        let tableReqH = 75 * self.optionList.count  // 75 is each cell height + top/bottom gap
        let diff = disBWTableBtmAndTitleLblBtm - tableReqH
        
        if (diff > 0) {
            self.tableHeightConstraints.constant = CGFloat(tableReqH)
            self.popoverBoardTable.isScrollEnabled = false
        }
        else {
            self.tableHeightConstraints.constant = CGFloat(tableReqH + diff - 10)
            self.popoverBoardTable.isScrollEnabled = true
        }
    }

    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func meditationApi(type: String) {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : 1,
            "level_id"      : 1,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : type,
            "guided_type"   : "Guided", // 'guided_type'
            "personalise"   : DataManager.sharedInstance.postData
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMConOnboardingVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //print("result signupletsstartvc meditation data... \(result)")
                //self.appPreference.setType(value: type)
                //self.appPreference.setGuideType(value: "Guided")
                self.appPreference.setType(value: "guided")
                self.appPreference.set21ChallengeName(value: type.capitalized)
                
                self.appPreference.setGuideTypeFor3DTouch(value: type)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.appPreference.setGetProfile(value: true)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                    UIApplication.shared.keyWindow?.rootViewController = vc
                    //UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
                }
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }

}

extension WWMPopoverOnboardingVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2//self.optionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let selectedBGImage = UIImageView(image: UIImage(named: "cellSelectedBG.png"))
        cell.selectedBackgroundView = selectedBGImage
        
        cell.tintColor = UIColor.black
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = UIColor.clear

        let text = self.optionList[indexPath.section].option_name
        if (text?.first == "Y"){
            let bgImage = UIImageView(image: UIImage(named: "cellBG.png"))
            cell.backgroundView = bgImage
        }
        
        cell.textLabel?.text = text
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return cell
    }
    
    func selectedOption() {
        
        let selectedOption = self.optionList.filter({$0.isSelected == true})
        DataManager.sharedInstance.getOptionList(selectedOptionList: selectedOption, currentPage: self.dataObj)
        DataManager.sharedInstance.postOnboardingRequest()
        if let exitPoint = selectedOption.first?.exitPoint {
            self.meditationApi(type: exitPoint);
        }
    }
}

extension WWMPopoverOnboardingVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedOpt = self.optionList[indexPath.section]
        selectedOpt.isSelected = true
        self.selectedOption()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }


}

