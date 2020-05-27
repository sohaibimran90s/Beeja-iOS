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
import FirebaseCrashlytics

class WWMHomeTabVC: WWMBaseViewController {

    @IBOutlet weak var lblMedHistoryText: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartedText: UILabel!
    @IBOutlet weak var lblIntroText: UILabel!
    @IBOutlet weak var imgGiftIcon: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var btnPlayVideo: UIButton!
    //@IBOutlet weak var viewVideo: VideoView!
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
    
    //banner outlet
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBanners: UITableView!
    var bannerDataArray: [[String: Any]] = []
    var bannerDescBool = false
    var bannerSelectdIndex = 0
    
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
    var selectedAudioIndex: Int = 0
    var currentValue: Int = 0
    var audioBool = false
    var currentTimePlay = 0
    var seekDuration: Float64 = 10
    
    //MARK:- Viewcontroller Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Crashlytics.sharedInstance().crash()
        self.podData = []
        self.podcastData()
        
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
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
        self.bannerAPI()
        timerCount = Int.random(in: 0...4)
        WWMHelperClass.timerCount = timerCount
        print("timercount... \(timerCount)")
        
        self.fetchMeditationHistDataFromDB()

        self.setNavigationBar(isShow: false, title: "")
        scrollView.setContentOffset(.zero, animated: true)
        //scrollView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)

        print("self.appPreffrence.getSessionAvailableData()... \(self.appPreffrence.getSessionAvailableData())")
        
        let fullname = self.appPreffrence.getUserName()
        let arrName = fullname.split(separator: " ")
        let firstName = arrName[0]
        
        if self.appPreffrence.getSessionAvailableData(){
            self.introView.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            //self.viewVideo.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            self.viewVideoHeightConstraint.constant = 110
            self.lblStartedText.text = KHOMELBL
            self.backImgVideo.image = UIImage(named: "")
            self.lblIntroText.isHidden = true
            self.imgGiftIcon.isHidden = true
            self.imgPlayIcon.isHidden = true
            
            let date = Date()// Aug 25, 2017, 11:55 AM
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            
            if hour < 12 {
                print("good morning")
                self.lblName.text = "\(kMORNING)\n\(firstName)!"
            }else if hour < 18 {
                print("good afternoon")
                self.lblName.text = "\(kAFTERNOON)\n\(firstName)!"
            }else{
                print("good evening")
                self.lblName.text = "\(kEVENING)\n\(firstName)!"
            }
        }else{
            self.lblName.text = "\(KWELCOME) \(firstName)!"
            self.lblStartedText.text = KHOMELBL1
            self.introView.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            //self.introView.backgroundColor = UIColor.clear
            self.backImgVideo.image = UIImage(named: "bg1")
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
        
        if audioBool{
            self.player?.pause()
            audioBool = false
            self.currentTimePlay = 0
        }
        
        self.player?.pause()
        self.stopPlayer()
        self.selectedAudio = "0"
        podcastMusicPlayerPopUp.removeFromSuperview()
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
    
    //banner api
    func bannerAPI() {
        
        self.bannerTopConstraint.constant = 0
        self.bannerHeightConstraint.constant = 1
        
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_BANNERS, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if let _ = result["success"] as? Bool {
                print("result")
                if let result = result["result"] as? [Any]{
                    self.appPreffrence.setBanners(value: result)
                    //print(self.appPreffrence.getBanners().count)
                    self.bannerData()
                }
            }
        }
        
        //banner top constraint 22
        //banner height constraint 185
        
        bannerData()
    }
    
    func bannerData(){
        self.bannerDataArray.removeAll()
        if self.appPreffrence.getBanners().count > 0{
            self.bannerTopConstraint.constant = 22
            for data in self.appPreffrence.getBanners() {
                
                if let dict = data as? [String: Any]{
                    if dict["description"] as? String != ""{
                        self.bannerDescBool = true
                    }else{
                        self.bannerDescBool = false
                    }
                    self.bannerDataArray.append(dict)

                }
                
                print("bannerDataArray \(bannerDataArray.count)")
                
                self.tableViewBanners.delegate = self
                self.tableViewBanners.dataSource = self
                self.tableViewBanners.reloadData()
            }
        }
    }
    
