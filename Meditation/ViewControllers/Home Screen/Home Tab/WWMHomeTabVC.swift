//
//  WWMHomeTabVC.swift
//  Meditation
//
//  Created by Prema Negi on 11/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import Crashlytics

class WWMHomeTabVC: WWMBaseViewController {

    @IBOutlet weak var lblMedHistoryText: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartedText: UILabel!
    @IBOutlet weak var lblIntroText: UILabel!
    @IBOutlet weak var imgGiftIcon: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var btnPlayVideo: UIButton!
    @IBOutlet weak var viewVideo: VideoView!
    @IBOutlet weak var backImgVideo: UIImageView!
    @IBOutlet weak var viewVideoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPodcastShowAll: UIButton!
    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var backViewTableView: UIView!
    @IBOutlet weak var medHisViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgTopBar: UIImageView!
    
    var player: AVPlayer?
    let playerController = AVPlayerViewController()
    var yaxis: CGFloat = 540
    
    let dateFormatter = DateFormatter()
    var currentDateString: String = ""
    var currentDate: Date!

    var giftPopUp = WWMHomeGiftPopUp()
    var alertJournalPopup = WWMJouranlPopUp()
    
    var data: [WWMMeditationHistoryListData] = []
    var podData: [WWMPodCastData] = []

    var guideStart = WWMGuidedStart()
    var guided_type = ""
    var type = ""
    
    let appPreffrence = WWMAppPreference()
    let reachable = Reachabilities()
    
    var timerCount = 0
    var selectedAudio = "0"
    
    var podcastMusicPlayerPopUp = WWWMPodCastPlayerView()
    
    
    //MARK:- Viewcontroller Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Crashlytics.sharedInstance().crash()
        self.podData = []
        self.podcastData()
        
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        self.currentDateString = dateFormatter.string(from: Date())
        self.currentDate = dateFormatter.date(from: currentDateString)!


