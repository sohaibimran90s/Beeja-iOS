//
//  WWMMyProgressStatsVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressStatsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var lblMonthYear: UILabel!
    @IBOutlet weak var btnPreviousMonth: UIButton!
    @IBOutlet weak var btnNextMonth: UIButton!
    
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
    var monthValue = 0
    var strMonthYear = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpUI()
    }
    
    func setUpUI() {
        self.updateDate(date: Date())
        DispatchQueue.main.async {
           // self.viewAvMinutes.layer.cornerRadius = self.viewAvMinutes.frame.size.height/2
           // self.viewAvMinutes.layer.borderWidth = 1.0
           // self.viewAvMinutes.layer.borderColor = UIColor.lightGray.cgColor
            
           // self.viewHourMeditate.layer.cornerRadius = //self.viewHourMeditate.frame.size.height/2
          //  self.viewHourMeditate.layer.borderWidth = 1.0
          //  self.viewHourMeditate.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    
    func updateDate(date : Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMM, yyyy"
        self.lblMonthYear.text = dateFormatter.string(from: date)
        self.btnNextMonth.isHidden = true
        
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: date)
        let firstDate = self.makeDate(year: Int(year)!, month: Int(month)!, day: 1, hr: 8, min: 30, sec: 30)
        let weekDay = Calendar.current.ordinality(of: .day, in: .weekOfMonth, for: firstDate)
        dayAdded = weekDay!-2
        
        self.getStatsData()
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
    
    @IBAction func btnNextMonthAction(_ sender: Any) {
        monthValue = monthValue+1
        if monthValue == 0 {
            self.btnNextMonth.isHidden = true
        }
         let nextMonth = Calendar.current.date(byAdding: .month, value: monthValue, to: Date())
        self.updateDate(date: nextMonth!)
    }
    
    @IBAction func btnPreviousMonthAction(_ sender: Any) {
        monthValue = monthValue-1
        self.btnNextMonth.isHidden = true
        let previousMonth = Calendar.current.date(byAdding: .month, value: monthValue, to: Date())
        self.updateDate(date: previousMonth!)
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statsData.consecutive_days.count + dayAdded
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
        let data = statsData.consecutive_days[indexPath.row-dayAdded]
        
        if indexPath.row-dayAdded > 0 {
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) && !(statsData.consecutive_days[indexPath.row-dayAdded+1].meditation_status == 0 && statsData.consecutive_days[indexPath.row-dayAdded+1].meditation_status2 == 0) {
                cell.imgViewRight.isHidden = false
            }
        }else if indexPath.row-dayAdded == self.statsData.consecutive_days.count-1 {
            if !(data.meditation_status == 0 && data.meditation_status2 == 0) {
                cell.imgViewRight.isHidden = false
            }
        }else {
            
        }
        
        if (data.meditation_status == 1 && data.meditation_status2 == 1) || (data.meditation_status == 1 && data.meditation_status2 == -1){
            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
        }else if (data.meditation_status == 0 && data.meditation_status2 == 0) {
            
        }else {
            cell.viewDateCircle.layer.borderWidth = 2.0
            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        }
        
        
        
        
        
//        if data.meditationStatus == 0  {
//
//        }else if data.meditationStatus == 1 {
//            cell.viewDateCircle.layer.borderWidth = 2.0
//            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//
//        }else if data.meditationStatus == 2 {
//            cell.viewDateCircle.layer.borderWidth = 2.0
//            cell.viewDateCircle.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
//
//        }else if data.meditationStatus == 3 {
//            cell.viewDateCircle.backgroundColor = UIColor.init(hexString: "#00eba9")!
//        }
//
//        if indexPath.row-dayAdded > 0 {
//            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row-1].meditationStatus == 3 {
//                cell.imgViewLeft.isHidden = false
//                cell.imgViewLeft.image = UIImage.init(named: "doubleLineLeft")
//            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row-1].meditationStatus == 0 {
//                cell.imgViewLeft.isHidden = true
//            }else {
//                cell.imgViewLeft.isHidden = false
//                cell.imgViewLeft.image = UIImage.init(named: "singleLineLeft")
//                // Single
//            }
//        }
//
//
//        if indexPath.row < statsData.consecutiveDays.count-1 {
//            if data.meditationStatus == 3 && statsData.consecutiveDays[indexPath.row+1].meditationStatus == 3 {
//                cell.imgViewRight.isHidden = false
//                cell.imgViewRight.image = UIImage.init(named: "doubleLineRight")
//            }else if data.meditationStatus == 0 || statsData.consecutiveDays[indexPath.row+1].meditationStatus == 0 {
//                cell.imgViewRight.isHidden = true
//            }else {
//                cell.imgViewRight.isHidden = false
//                cell.imgViewRight.image = UIImage.init(named: "singleLineRight")
//            }
//        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let monthDate = dateFormatter.date(from:data.date)!
        dateFormatter.dateFormat = "d"
        cell.lblDate.text = dateFormatter.string(from: monthDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-80)/7
        return CGSize.init(width: width, height: width)
    }
    
    
    func getStatsData() {
        WWMHelperClass.showSVHud()
        let param = ["user_id":"11",
                     "month":self.strMonthYear]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_STATSMYPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["Response"] as? [String:Any] {
                    self.statsData = WWMSatsProgressData.init(json: data)
                }
                self.collectionViewCal.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }


}
