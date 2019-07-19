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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar(isShow: false, title: "")
        print("poddatacount..... \(podData)")
        
            self.tableView.delegate = self
            self.tableView.dataSource = self
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        for data in podData {
            if data.isPlay {
                data.player.pause()
            }
        }
        
        self.tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
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
        
        cell.lblTitle.text = self.podData[indexPath.row].title
        let data = self.podData[indexPath.row]
        let duration = secondsToMinutesSeconds(second: data.duration)
        cell.lblTime.text = "\(duration)"
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem.init(url:URL.init(string: data.url_link)!)
            data.player = AVPlayer(playerItem:playerItem)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if !data.isPlay {
            cell.playPauseImg.image = UIImage(named: "podcastPlayIcon")
        }else{
            cell.playPauseImg.image = UIImage(named: "pauseAudio")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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

