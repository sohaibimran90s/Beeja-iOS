//
//  WWM21DayChallengeVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/02/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWM21DayChallengeVC: WWMBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var introBtn: UIButton!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func introBtnAction(_ sender: UIButton) {
    }
}

extension WWM21DayChallengeVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWM21DayChallengeTVC") as! WWM21DayChallengeTVC
        
        if selectedIndex == indexPath.row{
            cell.descLbl.isHidden = false
            
            cell.backImg1.backgroundColor = UIColor(red: 14.0/255.0, green: 31.0/255.0, blue: 104.0/255.0, alpha: 0.7)
            cell.backImg2.isHidden = false
            cell.backImg1.isHidden = true
            cell.arrowImg.image = UIImage(named: "upArrow")
        }else{
            cell.descLbl.isHidden = true
            cell.backImg1.isHidden = false
            cell.backImg2.isHidden = true
            cell.arrowImg.image = UIImage(named: "downArrow")
        }
        
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
}

extension WWM21DayChallengeVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as! WWM21DayChallengeCVC
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}
