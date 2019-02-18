//
//  WWMMeditationListVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMMeditationListVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource {

//    let arrMeditationList = ["Vedic","Vipassana","Transcendential","Zen","Mindfulness","Set My Own"]
    var arrMeditationDataList = [DBMeditationData]()
    @IBOutlet weak var tblMeditationList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        self.setNavigationBar(isShow: false, title: "")
        
        let data = WWMHelperClass.fetchDB(dbName: "DBMeditationData") as! [DBMeditationData]
        if data.count > 0 {
            arrMeditationDataList = data
        }
        
        self.tblMeditationList.reloadData()
    }
    
    // MARK: UITableView Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMeditationDataList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell = UITableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "secondCell")!
        
        let data = self.arrMeditationDataList[indexPath.row]
            let btn = cell.viewWithTag(101) as! UIButton
            btn.setTitle(data.meditationName, for: .normal)
            btn.layer.borderWidth = 2.0
            btn.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
            
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        for index in 0..<arrMeditationDataList.count {
            if index == indexPath.row {
                arrMeditationDataList[index].isMeditationSelected = true
            }else {
                arrMeditationDataList[index].isMeditationSelected = false
            }
        }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMeditationLevelVC") as! WWMMeditationLevelVC
            self.navigationController?.pushViewController(vc, animated: false)
        
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var cellHeight:CGFloat = tableView.frame.size.height
//        let numberOfCell = self.arrMeditationList.count+1
//        cellHeight = cellHeight / CGFloat(numberOfCell)
//        return cellHeight
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