        self.backViewTableView.layer.cornerRadius = 8
        self.btnBuyNow.layer.borderWidth = 2
        self.btnBuyNow.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSHOWALL,
                                                        attributes: attributes)
        btnPodcastShowAll.setAttributedTitle(attributeString, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationMeditationHistory(notification:)), name: Notification.Name("notificationMeditationHistory"), object: nil)
    }
    
    @objc func notificationMeditationHistory(notification: Notification) {
        self.fetchMeditationHistDataFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //UIApplication.shared.isStatusBarHidden = true
        timerCount = Int.random(in: 0...4)
        WWMHelperClass.timerCount = timerCount
        print("timercount... \(timerCount)")
        
        self.fetchMeditationHistDataFromDB()

        self.setNavigationBar(isShow: false, title: "")
        scrollView.setContentOffset(.zero, animated: true)
        //scrollView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)

        print("self.appPreffrence.getSessionAvailableData()... \(self.appPreffrence.getSessionAvailableData())")
        print("self.appPreffrence.getUserName()... \(self.appPreffrence.getUserName())")
        //self.imgTopBar.isHidden = true
        
        if self.appPreffrence.getSessionAvailableData(){
            self.imgTopBar.isHidden = false
            self.viewVideoHeightConstraint.constant = 140
            self.lblStartedText.text = KHOMELBL
            self.backImgVideo.image = UIImage(named: "meditationHistoryBG")
            self.imgTopBar.image = UIImage(named: "meditationHistoryBG")
            self.lblIntroText.isHidden = true
            self.imgGiftIcon.isHidden = true
            self.imgPlayIcon.isHidden = true
            
            let date = Date()// Aug 25, 2017, 11:55 AM
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            
            if hour < 12 {
                print("good morning")
                self.lblName.text = "\(kMORNING)\n\(self.appPreffrence.getUserName())!"
            }else if hour < 18 {
                print("good afternoon")
                self.lblName.text = "\(kAFTERNOON)\n\(self.appPreffrence.getUserName())!"
            }else{
                print("good evening")
                self.lblName.text = "\(kEVENING)\n\(self.appPreffrence.getUserName())!"
            }
        }else{
            self.imgTopBar.isHidden = true
            self.lblName.text = "\(KWELCOME) \(self.appPreffrence.getUserName())!"
            self.lblStartedText.text = KHOMELBL1
            self.backImgVideo.image = UIImage(named: "bg1")
            //self.imgTopBar.image = UIImage(named: "bg1")
            self.lblIntroText.isHidden = false
            self.imgGiftIcon.isHidden = false
            self.imgPlayIcon.isHidden = false
            self.getScreenSize()
        }
        
        self.lblName.alpha = 0
        self.lblStartedText.alpha = 0
        self.lblIntroText.alpha = 0
        self.imgPlayIcon.alpha = 0
        self.imgGiftIcon.alpha = 0
        
        self.selectedAudio = "0"
        
        //self.animatedImg()
        self.animatedlblName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //UIApplication.shared.isStatusBarHidden = false
        self.lblName.center.y = self.lblName.center.y + 20
        self.lblStartedText.center.y = self.lblStartedText.center.y + 16
        self.lblIntroText.center.y = self.lblIntroText.center.y + 20
        self.imgPlayIcon.center.y = self.imgPlayIcon.center.y + 24
        
        self.introView.isHidden = false
        for data in self.podData {
            if data.isPlay {
                self.player?.pause()
                data.isPlay = false
                data.currentTimePlay = 0
            }
        }
        
        self.tableView.reloadData()
        self.player?.pause()
        self.stopPlayer()
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player {
            print("stopped")
            play.pause()
            self.player = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
        }
    }
    
    //MARK: get screen size for setting video according to device
    func getScreenSize(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                yaxis = 476
            case 1334:
                print("iPhone 6/6S/7/8")
                yaxis = 570
            case 2208:
                print("iPhone 6+/6S+/7+/8+")
                yaxis = 640
            case 2436:
                print("iPhone X, XS")
                yaxis = 660
            case 2688:
                print("iPhone XS Max")
                yaxis = 740
            case 1792:
                print("iPhone XR")
                yaxis = 740
            default:
                print("unknown")
                yaxis = 570
            }
            
            self.viewVideoHeightConstraint.constant = yaxis
        }
    }
    
    //MARK: animated Views
    func animatedImg(){
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.imgGiftIcon.alpha = 1.0
        })
    }
    
    func animatedlblName(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblName.alpha = 1
            self.lblName.center.y = self.lblName.center.y - 20
        }, completion: { _ in
            self.animatedStartedText()
        })
    }
    
    func animatedStartedText(){
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
              self.lblStartedText.alpha = 1
              self.lblStartedText.center.y = self.lblStartedText.center.y - 16
          }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.animatedIntroText()
            })
          })
      }
    
    func animatedIntroText(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.lblIntroText.alpha = 1
            self.lblIntroText.center.y = self.lblIntroText.center.y - 20
        }, completion: { _ in
            self.animatedImgPlayIcon()
        })
    }

    func animatedImgPlayIcon(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.imgPlayIcon.alpha = 1
            self.imgPlayIcon.center.y = self.imgPlayIcon.center.y - 24
            }, completion: {_ in
        })
    }
    
    @IBAction func btnVideoClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "help"
        self.navigationController?.pushViewController(vc, animated: true)
      /*  let videoURL: String = self.appPreffrence.getHomePageURL()
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        if videoURL != ""{
            print("videourl... \(videoURL)")
            player = AVPlayer(url: URL(string: videoURL)!)
            playerController.player = player
            present(playerController, animated: true){
                self.player?.play()
            }
        }*/
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification){
        playerController.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnGiftClicked(_ sender: UIButton) {
        self.giftPopupAlert()
    }
    
    func giftPopupAlert(){
        self.giftPopUp = UINib(nibName: "WWMHomeGiftPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMHomeGiftPopUp
        let window = UIApplication.shared.keyWindow!
        
        self.giftPopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.giftPopUp.btnText.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
         self.giftPopUp.btnEmail.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
         self.giftPopUp.btnShare.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.giftPopUp.btnClose.addTarget(self, action: #selector(btnAlertCloseAction(_:)), for: .touchUpInside)
        self.giftPopUp.btnText.addTarget(self, action: #selector(btnTextAction(_:)), for: .touchUpInside)
        self.giftPopUp.btnEmail.addTarget(self, action: #selector(btnEmailAction(_:)), for: .touchUpInside)
        self.giftPopUp.btnShare.addTarget(self, action: #selector(btnShareAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(giftPopUp)
    }
    
    @objc func btnAlertCloseAction(_ sender: Any){
        self.giftPopUp.removeFromSuperview()
    }
    
    
    @objc func btnTextAction(_ sender: Any){
        self.giftPopUp.removeFromSuperview()
        self.shareData()
    }
    
    @objc func btnEmailAction(_ sender: Any){
        self.giftPopUp.removeFromSuperview()
        self.shareData()
    }
    
    @objc func btnShareAction(_ sender: Any){

        self.giftPopUp.removeFromSuperview()
        self.shareData()
    }
    
    func shareData(){
        let image = UIImage.init(named: "upbeat")
        let text = KSHARETEXT
        let imageToShare = [text,image!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            print(success ? "SUCCESS!" : "FAILURE")
            
            if success{
                self.xibJournalPopupCall()
            }
        }
        
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func xibJournalPopupCall(){
        alertJournalPopup = UINib(nibName: "WWMJouranlPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMJouranlPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertJournalPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        alertJournalPopup.lblTitle.text = KNICEONE
        alertJournalPopup.lblSubtitle.text = KMSGSHARED
        UIView.transition(with: alertJournalPopup, duration: 2.0, options: .transitionCrossDissolve, animations: {
            window.rootViewController?.view.addSubview(self.alertJournalPopup)
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertJournalPopup.removeFromSuperview()
            }
        }
    }
    
    func podcastData(){
        let podcast1 = WWMPodCastData.init(id: 1, title: KPODCAST1, duration: 4144, url_link: "https://mcdn.podbean.com/mf/play/h38jdi/Podcast_with_Howard_Donald_6th_November_2017_MP3_Master.mp3", isPlay: false, analyticsName: KPODCASTNAME1, currentTimePlay: 0)
        let podcast2 = WWMPodCastData.init(id: 1, title: KPODCAST2, duration: 3000, url_link: "https://mcdn.podbean.com/mf/play/35czi8/Podcast_with_Jasmine_Hemsley_MP3_Master.mp3", isPlay: false, analyticsName: KPODCASTNAME2, currentTimePlay: 0)
        let podcast3 = WWMPodCastData.init(id: 1, title: KPODCAST3, duration: 3947, url_link: "https://mcdn.podbean.com/mf/play/pxueh7/Podcast_Sam_Branson_11th_July_2017_MP3_Master.mp3", isPlay: false, analyticsName: KPODCASTNAME3, currentTimePlay: 0)
        let podcast4 = WWMPodCastData.init(id: 1, title: KPODCAST4, duration: 1564, url_link: "https://mcdn.podbean.com/mf/player-preload/38pjwx/Podcast_with_Maddie_4th_July_2017_1_.mp3", isPlay: false, analyticsName: KPODCASTNAME4, currentTimePlay: 0)
        
        self.podData.append(podcast1)
        self.podData.append(podcast2)
        self.podData.append(podcast3)
        self.podData.append(podcast4)
        
        self.tableView.reloadData()
    }
    
    @IBAction func btnTimerClicked(_ sender: UIButton) {
        
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "TIMER", itemName: "")
        
        self.type = "timer"
        self.guided_type = ""
        WWMHelperClass.selectedType = "timer"
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.userData.type = "timer"
        WWMHelperClass.selectedType = "timer"
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }

    @IBAction func btnGuidedClicked(_ sender: UIButton) {
        self.xibCallGuided()
    }

    @IBAction func btnLearnClicked(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "LEARN", itemName: "")
        
        self.type = "learn"
        self.guided_type = ""
        WWMHelperClass.selectedType = "learn"
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }
    
    
    //MARK: popup for guided
    func xibCallGuided(){
        guideStart = UINib(nibName: "WWMGuidedStart", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMGuidedStart
        let window = UIApplication.shared.keyWindow!
        
        guideStart.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        guideStart.btnClose.addTarget(self, action: #selector(btnGuideCloseAction(_:)), for: .touchUpInside)
        guideStart.btnMoreInformation.addTarget(self, action: #selector(btnMoreInformationActions(_:)), for: .touchUpInside)
        guideStart.btnSpritual.addTarget(self, action: #selector(btnSpritualAction(_:)), for: .touchUpInside)
        guideStart.btnPractical.addTarget(self, action: #selector(btnPracticalAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(guideStart)
    }
    
    @IBAction func btnPracticalAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "GUIDED", itemName: "PRACTICAL")
        
        guided_type = "practical"
        self.type = "guided"
        WWMHelperClass.selectedType = "guided"
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.appPreference.setGuideType(value: self.guided_type)
        self.appPreference.setGuideTypeFor3DTouch(value: guided_type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }
    
    @IBAction func btnSpritualAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "GUIDED", itemName: "SPIRITUAL")
        
        guided_type = "spiritual"
        self.type = "guided"
        WWMHelperClass.selectedType = "guided"
        
        self.view.endEditing(true)
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.appPreference.setGuideType(value: self.guided_type)
        self.appPreference.setGuideTypeFor3DTouch(value: guided_type)
        
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }
    
    @IBAction func btnGuideCloseAction(_ sender: UIButton) {
        guideStart.removeFromSuperview()
    }
    
    @IBAction func btnMoreInformationActions(_ sender: UIButton) {
        guideStart.removeFromSuperview()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        vc.strUrl = URL_MOREINFO
        vc.strType = KMOREINFORMATION
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK:- API Calling
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"      : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : self.type,
            "guided_type"   : self.guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                
                print("result hometabvc meditation data... \(result)")
                print("success meditationdata api WWMHomeTabVC background thread")
                
                if let userProfile = result["userprofile"] as? [String:Any] {
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                    }
                }
             }
        }
    }
    
    
     func fetchMeditationHistDataFromDB() {
        
        self.data.removeAll()
         let meditationHistDB = WWMHelperClass.fetchDB(dbName: "DBMeditationHistory") as! [DBMeditationHistory]
         if meditationHistDB.count > 0 {
            var data = WWMMeditationHistoryListData()
            for dict in meditationHistDB {
                if let jsonResult = self.convertToDictionary(text: dict.data ?? "") {
                    data = WWMMeditationHistoryListData.init(json: jsonResult)
                    self.data.append(data)
                    
                    print("meditation history cart dict... \(dict)")
                }
            }
            
            if self.data.count > 0{
                    self.medHisViewHeightConstraint.constant = 416
                    self.lblMedHistoryText.textColor = UIColor.white
                    self.collectionView.reloadData()
                }else{
                    self.medHisViewHeightConstraint.constant = 0
                    self.lblMedHistoryText.textColor = UIColor.clear
                }
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationMeditationHistory"), object: nil)
         }else{
            print("no meditation list data...")
            self.medHisViewHeightConstraint.constant = 0
            self.lblMedHistoryText.textColor = UIColor.clear
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name("notificationMeditationHistory"), object: nil)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    @IBAction func btnPodcastShowAllClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMPodcastListVC") as! WWMPodcastListVC
        
        vc.podData = self.podData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBookBuyNowClicked(_ sender: UIButton) {
        // Analytics
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "BOOK", itemName: "BUY_NOW")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
        
        let url = self.appPreffrence.getOffers()
        print("url /.... \(url[0])")
        
        vc.strType = KBUYBOOK
        vc.strUrl = url[0] 
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension WWMHomeTabVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.data.count > 10{
            return 10
        }else{
           return self.data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "WWMHomeMedHistoryCVC", for: indexPath) as! WWMHomeMedHistoryCVC
        
            cell.layer.cornerRadius = 8
        
            cell.lblSubTitle.numberOfLines = 2
            cell.lblSubTitle.sizeToFit()
        
            if self.data[indexPath.row].type == "timer"{
                cell.lblTitle.text = kTIMER
                cell.lblSubTitle.text = kMEDITATIONSESSINO
                
                cell.heartLbl.isHidden = true
                cell.heartImg.isHidden = true
                cell.lblLTMStep.isHidden = true
                
                cell.imgTitle.image = UIImage(named: self.data[indexPath.row].timerImage)
        
            }else if self.data[indexPath.row].type == "learn"{
                cell.lblTitle.text = kLEARN
                cell.lblSubTitle.text = "\(self.data[indexPath.row].title)"
                
                cell.heartLbl.isHidden = true
                cell.heartImg.isHidden = true
                cell.lblLTMStep.isHidden = false
                
                cell.imgTitle.image = UIImage(named: "LTMBg")
                cell.lblLTMStep.text = "\(self.data[indexPath.row].level_id)"
            }else{
                cell.lblTitle.text = kGUIDED
                cell.lblSubTitle.text = "\(KMEDITATIONFOR) \(self.data[indexPath.row].title)"
                cell.lblLTMStep.isHidden = true
                
                cell.imgTitle.sd_setImage(with: URL(string: self.data[indexPath.row].image), placeholderImage: UIImage(named: "rectangle-1"))
                
                if self.data[indexPath.row].like < 1{
                    cell.heartLbl.isHidden = true
                    cell.heartImg.isHidden = true
                }else{
                    cell.heartLbl.isHidden = false
                    cell.heartImg.isHidden = false
                }
            }

            print("meditation history title... \(self.data[indexPath.row].title)")
            
            cell.heartLbl.text = "\(self.data[indexPath.row].like)"
        
            if self.data[indexPath.row].duration < 60 && self.data[indexPath.row].duration != 0{
                cell.lblMin.text = "\(self.data[indexPath.row].duration) sec"
            }else{
                print("duration..... \(self.data[indexPath.row].duration)")
                cell.lblMin.text = "\(Int(round(Double(self.data[indexPath.row].duration)/60.0))) min"
            }
            
        
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let date_completed = self.data[indexPath.row].date
            if date_completed != ""{
            let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                
            print("dateCompare.... \(dateCompare)")
            if dateCompare.0 == 1{
                //equal
                let sec: Int = Int("\(dateCompare.2)".replacingOccurrences(of:
                    "-", with: "")) ?? 0
                print("dateCompare.2... \(sec)")
                if sec < 60{
                    cell.lblHr.text = KJUSTNOW
                }else if sec < 3600{
                    cell.lblHr.text = "\(sec/60) m ago"
                }else{
                    cell.lblHr.text = "\(sec/3600) h ago"
                }
            }else{
                let daysText = "\(dateCompare.1) d ago".replacingOccurrences(of:
                    "-", with: "")
                cell.lblHr.text = daysText
                }
            }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 281)
    }
}

extension WWMHomeTabVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.podData.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMHomePodcastTVC") as! WWMHomePodcastTVC
        
        if indexPath.row == 2{
            cell.lineLbl.isHidden = true
        }else{
            cell.lineLbl.isHidden = false
        }
        
        cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
        cell.lblTitle.text = self.podData[indexPath.row].title
        let data = self.podData[indexPath.row]
        let duration = secondsToMinutesSeconds(second: data.duration)
        cell.lblTime.text = "\(duration)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height/3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
           let cell = self.tableView.cellForRow(at: indexPath) as! WWMHomePodcastTVC
           let data = self.podData[indexPath.row]

            // Analytics
           WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "PODCASTPLAY", itemName: data.analyticsName)
            
            if selectedAudio == "0"{
                data.currentTimePlay = 0
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    let playerItem = AVPlayerItem.init(url:URL.init(string: data.url_link)!)
                    self.player = AVPlayer(playerItem:playerItem)
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { time in
                    if self.player?.currentItem?.status == .readyToPlay {
                        let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                        print("currentTime... \(currentTime)")
                        let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
                        print("totalDuration... \(Int(duration) - Int(currentTime))")
                            
                        data.currentTimePlay = Int(duration) - Int(currentTime)
                        if data.currentTimePlay != 0{
                            let remainingDuration = self.secondsToMinutesSeconds(second: data.currentTimePlay)
                            cell.lblTime.text = "\(remainingDuration)"
                            print("remainingDuration... \(remainingDuration)")
                            print("indexPath... \(indexPath.row)")
                        }
                    }
                })
                
                self.selectedAudio = "1"
            }
                
           if !data.isPlay {
               cell.playPauseImg.image = UIImage(named: "pauseAudio")
               self.player?.play()
               data.isPlay = true
           }else{
               cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
               self.player?.pause()
               data.isPlay = false
           }
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! WWMHomePodcastTVC
        let data = self.podData[indexPath.row]
        data.currentTimePlay = 0
        
        let duration = secondsToMinutesSeconds(second: data.duration)
        cell.lblTime.text = "\(duration)"
        
        if data.isPlay {
            cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
            self.player?.pause()
            data.isPlay = false
        }
        
        self.selectedAudio = "0"
    }
    
    func podCastXib(index: Int){
        podcastMusicPlayerPopUp = UINib(nibName: "WWWMPodCastPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWWMPodCastPlayerView
        let window = UIApplication.shared.keyWindow!
        
        podcastMusicPlayerPopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        //podcastMusicPlayerPopUp.lblTitle.text = "Toggle Airplane mode"
        //podcastMusicPlayerPopUp.btnOK.layer.borderWidth = 2.0
        //podcastMusicPlayerPopUp.btnCross.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        podcastMusicPlayerPopUp.btnCross.addTarget(self, action: #selector(btnCrossAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnPrevious.addTarget(self, action: #selector(btnPreviousAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnBackword.addTarget(self, action: #selector(btnBackwordAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnPlayPause.addTarget(self, action: #selector(btnPlayPauseAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnForward.addTarget(self, action: #selector(btnForwardAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnNext.addTarget(self, action: #selector(btnNextAction(_:)), for: .touchUpInside)
        
        window.rootViewController?.view.addSubview(alertPopupView)
    }
    
    @IBAction func btnCrossAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnPreviousAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnBackwordAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnPlayPauseAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnForwardAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
}
