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
    @IBOutlet weak var tblMeditationList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
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
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMeditationLevelVC") as! WWMMeditationLevelVC
            vc.selectedMeditation_Id = "\(arrMeditationDataList[indexPath.row].meditationId)"
            if let levels = arrMeditationDataList[indexPath.row].levels?.array as? [DBLevelData] {
                vc.arrMeditationLevels = levels
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }


}
