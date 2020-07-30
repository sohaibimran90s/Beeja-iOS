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
    @IBOutlet weak var imgBackTCB: UIImageView!
    @IBOutlet weak var imgBackTLB: UIImageView!
    @IBOutlet weak var tableViewBannersHC: NSLayoutConstraint!
    @IBOutlet weak var tableViewBannersTC: NSLayoutConstraint!
    @IBOutlet weak var tableViewBanners: UITableView!
    @IBOutlet weak var tableViewCB: UITableView!
    @IBOutlet weak var tableViewContinueTC: NSLayoutConstraint!
    @IBOutlet weak var tableViewContinueHC: NSLayoutConstraint!
    @IBOutlet weak var viewSwitchTC: UIView!
    
    var bannerLaunchData: [[String: Any]] = []
    var bannerProgressData: [[String: Any]] = []
    var bannerSelectdIndex = 0
    var bannerSelectdIndex1 = 0
    
    var player: AVPlayer?
    let playerController = AVPlayerViewController()
    var yaxis: CGFloat = 540
    
    let dateFormatter = DateFormatter()
    var currentDateString: String = ""
    var currentDate: Date!

    var shareTheLovePopUp = WWMShareLovePopUp()
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
    
    var bannerLaunchHeight = 84
    
    //MARK:- Viewcontroller Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.podData = []
        self.podcastData()
        
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
        self.currentDateString = dateFormatter.string(from: Date())
        self.currentDate = dateFormatter.date(from: currentDateString)!
        self.setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationMeditationHistory(notification:)), name: Notification.Name("notificationMeditationHistory"), object: nil)
        
        self.bannerAPI()
    }
    
    func setupView(){
        self.backViewTableView.layer.cornerRadius = 8
        self.btnBuyNow.layer.borderWidth = 2
        self.btnBuyNow.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        
        
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: KSHOWALL,
                                                        attributes: attributes)
        btnPodcastShowAll.setAttributedTitle(attributeString, for: .normal)
    }
    
    @objc func notificationMeditationHistory(notification: Notification) {
        self.fetchMeditationHistDataFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //UIApplication.shared.isStatusBarHidden = true
        timerCount = Int.random(in: 0...4)
        WWMHelperClass.timerCount = timerCount
        //print("timercount... \(timerCount)")
        
        self.fetchMeditationHistDataFromDB()

        self.setNavigationBar(isShow: false, title: "")
        scrollView.setContentOffset(.zero, animated: true)

        //print("self.appPreffrence.getSessionAvailableData()... \(self.appPreffrence.getSessionAvailableData())")
        
        let fullname = self.appPreffrence.getUserName()
        let arrName = fullname.split(separator: " ")
        let firstName = arrName[0].localizedCapitalized
        self.setUpImage(firstName: firstName)
        
        self.lblName.alpha = 0
        self.lblStartedText.alpha = 0
        self.lblIntroText.alpha = 0
        self.imgPlayIcon.alpha = 0
        self.imgGiftIcon.alpha = 0
        
        self.selectedAudio = "0"
        
        //self.animatedImg()
        self.animatedlblName()
    }
    
    func setUpImage(firstName: String){
        self.introView.backgroundColor = UIColor(red: 0.0/255.0, green: 18.0/255.0, blue: 82.0/255.0, alpha: 1.0)
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
            //print("good morning")
            self.lblName.text = "\(kMORNING)\n\(firstName)"
        }else if hour < 18 {
            //print("good afternoon")
            self.lblName.text = "\(kHey)\n\(firstName)"
        }else{
            //print("good evening")
            self.lblName.text = "\(kHey)\n\(firstName)"
        }
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
        bannerSelectdIndex = 0
        bannerSelectdIndex1 = 0
        self.player?.pause()
        self.stopPlayer()
        self.selectedAudio = "0"
        podcastMusicPlayerPopUp.removeFromSuperview()
        
        bannerSelectdIndex = 0
        bannerSelectdIndex1 = 0
        self.tableViewCB.reloadData()
        self.tableViewBanners.reloadData()
    }
    
    //MARK: Stop Payer
    func stopPlayer() {
        if let play = self.player {
            //print("stopped")
            play.pause()
            self.player = nil
            //print("player deallocated")
        } else {
            //print("player was already deallocated")
        }
    }
    
    //MARK: get screen size for setting video according to device
    func getScreenSize(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //print("iPhone 5 or 5S or 5C")
                yaxis = 476
            case 1334:
                //print("iPhone 6/6S/7/8")
                yaxis = 570
            case 2208:
                //print("iPhone 6+/6S+/7+/8+")
                yaxis = 640
            case 2436:
                //print("iPhone X, XS")
                yaxis = 660
            case 2688:
                //print("iPhone XS Max")
                yaxis = 740
            case 1792:
                //print("iPhone XR")
                yaxis = 740
            default:
                //print("unknown")
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
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification){
        playerController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnGiftClicked(_ sender: UIButton) {
        self.giftPopupAlert()
    }
    
    func giftPopupAlert(){
        self.shareTheLovePopUp = UINib(nibName: "WWMShareLovePopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMShareLovePopUp
        let window = UIApplication.shared.keyWindow!
        
        self.shareTheLovePopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        self.shareTheLovePopUp.btnInviteFriends.layer.cornerRadius = 20
        self.shareTheLovePopUp.lblCopyCode.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.shareTheLovePopUp.lblCopyCode.layer.borderWidth = 1.0
        
        self.shareTheLovePopUp.btnClose.addTarget(self, action: #selector(btnAlertCloseAction(_:)), for: .touchUpInside)
        
        self.shareTheLovePopUp.btnInviteFriends.addTarget(self, action: #selector(btnInviteFriendsAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(shareTheLovePopUp)
    }
    
    @objc func btnAlertCloseAction(_ sender: Any){
        self.shareTheLovePopUp.removeFromSuperview()
    }
    
    @objc func btnInviteFriendsAction(_ sender: Any){

        self.shareTheLovePopUp.removeFromSuperview()
        self.shareData()
    }
    
    func shareData(){
        let image = UIImage.init(named: "upbeat")
        let text = KSHARETEXT
        let imageToShare = [text,image!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            //print(success ? "SUCCESS!" : "FAILURE")
            
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
        
        self.view.endEditing(true)
        self.appPreffrence.set21ChallengeName(value: "")
        self.appPreference.setIsProfileCompleted(value: true)
        self.appPreference.setType(value: self.type)
        self.userData.type = "timer"
        
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
        
        self.view.endEditing(true)
        self.appPreffrence.set21ChallengeName(value: "")
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
        self.appPreffrence.set21ChallengeName(value: "")
        
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
    
     func fetchMeditationHistDataFromDB() {
        
        self.data.removeAll()
         let meditationHistDB = WWMHelperClass.fetchDB(dbName: "DBMeditationHistory") as! [DBMeditationHistory]
         if meditationHistDB.count > 0 {
            var data = WWMMeditationHistoryListData()
            for dict in meditationHistDB {
                if let jsonResult = self.convertToDictionary(text: dict.data ?? "") {
                    data = WWMMeditationHistoryListData.init(json: jsonResult)
                    self.data.append(data)
                    
                    //print("meditation history cart dict... \(dict)")
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
            //print("no meditation list data...")
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
                //print(error.localizedDescription)
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
        //print("url /.... \(url[0])")
        
        vc.strType = KBUYBOOK
        vc.strUrl = url[0] 
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension WWMHomeTabVC{
    //banner api
    func bannerAPI() {
        
        self.tableViewBannersTC.constant = 0
        self.tableViewBannersHC.constant = 1
        self.tableViewBanners.isHidden = true
        self.tableViewContinueTC.constant = 0
        self.tableViewContinueHC.constant = 1
        self.tableViewCB.isHidden = true
        self.imgBackTCB.isHidden = true
        self.imgBackTLB.isHidden = true
        
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_BANNERS, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if let success = result["success"] as? Bool {
                //print("result")
                if success{
                    if let result = result["result"] as? [String: Any]{
                        self.appPreffrence.setBanners(value: result)
                        self.bannerData()
                    }
                }
            }
        }
    }
    
    func bannerData(){
        
        if let launchData = self.appPreffrence.getBanners()["launch"] as? [[String: Any]]{
            //print(launchData)
            self.bannerLaunchData.removeAll()
            if launchData.count > 0{
                self.tableViewBannersTC.constant = 22
                self.tableViewBannersHC.constant = 1
                self.tableViewBanners.isHidden = false
                self.imgBackTLB.isHidden = false
                
                for data in launchData {
                    self.bannerLaunchData.append(data)
                }
                
                self.tableViewBanners.delegate = self
                self.tableViewBanners.dataSource = self
                self.tableViewBanners.reloadData()
            }
        }
        
        if let progressData = self.appPreffrence.getBanners()["in_progress"] as? [[String: Any]]{
            //print(progressData)
            self.bannerProgressData.removeAll()
            if progressData.count > 0{
                self.tableViewContinueTC.constant = 8
                self.tableViewContinueHC.constant = 1
                self.tableViewCB.isHidden = false
                self.imgBackTCB.isHidden = false
                
                for data in progressData {
                    self.bannerProgressData.append(data)
                }
            
                self.tableViewCB.delegate = self
                self.tableViewCB.dataSource = self
                self.tableViewCB.reloadData()
            }
        }
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

            //print("meditation history title... \(self.data[indexPath.row].title)")
            
            cell.heartLbl.text = "\(self.data[indexPath.row].like)"
        
            if self.data[indexPath.row].duration < 60 && self.data[indexPath.row].duration != 0{
                cell.lblMin.text = "\(self.data[indexPath.row].duration) sec"
            }else{
                //print("duration..... \(self.data[indexPath.row].duration)")
                cell.lblMin.text = "\(Int(round(Double(self.data[indexPath.row].duration)/60.0))) min"
            }
            
        
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let date_completed = self.data[indexPath.row].date
            if date_completed != ""{
            let dateCompare = WWMHelperClass.dateComparison1(expiryDate: date_completed)
                
            //print("dateCompare.... \(dateCompare)")
            if dateCompare.0 == 1{
                //equal
                let sec: Int = Int("\(dateCompare.2)".replacingOccurrences(of:
                    "-", with: "")) ?? 0
                //print("dateCompare.2... \(sec)")
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
            //print("self.bannerLaunchData.count \(self.bannerLaunchData.count) self.bannerProgressData.count \(self.bannerProgressData.count)")
            if self.bannerLaunchData.count > 1{
                return self.bannerLaunchData.count + 1
            }else{
                return self.bannerLaunchData.count
            }
        }else if tableView == tableViewCB{
            //print(self.bannerDataArray.count)
            if self.bannerProgressData.count > 1{
                return self.bannerProgressData.count + 1
            }else{
                return self.bannerProgressData.count
            }
        }else{
           return self.podData.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewBanners{
            let cell = self.tableViewBanners.dequeueReusableCell(withIdentifier: "WWMBannerTVC") as! WWMBannerTVC
            
            //des: We've launched a new challenge to take your practise to the next level. Get set go!
            
            if self.bannerLaunchData.count == 1{
                cell.lblLine.isHidden = true
                cell.lblChallTitle.text = (self.bannerLaunchData[indexPath.row]["name"] as? String)?.capitalized
                cell.lblChallSubTitle.text = self.bannerLaunchData[indexPath.row]["title"] as? String
                cell.lblChallDes.text = self.bannerLaunchData[indexPath.row]["description"] as? String
                cell.imgView.sd_setImage(with: URL(string: self.bannerLaunchData[indexPath.row]["image"] as? String ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))

                self.tableViewBannersHC.constant = 130 * 1
            }else{
                if indexPath.row == 0{
                    cell.lblChallTitle.text = "\(self.bannerLaunchData.count) Challenges: Launched"
                    cell.lblChallSubTitle.text = "Tap to view details"
                    cell.lblChallDes.text = ""
                    cell.lblLine.isHidden = false
                    
                    cell.lblChallTitle.textColor = UIColor.white
                    cell.imgWidthConstraint.constant = 0
                    cell.imgHeightConstraint.constant = 0
                    cell.stackViewLeadingConstraint.constant = 0
                }else{
                    cell.lblLine.isHidden = true
                    cell.lblChallTitle.text = (self.bannerLaunchData[indexPath.row - 1]["name"] as? String)?.capitalized
                    cell.lblChallSubTitle.text = self.bannerLaunchData[indexPath.row - 1]["title"] as? String
                    cell.lblChallDes.text = self.bannerLaunchData[indexPath.row - 1]["description"] as? String
                    cell.imgView.sd_setImage(with: URL(string: self.bannerLaunchData[indexPath.row - 1]["image"] as? String ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))
                    
                    cell.lblChallTitle.textColor = UIColor(red: 240/255, green: 163/255, blue: 103/255, alpha: 1.0)
                    cell.imgWidthConstraint.constant = 40
                    cell.imgHeightConstraint.constant = 40
                    cell.stackViewLeadingConstraint.constant = 16
                }
                
                if self.bannerSelectdIndex == 0{
                    cell.lblLine.isHidden = true
                    self.tableViewBannersHC.constant = 84 * 1
                    cell.imgArrow.image = UIImage(named: "downArrow")
                }else{
                    self.tableViewBannersHC.constant = 84 + CGFloat(130 * (self.bannerLaunchData.count))
                    if indexPath.row == 0{
                        cell.imgArrow.image = UIImage(named: "upArrow")
                    }else{
                        cell.imgArrow.image = UIImage(named: "rightArrow_Icon")
                    }
                }
            }
            
            return cell
        }else if tableView == tableViewCB{
            
            let cell = self.tableViewCB.dequeueReusableCell(withIdentifier: "WWMBannerTVC") as! WWMBannerTVC
            
            if self.bannerProgressData.count == 1{
                cell.lblLine.isHidden = true
                cell.lblChallTitle.text = (self.bannerProgressData[indexPath.row]["name"] as? String)?.capitalized
                cell.lblChallSubTitle.text = self.bannerProgressData[indexPath.row]["title"] as? String
                cell.lblChallDes.text = self.bannerProgressData[indexPath.row]["description"] as? String
                cell.imgView.sd_setImage(with: URL(string: self.bannerProgressData[indexPath.row]["image"] as? String ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))
                
                    self.tableViewContinueHC.constant = 84 * 1
            }else{
                if indexPath.row == 0{
                    cell.lblLine.isHidden = false
                    cell.lblChallTitle.text = "\(self.bannerProgressData.count) Challenges: In-Progress"
                    cell.lblChallSubTitle.text = "Tap to view details"
                    cell.lblChallDes.text = ""
                    
                    cell.lblChallTitle.textColor = UIColor.white
                    cell.imgWidthConstraint.constant = 0
                    cell.imgHeightConstraint.constant = 0
                    cell.stackViewLeadingConstraint.constant = 0
                }else{
                    cell.lblLine.isHidden = true
                    cell.lblChallTitle.text = (self.bannerProgressData[indexPath.row - 1]["name"] as? String)?.capitalized
                    cell.lblChallSubTitle.text = self.bannerProgressData[indexPath.row - 1]["title"] as? String
                    cell.lblChallDes.text = self.bannerProgressData[indexPath.row - 1]["description"] as? String
                    cell.imgView.sd_setImage(with: URL(string: self.bannerProgressData[indexPath.row - 1]["image"] as? String ?? ""), placeholderImage: UIImage(named: "consecutive_days"))
                    
                    cell.lblChallTitle.textColor = UIColor(red: 240/255, green: 163/255, blue: 103/255, alpha: 1.0)
                    cell.imgWidthConstraint.constant = 40
                    cell.imgHeightConstraint.constant = 40
                    cell.stackViewLeadingConstraint.constant = 16
                }
                
                if self.bannerSelectdIndex1 == 0{
                    cell.lblLine.isHidden = true
                    self.tableViewContinueHC.constant = 84 * 1
                    cell.imgArrow.image = UIImage(named: "downArrow")
                }else{
                    self.tableViewContinueHC.constant = CGFloat(84 * (self.bannerProgressData.count + 1))
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
        if tableView == self.tableViewBanners{
            if self.bannerLaunchData.count > 1{
                if indexPath.row == 0{
                    bannerLaunchHeight = 84
                    return 84
                }else{
                    bannerLaunchHeight = 130
                    return 130
                }
            }else{
                bannerLaunchHeight = 130
                return 130
            }
        }
        
        if tableView == self.tableViewCB{
            return 84
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
            if tableView == self.tableViewBanners{
                
                if self.bannerLaunchData.count == 1{
                    self.bannerClicked(guided_type: self.bannerLaunchData[indexPath.row]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerLaunchData[indexPath.row]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerLaunchData[indexPath.row]["emotion_id"] as? Int ?? 0)", type: "launch", intro_video: self.bannerLaunchData[indexPath.row]["intro_video"] as? String ?? "")
                }else{
                    
                    if indexPath.row == 0{
                        if self.bannerSelectdIndex == 0{
                            self.bannerSelectdIndex = 1
                        }else{
                            self.bannerSelectdIndex = 0
                        }
                        self.tableViewBanners.reloadData()
                    }else{
                        
                        self.bannerClicked(guided_type: self.bannerLaunchData[indexPath.row - 1]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerLaunchData[indexPath.row - 1]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerLaunchData[indexPath.row - 1]["emotion_id"] as? Int ?? 0)", type: "launch", intro_video: self.bannerLaunchData[indexPath.row - 1]["intro_video"] as? String ?? "")
                    }
                }
            }else if tableView == self.tableViewCB{
                
                if self.bannerProgressData.count == 1{
                    self.bannerClicked(guided_type: self.bannerProgressData[indexPath.row]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerProgressData[indexPath.row]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerProgressData[indexPath.row]["emotion_id"] as? Int ?? 0)", type: "progress", intro_video: self.bannerProgressData[indexPath.row]["intro_video"] as? String ?? "")
                }else{
                    
                    if indexPath.row == 0{
                        if self.bannerSelectdIndex1 == 0{
                            self.bannerSelectdIndex1 = 1
                        }else{
                            self.bannerSelectdIndex1 = 0
                        }
                        self.tableViewCB.reloadData()
                    }else{
                        
                        self.bannerClicked(guided_type: self.bannerProgressData[indexPath.row - 1]["name"] as? String ?? "21 Days challenge", guided_id: "\(self.bannerProgressData[indexPath.row - 1]["guided_id"] as? Int ?? 0)", emotion_id: "\(self.bannerProgressData[indexPath.row - 1]["emotion_id"] as? Int ?? 0)", type: "progress", intro_video: self.bannerProgressData[indexPath.row - 1]["intro_video"] as? String ?? "")
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
    
    func bannerClicked(guided_type: String, guided_id: String, emotion_id: String, type: String, intro_video: String) {
        
        if type == "launch"{
            if guided_type == "30 Day Challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "30DAYS")
                let introURL = self.appPreffrence.get30DaysURL()
                if introURL != ""{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                    
                    vc.challenge_type = "30days"
                    vc.emotionKey = "30days"
                    vc.value = "30days"
                    vc.vc = "HomeTabVC"
                    self.navigationController?.pushViewController(vc, animated: false)
                    return
                }else{
                    self.type = "learn"
                    self.appPreference.setType(value: "learn")
                    self.appPreference.setGuideTypeFor3DTouch(value: "learn")
                    appPreference.set21ChallengeName(value: "30 Day Challenge")
                }
            }else if guided_type == "8 Weeks Challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "8WEEK")
                let introURL = self.appPreffrence.get8WeekURL()
                if introURL != ""{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWalkThoghVC") as! WWMWalkThoghVC
                    
                    vc.challenge_type = "8weeks"
                    vc.emotionKey = "8weeks"
                    vc.value = "8weeks"
                    vc.vc = "HomeTabVC"
                    self.navigationController?.pushViewController(vc, animated: false)
                    return
                }else{
                    self.type = "learn"
                    self.appPreference.setType(value: "learn")
                    self.appPreference.setGuideTypeFor3DTouch(value: "learn")
                    appPreference.set21ChallengeName(value: "8 Weeks Challenge")
                }
            }else if guided_type == "21 Days challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "21DAYS")
                self.type = "guided"
                self.appPreference.setType(value: "guided")
                self.appPreference.setGuideTypeFor3DTouch(value: "guided")
                appPreference.set21ChallengeName(value: "21 Days challenge")
            }else if guided_type == "7 Days challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "7DAYS")
                self.type = "guided"
                self.appPreference.setType(value: "guided")
                self.appPreference.setGuideTypeFor3DTouch(value: "guided")
                appPreference.set21ChallengeName(value: "7 Days challenge")
            }
            self.callHomeVC1()
            DispatchQueue.global(qos: .background).async {
                 self.meditationApi()
             }
        }else{
            if guided_type == "30 Day Challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "30DAYS")
                self.type = "learn"
                self.appPreference.setType(value: "learn")
                self.appPreference.setGuideTypeFor3DTouch(value: "learn")
                appPreference.set21ChallengeName(value: "30 Day Challenge")
            }else if guided_type == "8 Weeks Challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "8WEEK")
                self.type = "learn"
                self.appPreference.setType(value: "learn")
                self.appPreference.setGuideTypeFor3DTouch(value: "learn")
                appPreference.set21ChallengeName(value: "8 Weeks Challenge")
            }else if guided_type == "21 Days challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "21DAYS")
                self.type = "guided"
                self.appPreference.setType(value: "guided")
                self.appPreference.setGuideTypeFor3DTouch(value: "guided")
                appPreference.set21ChallengeName(value: "21 Days challenge")
            }else if guided_type == "7 Days challenge"{
                WWMHelperClass.sendEventAnalytics(contentType: "HOME_BANNER", itemId: "START", itemName: "7DAYS")
                self.type = "guided"
                self.appPreference.setType(value: "guided")
                self.appPreference.setGuideTypeFor3DTouch(value: "guided")
                appPreference.set21ChallengeName(value: "7 Days challenge")
            }
            self.callHomeVC1()
            DispatchQueue.global(qos: .background).async {
                 self.meditationApi()
             }
        }
    }//banner scenario
    
    func podCastXib(index: Int){
        podcastMusicPlayerPopUp = UINib(nibName: "WWWMPodCastPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWWMPodCastPlayerView
        let window = UIApplication.shared.keyWindow!
        
        podcastMusicPlayerPopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        //print("index... \(index)")
        
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
        //print("podcastMusicPlayerPopUp.slider.currentValue... \(podcastMusicPlayerPopUp.slider.value)")
        
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
        //print("self.selectedAudioIndex next... \(self.selectedAudioIndex) self.podData.count... \(self.podData.count - 2)")
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
                    //print("currentTime... \(currentTime)")
                    let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
                    //print("totalDuration... \(Int(duration) - Int(currentTime))")
                    self.podcastMusicPlayerPopUp.lblEndTime.text = "\(self.secondsToMinutesSeconds(second: Int(duration)))"
                    self.currentTimePlay = Int(currentTime)
                    self.podcastMusicPlayerPopUp.slider.maximumValue = Float(Int(duration))
                    self.podcastMusicPlayerPopUp.slider.value = Float(currentTime)
                    if self.currentTimePlay != 0{
                        let remainingDuration = self.secondsToMinutesSeconds(second: self.currentTimePlay)
                        self.podcastMusicPlayerPopUp.lblStartTime.text = "\(remainingDuration)"
                        //print("remainingDuration... \(remainingDuration) indexPath... \(index)")
                        
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
                            //print("self.selectedAudioIndex+++++ \(self.selectedAudioIndex)")

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
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"      : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : self.type,
            "guided_type"   : self.guided_type
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMHomeTabVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
        }
    }
}
