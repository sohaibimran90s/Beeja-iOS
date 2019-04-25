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
    @IBOutlet weak var lblMoodselect: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var moodView: UIView?
    @IBOutlet weak var circularSlider: CircularSlider?
    var moodScroller: UIScrollView?
    
    var arrMoodData = [WWMMoodMeterData]()
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
    var arrLabel = [UILabel]()
    
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        UIView.transition(with: alertPrompt, duration: 1.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertPrompt)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.moodView!.bounds.size.width * CGFloat(self.arrMoodData.count / 2) + self.moodView!.bounds.size.width / 2, height: self.moodView!.bounds.size.height)
        var x = self.moodView!.bounds.size.width / 4
        let y = CGFloat(0)
        let width = self.moodView!.bounds.size.width / 2
        let height = self.moodView!.bounds.size.height
        self.arrLabel.removeAll()
        for mood in self.arrMoodData {
            label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            label.backgroundColor = .clear
            
            
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 13)
            label.text = mood.name
            
            label.textAlignment = .center
            scrollView.addSubview(label)
            x = x + width
            self.arrLabel.append(label)
        }
        self.moodView!.addSubview(scrollView)
        self.moodScroller = scrollView
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }


    func translatedAngle(angle: Double) -> Double {
        var angle = Double(450) -  angle
        if angle > 360 {
            angle = angle - 360
        }
        return angle
    }
    
    func circularSlider(_ circularSlider: CircularSlider, angleDidChanged newAngle: Double) -> Void {
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
        
        for index in 0..<arrLabel.count {
            let label = self.arrLabel[index]
            if index == moodIndex {
                label.font = UIFont.boldSystemFont(ofSize: 16)
                label.textColor = UIColor.white
            }else {
                label.font = UIFont.systemFont(ofSize: 13)
                label.textColor = UIColor.lightGray
            }
            
        }
        
        print("selected mood = \(mood.name)")
        self.btnConfirm.isHidden = false
        self.lblMoodselect.text = "Move dot to select your current feeling"
        // show your button here
    }
    

    // MARK:- Button Action

    @IBAction func btnSkipAction(_ sender: Any) {
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
