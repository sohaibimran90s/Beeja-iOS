//
//  WWMMeditationListVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMMeditationListVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource {

    var arrMeditationDataList = [DBAllMeditationData]()
    var type = ""
    @IBOutlet weak var tblMeditationList: UITableView!
    
    private var finishedLoadingInitialTableCells = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBAllMeditationData") as! [DBAllMeditationData]
        if data.count > 0 {
            arrMeditationDataList = data
        }
        
        self.tblMeditationList.reloadData()
    }
    
    // MARK: UITableView Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMeditationDataList.count+1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell = UITableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "secondCell")!
        
        let btn = cell.viewWithTag(101) as! UIButton
        
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        if indexPath.row == self.arrMeditationDataList.count {
            btn.setTitle("Set My Own", for: .normal)
        }else {
            let data = self.arrMeditationDataList[indexPath.row]
            btn.setTitle(data.meditationName, for: .normal)
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        if indexPath.row == self.arrMeditationDataList.count {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSetMyOwnVC") as! WWMSetMyOwnVC
            vc.type = "timer"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            
            self.appPreference.setMin_limit(value: arrMeditationDataList[indexPath.row].min_limit ?? "0")
            self.appPreference.setMax_limit(value: arrMeditationDataList[indexPath.row].max_limit ?? "0")
            self.appPreference.setMeditation_key(value: arrMeditationDataList[indexPath.row].meditationName ?? "0")
            
            print("setMin_limit++++ \(self.appPreference.getMin_limit()) setMax_limit++++ \(self.appPreference.getMax_limit()) setMeditation++++ \(self.appPreference.getMeditation_key())")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMeditationLevelVC") as! WWMMeditationLevelVC
            vc.selectedMeditation_Id = "\(arrMeditationDataList[indexPath.row].meditationId)"
            vc.type = self.type
            if let levels = arrMeditationDataList[indexPath.row].levels?.array as? [DBLevelData] {
                vc.arrMeditationLevels = levels
            }
    
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if self.arrMeditationDataList.count+1 > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        
        if !finishedLoadingInitialTableCells {
            
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: 80/2)
            cell.alpha = 0
            
            // UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations:
            
            UIView.animate(withDuration: 0.5, delay: 0.1*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
}
