//
//  WWMLearnOutroVC.swift
//  Meditation
//
//  Created by Prema Negi on 02/08/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMLearnOutroVC: WWMBaseViewController {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var beginTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var lblStep: UILabel!
    
    var player = AVPlayer()
    var isPlayComplete: Bool = false
    var isPlay: Bool = false
    
    var timer = Timer()
    
    var watched_duration: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblStep.text = "\(KSTEP) \(WWMHelperClass.step_id)"
        self.setupView()
    }
    
    func setupView(){
        self.slider.setThumbImage(UIImage(named: "spinCircle"), for: .normal)
        self.btnStart.layer.borderColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0).cgColor
        self.btnStart.isHidden = true
        self.slider.isUserInteractionEnabled = false
        
        self.btnReplay.setImage(UIImage(named: "pauseAudio"), for: .normal)
        
        print("outroaudio... \(WWMHelperClass.outro_audio)")
        self.audioPlay()
    }
    
    func audioPlay(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                let playerItem = AVPlayerItem.init(url:URL.init(string: (WWMHelperClass.outro_audio))!)
                self.player = AVPlayer(playerItem: playerItem)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                
                self.isPlay = true
                
                let duration = CMTimeGetSeconds((self.player.currentItem?.asset.duration)!)
                let duration1 = Int(round(duration))
                let totalAudioLength = self.secondToMinuteSecond(second : duration1)
                print("duration... \(duration)... duration1.... \(duration1)... totalAudioLength.... \(totalAudioLength)")
                
                self.endTimeLbl.text = "\(totalAudioLength)"
                self.beginTimeLbl.text = "00:00"
                self.slider.maximumValue = Float(duration1)
                self.slider.value = 0.0
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                
                self.player.play()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        let currentTime = CMTimeGetSeconds(self.player.currentTime())
        print("currentTime... \(currentTime)")
        self.slider.value = Float(currentTime)
        self.beginTimeLbl.text = "\(self.secondToMinuteSecond(second : Int(currentTime)))"
        
        if self.beginTimeLbl.text == self.endTimeLbl.text{
            self.timer.invalidate()
            if !self.isPlayComplete{
                self.beginTimeLbl.text = "00:00"
            }
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        self.btnStart.isHidden = false
        self.isPlayComplete = true
        self.btnReplay.setImage(UIImage(named: "replay"), for: .normal)
    }
    
    @IBAction func btnReplayClicked(_ sender: UIButton) {
        if !self.isPlayComplete{
            if isPlay{
                self.btnReplay.setImage(UIImage(named: "play_Icon"), for: .normal)
                self.isPlay = false
                self.player.pause()
            }else{
                self.btnReplay.setImage(UIImage(named: "pauseAudio"), for: .normal)
                self.isPlay = true
                self.player.play()
            }
            
        }else{
            self.btnReplay.setImage(UIImage(named: "pauseAudio"), for: .normal)
            self.isPlayComplete = false
            self.beginTimeLbl.text = "00:00"
            self.slider.minimumValue = 0.0
            self.audioPlay()
        }
    }
    
    @IBAction func btnBeginClicked(_ sender: UIButton) {
        self.player.pause()
        self.timer.invalidate()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnCongratsVC") as! WWMLearnCongratsVC
        
        WWMHelperClass.selectedType = "learn"
        vc.watched_duration = self.watched_duration
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
