//
//  WWMMoodMeterVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 10/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMMoodMeterVC: WWMBaseViewController,CircularSliderDelegate {

    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAskMeAgain: UIButton!
    @IBOutlet weak var lblMoodselect: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var moodView: UIView?
    @IBOutlet weak var circularSlider: CircularSlider?
    var moodScroller: UIScrollView?
    
    var arrMoodData = [WWMMoodMeterData]()
    var moodData = WWMMoodMeterData()
    var selectedIndex = -1
    var prepTime = 0
    var meditationTime = 0
    var restTime = 0
    var type = ""   // Pre | Post
    var meditationID = ""
    var levelID = ""
    var category_Id = "0"
    var emotion_Id = "0"
    var audio_Id = "0"
    var watched_duration = "0"
    var rating = "0"
    
    var settingData = DBSettings()
    var alertPrompt = WWMPromptMsg()
    
    var button = UIButton()
    var arrButton = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == "Pre" {
            self.btnAskMeAgain.isHidden = true
            self.btnSkip.isHidden = true
        }else{
            self.btnBack.isHidden = true
        }
        
        self.xibCall()
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Skip",
                                                        attributes: attributes)
        btnSkip.setAttributedTitle(attributeString, for: .normal)

        self.btnConfirm.layer.borderWidth = 2.0
        self.btnConfirm.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        self.btnConfirm.isHidden = true
        let data = WWMHelperClass.fetchDB(dbName: "DBSettings") as! [DBSettings]
        if data.count > 0 {
            settingData = data[0]
        }
        let moodMeter = WWMMoodMeterData()
        arrMoodData = moodMeter.getMoodMeterData()
        
        self.moodView?.isHidden = true
        self.moodView?.layer.cornerRadius = 20
        self.moodView?.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    func xibCall(){
        alertPrompt = UINib(nibName: "WWMPromptMsg", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMPromptMsg
        let window = UIApplication.shared.keyWindow!
        
        alertPrompt.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        UIView.transition(with: alertPrompt, duration: 0.8, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPrompt)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.alertPrompt.removeFromSuperview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.createMoodScroller()
    }

    func createMoodScroller() {
        
        let scrollView = UIScrollView(frame: self.moodView!.bounds)
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.moodView!.bounds.size.width * CGFloat(self.arrMoodData.count / 2) + self.moodView!.bounds.size.width / 2, height: self.moodView!.bounds.size.height)
        var x = self.moodView!.bounds.size.width / 4
        let y = CGFloat(0)
        let width = self.moodView!.bounds.size.width / 2
        let height = self.moodView!.bounds.size.height

        self.arrButton.removeAll()
        var tags: Int = 0
        for mood in self.arrMoodData {
            
            //buttons....
            button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
            button.backgroundColor = .clear
            
            button.setTitle(mood.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 13)
            button.titleLabel?.textAlignment = .center
            button.tag = tags
            
            button.addTarget(self, action: #selector(selectedMoodAction), for: .touchUpInside)
            scrollView.addSubview(button)
            x = x + width
            self.arrButton.append(button)
            tags += 1
        }
        
        self.moodView!.addSubview(scrollView)
        self.moodScroller = scrollView
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @objc func selectedMoodAction(sender: UIButton){
        print("sender selected button label with tag.....\(sender.tag) selectedName...\(self.arrMoodData[sender.tag].name) buttonName.... \(arrButton[sender.tag].titleLabel?.text ?? "") selected index button... \(sender.tag)")
        
        selectedIndex = sender.tag

        for index in 0..<arrButton.count {
            let button = arrButton[index]
            if index == sender.tag {
                button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 16)
                button.setTitleColor(UIColor.white, for: .normal)
            }else {
                button.titleLabel?.font = UIFont(name: "Maax-Medium", size: 13)
                button.setTitleColor(UIColor.lightGray, for: .normal)
            }
        }
        
        
        let diff = Double(360) / Double(self.arrMoodData.count)
        let angle = Double(selectedIndex) * diff
        self.circularSlider(circularSlider!, angleDidChanged: angle)
        
        
        let x = Int(self.moodView!.bounds.size.width / 2) * selectedIndex
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)

    }
    
    func translatedAngle(angle: Double) -> Double {
        print("angle..... \(angle)")
        //450
        var angle = Double(450) -  angle
        if angle > 360 {
            angle = angle - 360
        }
        return angle
    }
    
    func circularSlider(_ circularSlider: CircularSlider, angleDidChanged newAngle: Double) -> Void {
        
        print("newAngle.... \(newAngle)")
        let angle = self.translatedAngle(angle: newAngle)
        self.moodView?.isHidden = false
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        let x = Int(self.moodView!.bounds.size.width / 2) * Int(selectedMood)
        self.moodScroller?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func circularSlider(slidingDidEnd circularSlider: CircularSlider) -> Void {
        let angle = self.translatedAngle(angle: circularSlider.angleInDegrees())
        let diff = Double(360) / Double(self.arrMoodData.count)
        let selectedMood = angle / diff
        let moodIndex = Int(selectedMood)
        selectedIndex = moodIndex
        let mood = self.arrMoodData[moodIndex]

        print("selected index slider... \(selectedIndex)")
        
        for index in 0..<arrButton.count {
            let button = arrButton[index]
            if index == moodIndex {
                button.titleLabel?.font = UIFont(name: "Maax-Bold", size: 16)
                button.setTitleColor(UIColor.white, for: .normal)
            }else {
                button.titleLabel?.font = UIFont(name: "Maax-Medium", size: 13)
                button.setTitleColor(UIColor.lightGray, for: .normal)
            }
        }
        
        print("selected mood = \(mood.name)")
        self.btnConfirm.isHidden = false
        self.lblMoodselect.text = "Move dot to select your current feeling"
    }
    

    // MARK:- Button Action

    @IBAction func btnSkipAction(_ sender: Any) {

        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "type": self.userData.type,
            "category_id": self.category_Id,
            "emotion_id": self.emotion_Id,
            "audio_id": self.audio_Id,
            "guided_type": self.userData.guided_type,
            "watched_duration": self.watched_duration,
            "rating": self.rating,
            "user_id": self.appPreference.getUserID(),
            "meditation_type": self.type,
            "date_time": "\(Int(Date().timeIntervalSince1970*1000))",
            "tell_us_why": "",
            "prep_time": self.prepTime,
            "meditation_time": self.meditationTime,
            "rest_time": self.restTime,
            "meditation_id": self.meditationID,
            "level_id": self.levelID,
            "mood_id": self.moodData.id == -1 ? "0" : self.moodData.id,
            ] as [String : Any]
        
        print("param.... \(param)")
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONCOMPLETE, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let success = result["success"] as? Bool {
                    print(success)
                    self.navigateToDashboard()
                }else {
                    self.saveToDB(param: param)
                }
                
            }else {
                self.saveToDB(param: param)
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func saveToDB(param:[String:Any]) {
        let meditationDB = WWMHelperClass.fetchEntity(dbName: "DBMeditationComplete") as! DBMeditationComplete
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        meditationDB.meditationData = myString
        WWMHelperClass.saveDb()
        self.navigateToDashboard()
    }
    
    func navigateToDashboard() {
        self.navigationController?.isNavigationBarHidden = false
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 4
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 4 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        if selectedIndex != -1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMMoodMeterLogVC") as! WWMMoodMeterLogVC
            vc.moodData = arrMoodData[selectedIndex]
            vc.type = self.type
            vc.prepTime = self.prepTime
            vc.meditationTime = self.meditationTime
            vc.restTime = self.restTime
            vc.meditationID = self.meditationID
            vc.levelID = self.levelID
            vc.category_Id = self.category_Id
            vc.emotion_Id = self.emotion_Id
            vc.audio_Id = self.audio_Id
            vc.rating = self.rating
            vc.watched_duration = self.watched_duration
            
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
        vc.meditationID = self.meditationID
        vc.levelID = self.levelID
        vc.category_Id = self.category_Id
        vc.emotion_Id = self.emotion_Id
        vc.audio_Id = self.audio_Id
        vc.rating = self.rating
        vc.watched_duration = self.watched_duration
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
