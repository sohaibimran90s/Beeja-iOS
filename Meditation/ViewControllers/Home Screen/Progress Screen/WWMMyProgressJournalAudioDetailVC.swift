//
//  WWMMyProgressJournalAudioDetailVC.swift
//  Meditation
//
//  Created by Prashant Tayal on 16/07/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMMyProgressJournalAudioDetailVC: WWMBaseViewController {
    
    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UITextView!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var beginTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    
    var lblTitle: String = ""
    var lblDesc: String = ""
    var lblDateDay1: String = ""
    var lblDateMonth1: String = ""
    var lblWeekDayAndTime1: String = ""
    var arrAudio = [WWMJournalMediaData]()
    
    var player: AVPlayer?
    var isPlayComplete: Bool = false
    var isPlay: Bool = false
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        
        self.lblMeditationType.text = self.lblTitle
        self.lblJournalDesc.text = self.lblDesc
        self.lblDateDay.text = self.lblDateDay1
        self.lblDateMonth.text = self.lblDateMonth1
        self.lblWeekDayAndTime.text = self.lblWeekDayAndTime1
        
        
        let playerItem = AVPlayerItem.init(url:URL.init(string: self.arrAudio[0].name)!)
        self.player = AVPlayer(playerItem: playerItem)
        
        let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
        let duration1 = Int(round(duration))
        let totalAudioLength = self.secondToMinuteSecond(second : duration1)
        
        self.endTimeLbl.text = "\(totalAudioLength)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        stopPlayer()
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickPlayPauseButton() {
        btnStart.isSelected = !btnStart.isSelected
        if btnStart.isSelected {
            //start player
            btnStart.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
            audioPlay()
        }
        else {
            //stop player
            btnStart.setImage(UIImage(named: "play.png"), for: .normal)
            stopPlayer()
        }
    }
    
    func audioPlay(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                let playerItem = AVPlayerItem.init(url:URL.init(string: self.arrAudio[0].name)!)
                self.player = AVPlayer(playerItem: playerItem)
                
//                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                
                self.isPlay = true
                
                let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
                let duration1 = Int(round(duration))
                let totalAudioLength = self.secondToMinuteSecond(second : duration1)
                
                self.endTimeLbl.text = "\(totalAudioLength)"
                self.beginTimeLbl.text = "00:00"
                self.slider.maximumValue = Float(duration1)
                self.slider.value = 0.0
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                
                if self.beginTimeLbl.text == self.endTimeLbl.text{
                    self.beginTimeLbl.text = self.endTimeLbl.text
                    self.btnStart.isHidden = false
                    self.isPlayComplete = true
                }
                self.player?.play()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        let currentTime = CMTimeGetSeconds((self.player?.currentTime())!)
        //print("currentTime... \(currentTime)")
        self.slider.value = Float(currentTime)
        self.beginTimeLbl.text = "\(self.secondToMinuteSecond(second : Int(currentTime)))"
        
        if self.beginTimeLbl.text == self.endTimeLbl.text{
            self.timer.invalidate()
            if !self.isPlayComplete{
                self.beginTimeLbl.text = "00:00"
            }
        }
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
}
