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
    
    var player: AVPlayer?
    var mantraData: [WWMMantraData] = []
    var isPlay: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playPauseBtn.setImage(UIImage(named: "pauseAudio"), for: .normal)
        
        //getMantrasAPI()
        self.fetchMantrasDataFromDB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func fetchMantrasDataFromDB() {
        let mantrasDataDB = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
        if mantrasDataDB.count > 0 {
            print("mantrasDataDB.count WWMListenMantraVC... \(mantrasDataDB.count)")
            for dict in mantrasDataDB {
                if let jsonResult = self.convertToDictionary1(text: dict.data ?? "") {
                    let mantraData = WWMMantraData.init(json: jsonResult)
                    self.mantraData.append(mantraData)
                }
            }
            
            if self.mantraData.count > 0{
                self.audioPlay(audio: self.mantraData[0].mantra_audio)
            }
        }else{
            self.getMantrasAPI()
        }
    }
    
    //MARK: API call
    func getMantrasAPI() {
                
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_MANTRAS, context: "WWMListenMantraVC", headerType: kGETHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                if let data = result["data"] as? [[String: Any]]{
                    let mantrasData = WWMHelperClass.fetchDB(dbName: "DBMantras") as! [DBMantras]
                    if mantrasData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBMantras")
                    }
                    for dict in data{
                        
                        print("mantras result... \(result)")
                        print("listenmantravc getmantras api")
                        
                        
                        let dbMantrasData = WWMHelperClass.fetchEntity(dbName: "DBMantras") as! DBMantras
                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted)
                        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                        dbMantrasData.data = myString
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        print("timeInterval.... \(timeInterval)")
                        
                        dbMantrasData.last_time_stamp = "\(timeInterval)"
                        WWMHelperClass.saveDb()
                        
                        self.fetchMantrasDataFromDB()
                        
                    }
                }
                
            }else {
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
    
    func audioPlay(audio: String){

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem.init(url:URL.init(string: (audio))!)
            self.player = AVPlayer(playerItem: playerItem)
                
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                
            self.player?.play()
            self.isPlay = true
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMChooseMantraListVC") as! WWMChooseMantraListVC
        self.player?.pause()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPlayPauseClicked(_ sender: UIButton) {
        if isPlay{
            self.playPauseBtn.setImage(UIImage(named: "play_Icon"), for: .normal)
            self.isPlay = false
            self.player?.pause()
        }else{
            self.playPauseBtn.setImage(UIImage(named: "pauseAudio"), for: .normal)
            self.isPlay = true
            self.player?.play()
        }
    }
}

extension WWMListenMantraVC: WWMChooseMantraListDelegate{
    func chooseAudio(audio: String) {
        self.audioPlay(audio: audio)
    }
}
