//
//  WWMListenMantraVC.swift
//  Meditation
//
//  Created by Prema Negi on 16/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMListenMantraVC: WWMBaseViewController {

    @IBOutlet weak var playPauseBtn: UIButton!
    
    var player = AVPlayer()
    var mantraData: [WWMMantraData] = []
    var isPlay: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playPauseBtn.setImage(UIImage(named: "pauseAudio"), for: .normal)
        getMantrasAPI()
    }
    
    //MARK: API call
    func getMantrasAPI() {
        
       // WWMHelperClass.showLoaderAnimate(on: self.view)
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_MANTRAS, headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [[String: Any]]{
                    for json in data{
                        let mantraData = WWMMantraData.init(json: json)
                        self.mantraData.append(mantraData)
                    }
                }
                
                if self.mantraData.count > 0{
                    self.audioPlay(audio: self.mantraData[0].mantra_audio)
                }
                print("mantras.... \(result)")
                
            }else {
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                }
            }
          //  WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
    
    func audioPlay(audio: String){

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem.init(url:URL.init(string: (audio))!)
            self.player = AVPlayer(playerItem: playerItem)
                
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                
            self.player.play()
            self.isPlay = true
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMChooseMantraListVC") as! WWMChooseMantraListVC
        self.player.pause()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPlayPauseClicked(_ sender: UIButton) {
        if isPlay{
            self.playPauseBtn.setImage(UIImage(named: "play_Icon"), for: .normal)
            self.isPlay = false
            self.player.pause()
        }else{
            self.playPauseBtn.setImage(UIImage(named: "pauseAudio"), for: .normal)
            self.isPlay = true
            self.player.play()
        }
    }
}

extension WWMListenMantraVC: WWMChooseMantraListDelegate{
    func chooseAudio(audio: String) {
        self.audioPlay(audio: audio)
    }
}
