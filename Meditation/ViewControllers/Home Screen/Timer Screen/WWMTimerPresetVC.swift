//
//  WWMTimerPresetVC.swift
//  Meditation
//
//  Created by Prema Negi on 26/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

protocol WWMTimerPresetVCDelegate {
    func choosePresetName(index: Int)
}

class WWMTimerPresetVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: WWMTimerPresetVCDelegate?
    
    var LevelData  = [DBLevelData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0).withAlphaComponent(0.9)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        

        self.tableViewHeightConstraint.constant = CGFloat(80 * self.LevelData.count + 30)
    }
    
    @IBAction func crossBtnClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension WWMTimerPresetVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.LevelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let data = self.LevelData[indexPath.row]
        let label:UILabel = cell.viewWithTag(1) as! UILabel
        label.layer.borderWidth = 2
        label.layer.cornerRadius = 20
        label.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        label.text = data.levelName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            self.delegate?.choosePresetName(index: indexPath.row)
        }
        
    }
}
