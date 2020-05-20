//
//  WWMPopoverOnboardingVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMPopoverOnboardingVC: UIViewController {

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
    
}

extension WWMPopoverOnboardingVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }


}