    @IBAction func btnVideoClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
        
        vc.value = "help"
        self.navigationController?.pushViewController(vc, animated: true)
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
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
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
        if tableView == tableViewBanners{
            //print(self.bannerDataArray.count)
            if self.bannerDataArray.count > 1{
                return self.bannerDataArray.count + 1
            }else{
                return self.bannerDataArray.count
            }
        }else{
           return self.podData.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewBanners{
            let cell = self.tableViewBanners.dequeueReusableCell(withIdentifier: "WWMBannerTVC") as! WWMBannerTVC
            
            //des: We've launched a new challenge to take your practise to the next level. Get set go!
            
            if self.bannerDataArray.count == 1{
                cell.lblChallTitle.text = (self.bannerDataArray[indexPath.row]["name"] as? String)?.capitalized
                cell.lblChallSubTitle.text = self.bannerDataArray[indexPath.row]["title"] as? String
                cell.lblChallDes.text = self.bannerDataArray[indexPath.row]["description"] as? String
                cell.imgView.sd_setImage(with: URL(string: self.bannerDataArray[indexPath.row]["image"] as? String ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))
                //bannerDescBool false means doesnt contain description
                if !self.bannerDescBool{
                    self.bannerHeightConstraint.constant = 84 * 1
                }else{
                    self.bannerHeightConstraint.constant = 126 * 1
                }
            }else{
                if indexPath.row == 0{
                    cell.lblChallTitle.text = "2 Challenges: In-Progress"
                    cell.lblChallSubTitle.text = "Tap to view details"
                    cell.lblChallDes.text = ""
                    
                    cell.lblChallTitle.textColor = UIColor.white
                    cell.imgWidthConstraint.constant = 0
                    cell.imgHeightConstraint.constant = 0
                    cell.stackViewLeadingConstraint.constant = 0
                }else{
                    cell.lblChallTitle.text = (self.bannerDataArray[indexPath.row - 1]["name"] as? String)?.capitalized
                    cell.lblChallSubTitle.text = self.bannerDataArray[indexPath.row - 1]["title"] as? String
                    cell.lblChallDes.text = self.bannerDataArray[indexPath.row - 1]["description"] as? String
                    cell.imgView.sd_setImage(with: URL(string: self.bannerDataArray[indexPath.row - 1]["image"] as? String ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))
                    
                    cell.lblChallTitle.textColor = UIColor(red: 240/255, green: 163/255, blue: 103/255, alpha: 1.0)
                    cell.imgWidthConstraint.constant = 40
                    cell.imgHeightConstraint.constant = 40
                    cell.stackViewLeadingConstraint.constant = 16
                }
                
                if self.bannerSelectdIndex == 0{
                    self.bannerHeightConstraint.constant = 84 * 1
                    cell.imgArrow.image = UIImage(named: "downArrow")
                }else{
                    self.bannerHeightConstraint.constant = 84 * 3
                    if indexPath.row == 0{
                        cell.imgArrow.image = UIImage(named: "upArrow")
                    }else{
                        cell.imgArrow.image = UIImage(named: "rightArrow_Icon")
                    }
                }
            }
            
            return cell
        }else{
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView{
            return self.tableView.frame.size.height/3
        }
        
        //reverse it when array comes from background
        if self.bannerDataArray.count == 1{
            if !self.bannerDescBool{
                return 84
            }else{
                return 126
            }
            
        }else{
            return 84
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
            if tableView == self.tableViewBanners{
                
                if self.bannerDataArray.count == 1{
                    self.bannerClicked(guided_type: self.bannerDataArray[indexPath.row]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerDataArray[indexPath.row]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerDataArray[indexPath.row]["emotion_id"] as? Int ?? 0)")
                }else{
                    
                    if indexPath.row == 0{
                        if self.bannerSelectdIndex == 0{
                            self.bannerSelectdIndex = 1
                        }else{
                            self.bannerSelectdIndex = 0
                        }
                        self.tableViewBanners.reloadData()
                    }else{
                        
                        self.bannerClicked(guided_type: self.bannerDataArray[indexPath.row - 1]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerDataArray[indexPath.row - 1]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerDataArray[indexPath.row - 1]["emotion_id"] as? Int ?? 0)")
                    }
                }
            }else{
                let data = self.podData[indexPath.row]
                
                // Analytics
                WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "PODCASTPLAY", itemName: data.analyticsName)
                
                self.selectedAudioIndex = indexPath.row
                self.podCastXib(index: self.selectedAudioIndex)
            }
            
        }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func bannerClicked(guided_type: String, guided_id: String, emotion_id: String) {
        WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "GUIDED", itemName: "PRACTICAL")
        
        self.appPreference.setType(value: "guided")
        self.appPreference.setGuideTypeFor3DTouch(value: "guided")
        WWMHelperClass.selectedType = "guided"
        self.view.endEditing(true)
        self.type = "guided"
        DispatchQueue.global(qos: .background).async {
            self.meditationApi()
        }
        
        if guided_type == "Challenge expired"{
            appPreference.set21ChallengeName(value: "Practical")
            self.appPreference.setGuideType(value: "Practical")
            if guided_id == "0"{
                print(emotion_id)
                self.retakeChallengeApi(guided_id: emotion_id)
            }else{
                print(guided_id)
                self.retakeChallengeApi(guided_id: guided_id)
            }
        }else{
            appPreference.set21ChallengeName(value: guided_type)
            self.appPreference.setGuideType(value: self.guided_type)
            self.reloadTabs21DaysController()
        }
    }
    
