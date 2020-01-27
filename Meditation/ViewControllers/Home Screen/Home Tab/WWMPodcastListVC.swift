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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        print("poddatacount..... \(podData)")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        for data in self.podData {
            if data.isPlay {
                self.player?.pause()
                data.isPlay = false
            }
        }
        
        self.player?.pause()
        self.stopPlayer()
        self.tableView.reloadData()
        
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
}

