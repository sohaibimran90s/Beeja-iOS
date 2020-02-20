//
//  WWMPodcastListVC.swift
//  Meditation
//
//  Created by Prema Negi on 15/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMPodcastListVC: WWMBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var podData: [WWMPodCastData] = []
    
    let reachable = Reachabilities()
    var selectedAudio = "0"
    var player: AVPlayer?
    var selectedAudioIndex: Int = 0
    var currentValue: Int = 0
    var audioBool = false
    var currentTimePlay = 0
    var seekDuration: Float64 = 10
    var podcastMusicPlayerPopUp = WWWMPodCastPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        print("poddatacount..... \(podData)")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if audioBool {
            self.player?.pause()
            audioBool = false
            self.currentTimePlay = 0
        }
        
        self.player?.pause()
        self.stopPlayer()
        self.selectedAudio = "0"
        podcastMusicPlayerPopUp.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
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
    
    func secondsToMinutesSeconds (second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
}

extension WWMPodcastListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.podData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMHomePodcastTVC") as! WWMHomePodcastTVC
        
        cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
        cell.lblTitle.text = self.podData[indexPath.row].title
        let data = self.podData[indexPath.row]
        let duration = secondsToMinutesSeconds(second: data.duration)
        cell.lblTime.text = "\(duration)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachable.isConnectedToNetwork() {
           let data = self.podData[indexPath.row]

            // Analytics
           WWMHelperClass.sendEventAnalytics(contentType: "HOMEPAGE", itemId: "PODCASTPLAY", itemName: data.analyticsName)
            
            self.selectedAudioIndex = indexPath.row
            self.podCastXib(index: self.selectedAudioIndex)
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
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
        }else if self.selectedAudioIndex == self.podData.count - 1{
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
            self.player?.play()
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
        print("self.selectedAudioIndex next... \(self.selectedAudioIndex) self.podData.count... \(self.podData.count - 1)")
        self.selectedAudio = "0"
        self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
        if self.selectedAudioIndex == self.podData.count - 1{
            podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
            podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
            self.selectedAudioIndex = self.podData.count - 1
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
        player?.play()
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
        player?.play()
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
                            if self.selectedAudioIndex < self.podData.count - 1{
                                self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
                                self.podcastMusicPlayerPopUp.btnPrevious.isUserInteractionEnabled = true
                                self.podcastMusicPlayerPopUp.btnPrevious.setImage(UIImage(named: "previous_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img1"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = true
                                self.playPauseAudio(index: self.selectedAudioIndex)
                            }else if self.selectedAudioIndex == self.podData.count - 1{
                                self.podcastMusicPlayerPopUp.lblStartTime.text = "00:00"
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
                                self.selectedAudioIndex = self.podData.count - 1
                                self.playPauseAudio(index: self.selectedAudioIndex)
                                //self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "play_Icon"), for: .normal)
                            }else if self.selectedAudioIndex > self.podData.count - 1{
                                self.selectedAudioIndex = self.podData.count - 1
                                self.podcastMusicPlayerPopUp.btnNext.isUserInteractionEnabled = false
                                self.podcastMusicPlayerPopUp.btnNext.setImage(UIImage(named: "next_img"), for: .normal)
                                self.podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "play_Icon"), for: .normal)
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
            podcastMusicPlayerPopUp.btnPlayPause.setImage(UIImage(named: "play_Icon"), for: .normal)
            self.player?.pause()
            audioBool = false
        }
    }

}