    func reloadTabs21DaysController(){
        self.navigationController?.isNavigationBarHidden = false
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationReloadGuidedTabs"), object: nil)
        
        if let tabController = self.tabBarController as? WWMTabBarVC {
            tabController.selectedIndex = 2
            for index in 0..<tabController.tabBar.items!.count {
                let item = tabController.tabBar.items![index]
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
                if index == 2 {
                    item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#00eba9")!], for: .normal)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    //banner scenario

    
    func podCastXib(index: Int){
        podcastMusicPlayerPopUp = UINib(nibName: "WWWMPodCastPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWWMPodCastPlayerView
        let window = UIApplication.shared.keyWindow!
        
        podcastMusicPlayerPopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        print("index... \(index)")
        
        self.selectedAudioIndex = index
        
        podcastMusicPlayerPopUp.slider.value = Float(currentTimePlay)
        podcastMusicPlayerPopUp.slider.setThumbImage(UIImage(named: "spinCircle"), for: .normal)
        podcastMusicPlayerPopUp.lblTitle.text = self.podData[index].title
        podcastMusicPlayerPopUp.btnCross.addTarget(self, action: #selector(btnCrossAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnBackword.addTarget(self, action: #selector(btnBackwordAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnPlayPause.addTarget(self, action: #selector(btnPlayPauseAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnForward.addTarget(self, action: #selector(btnForwardAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnPrevious.addTarget(self, action: #selector(btnPreviousAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.slider.setThumbImage(UIImage(named: "spinCircle"), for: .highlighted)
        podcastMusicPlayerPopUp.slider.addTarget(self, action: #selector(sliderAction(_:)), for: .touchUpInside)
        podcastMusicPlayerPopUp.btnNext.addTarget(self, action: #selector(btnNextAction(_:)), for: .touchUpInside)
        
        if self.selectedAudioIndex <= 0{
            podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = false
            podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img"), for: .normal)
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
        }else if self.selectedAudioIndex == self.podData.count - 2{
            podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
            podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
        }else{
            podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
            podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
        }
        
        playPauseAudio(index: index)
        
        window.rootViewController?.view.addSubview(podcastMusicPlayerPopUp)
    }
    
    
    @IBAction func sliderAction(_ sender: Any) {
        print("podcastMusicPlayerPopUp.slider.currentValue... \(podcastMusicPlayerPopUp.slider.value)")
        
        if self.player == nil{
            return
        }
        
        let seconds1: Int64 = Int64(podcastMusicPlayerPopUp.slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds1, timescale: 1)
        
        player?.pause()
        DispatchQueue.main.async {
            self.player!.seek(to: targetTime)
            
            if !self.audioBool {
                self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
                self.player?.pause()
            }else{
                self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_pause"), for: .normal)
                self.player?.play()
            }
        }
    }
    
    @IBAction func btnCrossAction(_ sender: Any) {
        if audioBool {
            self.player?.pause()
            audioBool = false
            self.currentTimePlay = 0
        }
        
        self.player?.pause()
        self.stopPlayer()
        self.selectedAudio = "0"
        podcastMusicPlayerPopUp.removeFromSuperview()
    }
    
    @IBAction func btnPreviousAction(_ sender: Any) {
        
        podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
        podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
        
        self.selectedAudioIndex = self.selectedAudioIndex - 1
        self.audioBool = false
        self.selectedAudio = "0"
        self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
        
        if self.selectedAudioIndex <= 0{
            podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = false
            podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img"), for: .normal)
            self.selectedAudioIndex = 0
            self.playPauseAudio(index: self.selectedAudioIndex)
        }else{
            self.currentTimePlay = 0
            podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
            self.podcastMusicPlayerPopUp.slider.value = Float(currentTimePlay)
            self.selectedAudio = "0"
            podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
            podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
            self.playPauseAudio(index: self.selectedAudioIndex)
        }
        podcastMusicPlayerPopUp.lblTitle.text = self.podData[self.selectedAudioIndex].title
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        
        podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
        podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
        
        self.audioBool = false
        self.selectedAudioIndex = self.selectedAudioIndex + 1
        print("self.selectedAudioIndex next... \(self.selectedAudioIndex) self.podData.count... \(self.podData.count - 2)")
        self.selectedAudio = "0"
        self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
        if self.selectedAudioIndex == self.podData.count - 2{
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
            self.selectedAudioIndex = self.podData.count - 2
            self.playPauseAudio(index: self.selectedAudioIndex)
        }else{
            self.currentTimePlay = 0
            podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
            self.podcastMusicPlayerPopUp.slider.value = Float(currentTimePlay)
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
            self.playPauseAudio(index: self.selectedAudioIndex)
        }
        
        podcastMusicPlayerPopUp.lblTitle.text = self.podData[self.selectedAudioIndex].title
    }
    
    @IBAction func btnPlayPauseAction(_ sender: Any) {
        self.playPauseAudio(index: self.selectedAudioIndex)
    }
    
    @IBAction func btnForwardAction(_ sender: Any) {
        if self.player == nil{
            return
        }
        if let duration = self.player!.currentItem?.duration {
        let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
        let newTime = playerCurrentTime + self.seekDuration
        if newTime < CMTimeGetSeconds(duration){
            let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player!.seek(to: selectedTime)
        }
        player?.pause()
        if !self.audioBool {
            self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
            self.player?.pause()
        }else{
            self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_pause"), for: .normal)
            self.player?.play()
        }
        }
    }

    @IBAction func btnBackwordAction(_ sender: Any) {
        if player == nil{
            return
        }
        let playerCurrenTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrenTime - self.seekDuration
        if newTime < 0{
            newTime = 0
        }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        if !self.audioBool {
            self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
            self.player?.pause()
        }else{
            self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_pause"), for: .normal)
            self.player?.play()
        }
    }
    
    func playPauseAudio(index: Int){
        if selectedAudio == "0"{
            self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
            currentTimePlay = 0
            self.podcastMusicPlayerPopUp.lblTitle.text = self.podData[index].title
            self.podcastMusicPlayerPopUp.slider.value = Float(currentTimePlay)
            
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    let playerItem = AVPlayerItem.init(url:URL.init(string: self.podData[index].url_link)!)
                    self.player = AVPlayer(playerItem:playerItem)
                }catch let error as NSError {
                    print(error.localizedDescription)
                }
        
                self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { time in
                    if self.player?.currentItem?.status == .readyToPlay {
                    let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                    print("currentTime... \(currentTime)")
                    let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
                    print("totalDuration... \(Int(duration) - Int(currentTime))")
                    self.podcastMusicPlayerPopUp.lblEndTime.text = "\(self.secondsToMinutesSeconds(second: Int(duration)))"
                    self.currentTimePlay = Int(currentTime)
                    self.podcastMusicPlayerPopUp.slider.maximumValue = Float(Int(duration))
                    self.podcastMusicPlayerPopUp.slider.value = Float(currentTime)
                    if self.currentTimePlay != 0{
                        let remainingDuration = self.secondsToMinutesSeconds(second: self.currentTimePlay)
                        self.podcastMusicPlayerPopUp.lblStartTime.text = "\(remainingDuration)"
                        print("remainingDuration... \(remainingDuration)")
                        print("indexPath... \(index)")
                        
                        if self.podcastMusicPlayerPopUp.lblStartTime.text == self.podcastMusicPlayerPopUp.lblEndTime.text{
                            self.selectedAudio = "0"
                            self.audioBool = false
                            self.selectedAudioIndex = self.selectedAudioIndex + 1
                            if self.selectedAudioIndex < self.podData.count - 2{
                                self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
                                self.podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
                                self.podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
                                self.playPauseAudio(index: self.selectedAudioIndex)
                            }else if self.selectedAudioIndex == self.podData.count - 2{
                                self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
                                self.selectedAudioIndex = self.podData.count - 2
                                self.playPauseAudio(index: self.selectedAudioIndex)
                                //self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
                            }else if self.selectedAudioIndex > self.podData.count - 2{
                                self.selectedAudioIndex = self.podData.count - 2
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
                                self.podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
                            }else{
                                self.podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
                                self.podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
                            }
                            print("self.selectedAudioIndex+++++ \(self.selectedAudioIndex)")

                        }
                    }
                }
            })
                self.selectedAudio = "1"
        }
        
        if !audioBool {
            podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_pause"), for: .normal)
            self.player?.play()
            audioBool = true
        }else{
            podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "white_play"), for: .normal)
            self.player?.pause()
            audioBool = false
        }
    }
}

extension WWMHomeTabVC{
        
    func retakeChallengeApi(guided_id: String) {
        self.view.endEditing(true)
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "user_id"       : self.appPreference.getUserID(),
            "guided_id"     : guided_id
            ] as [String : Any]
        
        print("retakeChallenge param... \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_RETAKE, context: "WWM21DayChallengeVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                print("retake api... \(result)")
                self.getGuidedListAPI()
            }else {
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
        }
    }
    
    func getGuidedListAPI() {

        let param = ["user_id":self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_GETGUIDEDDATA, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let _ = result["success"] as? Bool {
                    print("success guidedList hometabVC... getGuidedListAPI \(result)")
                    WWMHelperClass.hideLoaderAnimate(on: self.view)
                    self.appPreference.set21ChallengeName(value: "21 Days challenge")
                    if let result = result["result"] as? [[String:Any]] {
                                                
                        let guidedData = WWMHelperClass.fetchDB(dbName: "DBGuidedData") as! [DBGuidedData]
                        if guidedData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedData")
                        }
                        
                        let guidedEmotionsData = WWMHelperClass.fetchDB(dbName: "DBGuidedEmotionsData") as! [DBGuidedEmotionsData]
                        if guidedEmotionsData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedEmotionsData")
                        }
                        
                        let guidedAudioData = WWMHelperClass.fetchDB(dbName: "DBGuidedAudioData") as! [DBGuidedAudioData]
                        if guidedAudioData.count > 0 {
                            WWMHelperClass.deletefromDb(dbName: "DBGuidedAudioData")
                        }
                        
                        for dict in result {
                            
                            if let meditation_list = dict["meditation_list"] as? [[String: Any]]{
                                
                                for meditationList in meditation_list {
                                    let dbGuidedData = WWMHelperClass.fetchEntity(dbName: "DBGuidedData") as! DBGuidedData
                                    
                                    let timeInterval = Int(Date().timeIntervalSince1970)
                                    
                                    dbGuidedData.last_time_stamp = "\(timeInterval)"
                                    dbGuidedData.cat_name = dict["name"] as? String
                                    
                                    if let id = meditationList["id"]{
                                        dbGuidedData.guided_id = "\(id)"
                                    }
                                    
                                    if let name = meditationList["name"] as? String{
                                        dbGuidedData.guided_name = name
                                    }
                                    
                                    if let meditation_type = meditationList["meditation_type"] as? String{
                                        dbGuidedData.meditation_type = meditation_type
                                    }
                                    
                                    if let guided_mode = meditationList["mode"] as? String{
                                        dbGuidedData.guided_mode = guided_mode
                                    }
                                    
                                    if let min_limit = meditationList["min_limit"] as? String{
                                        dbGuidedData.min_limit = min_limit
                                    }else{
                                        dbGuidedData.min_limit = "95"
                                    }
                                    
                                    if let max_limit = meditationList["max_limit"] as? String{
                                        dbGuidedData.max_limit = max_limit
                                    }else{
                                        dbGuidedData.max_limit = "98"
                                    }
                                    
                                    if let meditation_key = meditationList["meditation_key"] as? String{
                                        dbGuidedData.meditation_key = meditation_key
                                    }else{
                                        if let meditation_type = dict["meditation_type"] as? String{
                                            dbGuidedData.meditation_key = meditation_type
                                        }
                                    }
                                    
                                    if let complete_count = meditationList["complete_count"] as? Int{
                                        dbGuidedData.complete_count = "\(complete_count)"
                                    }else{
                                        dbGuidedData.complete_count = "0"
                                    }
                                    
                                    if let intro_url = meditationList["intro_url"] as? String{
                                        dbGuidedData.intro_url = intro_url
                                    }else{
                                        dbGuidedData.intro_url = ""
                                    }
                                    
                                    if let intro_completed = meditationList["intro_completed"] as? Bool{
                                        dbGuidedData.intro_completed = intro_completed
                                    }else{
                                        dbGuidedData.intro_completed = false
                                    }
                                    
                                    if let emotion_list = meditationList["emotion_list"] as? [[String: Any]]{
                                        for emotionsDict in emotion_list {
                                            
                                            let dbGuidedEmotionsData = WWMHelperClass.fetchEntity(dbName: "DBGuidedEmotionsData") as! DBGuidedEmotionsData
                                            
                                            if let id = meditationList["id"]{
                                                dbGuidedEmotionsData.guided_id = "\(id)"
                                            }
                                            
                                            if let emotion_id = emotionsDict["emotion_id"]{
                                                dbGuidedEmotionsData.emotion_id = "\(emotion_id)"
                                            }
                                            
                                            if let author_name = emotionsDict["author_name"]{
                                                dbGuidedEmotionsData.author_name = "\(author_name)"
                                            }
                                            
                                            if let emotion_image = emotionsDict["emotion_image"] as? String{
                                                dbGuidedEmotionsData.emotion_image = emotion_image
                                            }
                                            
                                            if let emotion_name = emotionsDict["emotion_name"] as? String{
                                                dbGuidedEmotionsData.emotion_name = emotion_name
                                            }
                                            
                                            if let intro_completed = emotionsDict["intro_completed"] as? Bool{
                                                dbGuidedEmotionsData.intro_completed = intro_completed
                                            }else{
                                                dbGuidedEmotionsData.intro_completed = false
                                            }
                                            
                                            if let tile_type = emotionsDict["tile_type"] as? String{
                                                dbGuidedEmotionsData.tile_type = tile_type
                                            }
                                            
                                            if let emotion_key = emotionsDict["emotion_key"] as? String{
                                                dbGuidedEmotionsData.emotion_key = emotion_key
                                            }
                                            
                                            if let emotion_body = emotionsDict["emotion_body"] as? String{
                                                dbGuidedEmotionsData.emotion_body = emotion_body
                                            }
                                            
                                            if let completed = emotionsDict["completed"] as? Bool{
                                                dbGuidedEmotionsData.completed = completed
                                            }
                                            
                                            if let completed_date = emotionsDict["completed_date"] as? String{
                                                dbGuidedEmotionsData.completed_date = completed_date
                                            }
                                            
                                            if let intro_url = emotionsDict["intro_url"] as? String{
                                                dbGuidedEmotionsData.intro_url = intro_url
                                            }else{
                                                dbGuidedEmotionsData.intro_url = ""
                                            }
                                            
                                            if let emotion_type = emotionsDict["emotion_type"] as? String{
                                                dbGuidedEmotionsData.emotion_type = emotion_type
                                            }else{
                                                dbGuidedEmotionsData.emotion_type = ""
                                            }
                                            
                                            if let audio_list = emotionsDict["audio_list"] as? [[String: Any]]{
                                                for audioDict in audio_list {
                                                    
                                                    let dbGuidedAudioData = WWMHelperClass.fetchEntity(dbName: "DBGuidedAudioData") as! DBGuidedAudioData
                                                    
                                                    if let emotion_id = emotionsDict["emotion_id"]{
                                                        dbGuidedAudioData.emotion_id = "\(emotion_id)"
                                                    }
                                                    
                                                    if let audio_id = audioDict["id"]{
                                                        dbGuidedAudioData.audio_id = "\(audio_id)"
                                                    }
                                                    
                                                    if let audio_image = audioDict["audio_image"] as? String{
                                                        dbGuidedAudioData.audio_image = audio_image
                                                    }
                                                    
                                                    if let audio_name = audioDict["audio_name"] as? String{
                                                        dbGuidedAudioData.audio_name = audio_name
                                                    }
                                                    
                                                    if let audio_url = audioDict["audio_url"] as? String{
                                                        dbGuidedAudioData.audio_url = audio_url
                                                    }
                                                    
                                                    if let author_name = audioDict["author_name"] as? String{
                                                        dbGuidedAudioData.author_name = author_name
                                                    }
                                                    
                                                    if let duration = audioDict["duration"]{
                                                        dbGuidedAudioData.duration = "\(duration)"
                                                    }
                                                    
                                                    if let paid = audioDict["paid"] as? Bool{
                                                        dbGuidedAudioData.paid = paid
                                                    }
                                                    
                                                    if let vote = audioDict["vote"] as? Bool{
                                                        dbGuidedAudioData.vote = vote
                                                    }
                                                    WWMHelperClass.saveDb()
                                                }
                                            }
                                            
                                            WWMHelperClass.saveDb()
                                            
                                        }
                                    }
                                }
                            }
                            
                            WWMHelperClass.saveDb()
                            self.reloadTabs21DaysController()
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationGuided"), object: nil)
                        print("guided data tabbarvc in background thread...")
                    }
                }
            }
            
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }//end guided api*
}
