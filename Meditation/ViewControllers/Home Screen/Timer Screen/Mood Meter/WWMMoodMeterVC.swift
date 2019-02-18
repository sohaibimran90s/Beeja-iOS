//
//  WWMMoodMeterVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodMeterVC: WWMBaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var lblExpressMood: UILabel!
    var arrMoodData = [WWMMoodMeterData]()
    var selectedIndex = -1
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var type = ""   // Pre | Post
    
    var settingData = DBSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        let moodMeter = WWMMoodMeterData()
        arrMoodData = moodMeter.getMoodMeterData()
        
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }


    // MARK:- Button Action

    @IBAction func btnSkipAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
        vc.type = self.type
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        if selectedIndex != -1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
            vc.moodData = arrMoodData[selectedIndex]
            vc.type = self.type
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnAskMeAgainAction(_ sender: Any) {
        
        self.settingData.moodMeterEnable = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
        vc.type = self.type
        vc.prepTime = self.prepTime
        vc.meditationTime = self.meditationTime
        vc.restTime = self.restTime
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK:- UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMoodData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if  let view = cell.viewWithTag(101) {
            let data = arrMoodData[indexPath.row]
            view.backgroundColor = UIColor.init(hexString: data.color)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if  let cell = collectionView.cellForItem(at: indexPath) {
            if let zoomView = cell.viewWithTag(101){
                self.lblExpressMood.text = arrMoodData[indexPath.row].mood
                UIView.animate(withDuration: 0.5, animations: {
                    zoomView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                    self.lblExpressMood.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                }, completion: { (isComplete) in
                    if isComplete {
                        UIView.animate(withDuration: 0.5) {
                            zoomView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                            self.lblExpressMood.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                })
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-40)/10
        return CGSize.init(width: width, height: width)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
