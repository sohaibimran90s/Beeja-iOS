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

class WWMHomeTabVC: WWMBaseViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartedText: UILabel!
    @IBOutlet weak var lblIntroText: UILabel!
    @IBOutlet weak var imgGiftIcon: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var viewVideo: VideoView!
    @IBOutlet weak var viewVideoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPodcastShowAll: UIButton!
    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var backViewTableView: UIView!
    @IBOutlet weak var medHisViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var player: AVPlayer?
    let playerController = AVPlayerViewController()
    var yaxis: CGFloat = 540
    
    let dateFormatter = DateFormatter()
    var currentDateString: String = ""
    var currentDate: Date!

    var inviteGiftPopUp = WWMHomeGiftPopUp()
    var data: [WWMMeditationHistoryListData] = []
    var podData: [WWMPodCastData] = []
    
    var id: [Int] = [1, 1, 1, 1]
    var duration: [Int] = [4144, 1564, 3947, 3000]
    var podcastTitle: [String] = ["Will Williams Podcast with Howard Donald from Take That", "Will Williams Podcast with Madeleine Shaw", "", ""]

    //MARK:- Viewcontroller Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.viewVideoHeightConstraint.constant = yaxis
        self.getScreenSize()
        let attributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let attributeString = NSMutableAttributedString(string: "Show all",
                                                        attributes: attributes)
        btnPodcastShowAll.setAttributedTitle(attributeString, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.navigationController?.isNavigationBarHidden = true
        self.setNavigationBar(isShow: false, title: "")
        
        scrollView.setContentOffset(.zero, animated: true)
        
        self.lblName.alpha = 0
        self.lblStartedText.alpha = 0
        self.lblIntroText.alpha = 0
        self.imgPlayIcon.alpha = 0
        self.imgGiftIcon.alpha = 0
        
        self.meditationHistoryListAPI()
        self.animatedImg()
        self.animatedlblName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.lblName.center.y = self.lblName.center.y + 20
        self.lblStartedText.center.y = self.lblStartedText.center.y + 16
        self.lblIntroText.center.y = self.lblIntroText.center.y + 20
        self.imgPlayIcon.center.y = self.imgPlayIcon.center.y + 24
        
        self.introView.isHidden = false
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
        let videoURL = Bundle.main.url(forResource: "walkthough", withExtension: "mp4")
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        if let videoURL = videoURL {
            print("videourl... \(videoURL)")
            player = AVPlayer(url: videoURL)
            playerController.player = player
            present(playerController, animated: true){
                self.player?.play()
            }
        }
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification){
        playerController.dismiss(animated: true, completion: nil)
    }
    
    func inviteFriendsPopupAlert(){
        self.inviteGiftPopUp = UINib(nibName: "WWMHomeGiftPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMHomeGiftPopUp
        let window = UIApplication.shared.keyWindow!
        
        self.inviteGiftPopUp.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        self.inviteGiftPopUp.btnText.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
         self.inviteGiftPopUp.btnEmail.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
         self.inviteGiftPopUp.btnShare.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.inviteGiftPopUp.btnClose.addTarget(self, action: #selector(btnAlertCloseAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(inviteGiftPopUp)
    }
    
    @IBAction func btnGiftClicked(_ sender: UIButton) {
        self.inviteFriendsPopupAlert()
    }
    
    @objc func btnAlertCloseAction(_ sender: Any){
        self.inviteGiftPopUp.removeFromSuperview()
    }
    
    func podcastData(){
       let podcast1 = WWMPodCastData.init(id: 1, title: "Will Williams Podcast with Howard Donald from Take That", duration: 4144, url_link: "https://mcdn.podbean.com/mf/play/h38jdi/Podcast_with_Howard_Donald_6th_November_2017_MP3_Master.mp3", isPlay: false)
        let podcast2 = WWMPodCastData.init(id: 1, title: "Will Williams Podcast with Madeleine Shaw", duration: 1564, url_link: "https://mcdn.podbean.com/mf/player-preload/38pjwx/Podcast_with_Maddie_4th_July_2017_1_.mp3", isPlay: false)
        let podcast3 = WWMPodCastData.init(id: 1, title: "Will Williams Podcast with Sam Branson", duration: 3947, url_link: "https://mcdn.podbean.com/mf/play/pxueh7/Podcast_Sam_Branson_11th_July_2017_MP3_Master.mp3", isPlay: false)
        let podcast4 = WWMPodCastData.init(id: 1, title: "Will Williams Podcast with Jasmine Hemsley", duration: 3000, url_link: "https://mcdn.podbean.com/mf/play/35czi8/Podcast_with_Jasmine_Hemsley_MP3_Master.mp3", isPlay: false)
        
        self.podData.append(podcast1)
        self.podData.append(podcast2)
        self.podData.append(podcast3)
        self.podData.append(podcast4)
        
        self.tableView.reloadData()
    }
    
    func meditationHistoryListAPI() {
        
        WWMHelperClass.showLoaderAnimate(on: self.view)
        
        let param = ["user_id": self.appPreference.getUserID()]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MEDITATIONHISTORY+"?page=1", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [String: Any]{
                    if let records = data["records"] as? [[String: Any]]{
                        for dict in records{
                            let data = WWMMeditationHistoryListData(json: dict)
                            self.data.append(data)
                        }
                    }
                    
                    if self.data.count > 0{
                        self.medHisViewHeightConstraint.constant = 416
                        self.collectionView.reloadData()
                    }else{
                        self.medHisViewHeightConstraint.constant = 0
                    }
                }
                
                
                print("param....****** \(URL_MEDITATIONHISTORY+"/page=1")")
                print("param....****** \(param)")
                print("result....****** \(result)")
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    @IBAction func btnPodcastShowAllClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMPodcastListVC") as! WWMPodcastListVC
        
        vc.podData = self.podData
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WWMHomeTabVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "WWMHomeMedHistoryCVC", for: indexPath) as! WWMHomeMedHistoryCVC
        
        cell.layer.cornerRadius = 8
        
        if self.data[indexPath.row].image == ""{
            cell.imgTitle.image = UIImage(named: "rectangle-1")
        }else{
            cell.imgTitle.sd_setImage(with: URL(string: self.data[indexPath.row].image), placeholderImage: UIImage(named: "rectangle-1"))
        }

        cell.lblTitle.text = self.data[indexPath.row].title
        cell.lblSubTitle.text = "Meditation for \(self.data[indexPath.row].type)"
        cell.heartLbl.text = "\(self.data[indexPath.row].like)"
        cell.lblMin.text = "\(self.data[indexPath.row].duration/60) min"
        
        
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let expireDate = dateFormatter.date(from: self.data[indexPath.row].date) ?? self.currentDate
        print("expireDate***.. \(expireDate)")
        print("currentdate***.. \(self.currentDate)")
        print("date***.. \(self.data[indexPath.row].date)")
        let day =  Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: expireDate!).day ?? 0
        let hour =  Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: expireDate!).hour ?? 0
        let min =  Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: expireDate!).minute ?? 0
        let sec =  Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: expireDate!).second ?? 0
        print("day..... \(day) hour..... \(hour) min..... \(min) sec..... \(sec)")
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 281)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnStepListVC") as! WWMLearnStepListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WWMHomeTabVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.podData.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMHomePodcastTVC") as! WWMHomePodcastTVC
        
        cell.lblTitle.text = self.podData[indexPath.row].title
        let data = self.podData[indexPath.row]
        let duration = secondsToMinutesSeconds(second: data.duration)
        cell.lblTime.text = "\(duration)"
        
        let playerItem = AVPlayerItem.init(url:URL.init(string: data.url_link)!)
        data.player = AVPlayer.init(playerItem: playerItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height/3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! WWMHomePodcastTVC
        let data = self.podData[indexPath.row]
        
        if !data.isPlay {
            cell.playPauseImg.image = UIImage(named: "pauseAudio")
            data.player.play()
            data.isPlay = true
        }else{
            cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
            data.player.pause()
            data.isPlay = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! WWMHomePodcastTVC
        let data = self.podData[indexPath.row]
        
        if data.isPlay {
            cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
            data.player.pause()
            data.isPlay = false
        }
    }
}
