//
//  WWMMyProgressStatsVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressStatsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    

    @IBOutlet weak var collectionViewCal: UICollectionView!
    @IBOutlet weak var viewHourMeditate: UIView!
    @IBOutlet weak var lblHourMeditate: UILabel!
    @IBOutlet weak var lblAvMinutes: UILabel!
    @IBOutlet weak var lblDailyfrequency: UILabel!
    @IBOutlet weak var lblAvSession: UILabel!
    @IBOutlet weak var lblLongestSession: UILabel!
    @IBOutlet weak var viewAvMinutes: UIView!
    var statsData = WWMSatsProgressData()
    var dayAdded = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpUI()
    }
    
    func setUpUI() {
        let getData = WWMSatsProgressData()
        statsData = getData.getStatsProgressData()
        
        let firstDate = self.makeDate(year: 2019, month: 2, day: 1, hr: 8, min: 30, sec: 30)
        let weekDay = Calendar.current.ordinality(of: .day, in: .weekOfMonth, for: firstDate)
        dayAdded = weekDay!-1
        DispatchQueue.main.async {
           // self.viewAvMinutes.layer.cornerRadius = self.viewAvMinutes.frame.size.height/2
           // self.viewAvMinutes.layer.borderWidth = 1.0
           // self.viewAvMinutes.layer.borderColor = UIColor.lightGray.cgColor
            
           // self.viewHourMeditate.layer.cornerRadius = //self.viewHourMeditate.frame.size.height/2
          //  self.viewHourMeditate.layer.borderWidth = 1.0
          //  self.viewHourMeditate.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        
        self.collectionViewCal.reloadData()
    }
    
    func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }
    
    // MARK:- Button Action
    
    @IBAction func btnAddJournalAction(_ sender: Any) {
        
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statsData.consecutiveDays.count+dayAdded
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < dayAdded {
            let blankCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlankCell", for: indexPath)
            return blankCell
        }
        
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WWMStatsCalCollectionViewCell
        //cell.viewDateCircle.layer.cornerRadius = cell.viewDateCircle.frame.size.width/2
        cell.imgViewLeft.isHidden = true
        cell.imgViewRight.isHidden = true
        let data = statsData.consecutiveDays[indexPath.row-dayAdded]
        if data.meditationStatus == 0  {
            
        }else if data.meditationStatus == 1 {
            cell.viewDateCircle.layer.borderWidth = 2.0
            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//            let arcCenter = CGPoint(x: cell.viewDateCircle.bounds.size.width / 2, y: cell.viewDateCircle.bounds.size.height / 2)
//            let circleRadius = cell.viewDateCircle.bounds.size.width / 2
//            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi * 3/2, clockwise: true)
//
//            let semiCirleLayer = CAShapeLayer()
//            semiCirleLayer.path = circlePath.cgPath
//            semiCirleLayer.strokeColor = UIColor.init(hexString: "#00eba9")!.cgColor
//            semiCirleLayer.lineWidth = 2.0
//            semiCirleLayer.fillColor = UIColor.clear.cgColor
//            cell.viewDateCircle.layer.addSublayer(semiCirleLayer)
        }else if data.meditationStatus == 2 {
            cell.viewDateCircle.layer.borderWidth = 2.0
            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//            let arcCenter = CGPoint(x: cell.viewDateCircle.bounds.size.width / 2, y: cell.viewDateCircle.bounds.size.height / 2)
//            let circleRadius = cell.viewDateCircle.bounds.size.width / 2
//            let circlePath = UIBezierPath(arcCenter: arcCenter, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi * 3/2, clockwise: false)
//
//            let semiCirleLayer = CAShapeLayer()
//            semiCirleLayer.path = circlePath.cgPath
//            semiCirleLayer.strokeColor = UIColor.init(hexString: "#00eba9")!.cgColor
//            semiCirleLayer.lineWidth = 2.0
//            semiCirleLayer.fillColor = UIColor.clear.cgColor
//            cell.viewDateCircle.layer.addSublayer(semiCirleLayer)
        }else if data.meditationStatus == 3 {
            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
        }
        
//        if dayMonth == data.date {
//            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
//            cell.lblDate.textColor = UIColor.black
//        }
        
        if indexPath.row > 0 {
            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row-1].meditationStatus == 3 {
                cell.imgViewLeft.isHidden = false
                cell.imgViewLeft.image = UIImage.init(named: "doubleLineLeft")
            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row-1].meditationStatus == 0 {
                cell.imgViewLeft.isHidden = true
            }else {
                cell.imgViewLeft.isHidden = false
                cell.imgViewLeft.image = UIImage.init(named: "singleLineLeft")
                // Single
            }
        }
        
        
        if indexPath.row < statsData.consecutiveDays.count-1 {
            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row+1].meditationStatus == 3 {
                cell.imgViewRight.isHidden = false
                cell.imgViewRight.image = UIImage.init(named: "doubleLineRight")
            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row+1].meditationStatus == 0 {
                cell.imgViewRight.isHidden = true
            }else {
                cell.imgViewRight.isHidden = false
                cell.imgViewRight.image = UIImage.init(named: "singleLineRight")
            }
        }
        
        
        
        
        
        
        
        
        cell.lblDate.text = "\(data.date)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-80)/7
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
