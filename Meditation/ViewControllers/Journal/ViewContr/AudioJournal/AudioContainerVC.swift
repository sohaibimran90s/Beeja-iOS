//
//  AudioContainerVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 8/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import AVFoundation


struct AudioJournal {
    var caption: String?
    var duration: String?
    var audioFilePath: URL?
}

class AudioContainerVC: UIViewController {

    @IBOutlet weak var audioTable: UITableView!
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var tapToRecordLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var recordPauseBtn: UIButton!
    @IBOutlet weak var play_btn_ref: UIButton!
    @IBOutlet weak var stopRecordBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var recordCtrBGView: UIView!

    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isResume = false
    var isPlaying = false
    
    var audioJournalArr : [AudioJournal] = []
    
    
    var audioView = AudioVisualizerView()
    let waveAudioEngine = WaveAudioEngine()
    let kDataManager = DataManager.sharedInstance
    let kAudioPermissionMsg = "Don't have access to use your microphone. Please allow it from the settings."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.captionField.setLeftPaddingPoints(20)
        
        self.stopRecordBtn.isHidden = true
        self.recordPauseBtn.isEnabled = false
        self.overlayView.isHidden = (kDataManager.isPaidAc) ? true : false
        self.stopRecordBtn.layer.borderColor = UIColor.white.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopAudioEngineAndRecorder(notification:)), name: Notification.Name(Constant.kNotificationInAudioJournal), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setupAudioWaveView()
    }
        
    //MARK: Events
    // When tab changed (Journal option). Check if recording is going on then stop.
    @objc func stopAudioEngineAndRecorder(notification: Notification) {
        
        if (isRecording) {
            self.deleteRecordingAction(sender: deleteBtn)
        }
    }
    
    // Call this function from AddJournalVC upper tab option to select Journal
    func updateAudioView() {
        self.overlayView.isHidden = (kDataManager.isPaidAc) ? true : false
        self.checkRecordPermission()

    }
    
    // Call this function from AddJournalVC to remove overlay if already paid.
    func purchasedUpdate() {
        self.overlayView.isHidden = (kDataManager.isPaidAc) ? true : false
    }
    
    fileprivate func setupAudioWaveView() {
        audioView.frame = CGRect(x: 0, y: self.recordCtrBGView.frame.height-30, width: self.recordCtrBGView.frame.width, height: 40)
        self.recordCtrBGView.addSubview(audioView)
    }

    func stopAudioWave() {
        self.waveAudioEngine.stopAudioEngine()
        self.audioView.removeFromSuperview()
        self.audioView = AudioVisualizerView()
        setupAudioWaveView()
    }
        
    // Access Permission from user for Recording
    func checkRecordPermission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            self.checkPermission()
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            self.checkPermission()
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                
                    OperationQueue.main.addOperation() {
                        self.checkPermission()
                    }
            })
            break
        default:
            break
        }
     }
    
    func checkPermission() {
        self.recordPauseBtn.isEnabled = self.isAudioRecordingGranted
        if (!self.isAudioRecordingGranted) {
            
            Alert.alertWithTwoButton(title: "Opss!", message: kAudioPermissionMsg,
                                     btn1: Constant.kCancel, btn2: Constant.kGoToSetting, container: self)
            { (alert, index) in
                
                if (index == 1) {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            //print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
            }
        }
    }

    // Initiate recorder.
    func setupRecorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                //try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setCategory(.playAndRecord, mode: .default)            
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                self.audioRecorder = try AVAudioRecorder(url: Utilities.getFileUrl(fileName: Constant.FILENAME), settings: settings)
                self.audioRecorder.delegate = self
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
            }
            catch let error {
                Alert.alertWithOneButton(title: "Error", message: error.localizedDescription, container: self) { (alert, index) in
                }
            }
        }
        else
        {
            Alert.alertWithOneButton(title: "Error", message: "Don't have access to use your microphone.", container: self)
            { (alert, index) in
            }
        }
    }

    // Timer for 5 minute.
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((0 - self.audioRecorder.currentTime / 60) / 60)
            let min = Int(5 - self.audioRecorder.currentTime / 60)
            let sec = Int(60 - self.audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            self.timerLbl.text = totalTimeString
            self.audioRecorder.updateMeters()
            
            if (min == 00 && sec == 00) {
                self.stopAndSaveRecordingAction(sender: stopRecordBtn)
            }
        }
    }

    func finishAudioRecording(success: Bool)
    {
        if success
        {
            self.stopAudioWave()
            self.audioRecorder.stop()
            self.audioRecorder = nil
            meterTimer.invalidate()
        }
        else
        {
            Alert.alertWithOneButton(title: "Error", message: "Recording failed.", container: self) { (alert, index) in
            }
        }
    }


    //MARK: IBAction
    @IBAction func recordPauseAction(sender: UIButton) {
        
        if (isRecording)
        {
            self.waveAudioEngine.stopAudioEngine()
            self.audioRecorder.pause()
            
            self.recordPauseBtn.setImage(UIImage(named: "RecordIcon.png"), for: .normal)
            //play_btn_ref.isEnabled = true
            isRecording = false
            isResume = true
            meterTimer.invalidate()
        }
        else
        {
            // setup recording once, second time it should resume only.
            if (!isResume){
                setupRecorder()
            }
            
            self.waveAudioEngine.startAudioEngine(audioView: self.audioView)
            self.audioRecorder.record()
            
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self,
                                              selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            self.recordPauseBtn.setImage(UIImage(named: "Pause.png"), for: .normal)
            //play_btn_ref.isEnabled = false
            isRecording = true
            self.stopRecordBtn.isHidden = false
            self.tapToRecordLbl.isHidden = true
            self.deleteBtn.isEnabled = true
        }
    }
    
    
    @IBAction func stopAndSaveRecordingAction(sender: UIButton) {
        
        if (self.captionField.text == "") {
            Alert.alertWithOneButton(title: "", message: "Please write caption.", container: self) { (alert, index) in
            }
            return
        }
        
        finishAudioRecording(success: true)
        
        self.recordPauseBtn.setImage(UIImage(named: "RecordIcon.png"), for: .normal)
        //play_btn_ref.isEnabled = true
        isRecording = false
        isResume = false
        self.stopRecordBtn.isHidden = true
        self.tapToRecordLbl.isHidden = false
        self.deleteBtn.isEnabled = false
        self.overlayView.isHidden = false
        
        self.saveAudio()
        self.timerLbl.text = "00:05:00"
        self.captionField.text = ""
        self.captionField.resignFirstResponder()
    }
    
    func saveAudio() {
        let durationStr = self.timerLbl.text
        let audioJournalObj = AudioJournal(caption: self.captionField.text ?? " ", duration: durationStr,
                                           audioFilePath: Utilities.getFileUrl(fileName: Constant.FILENAME))
        self.audioJournalArr.append(audioJournalObj)
        self.audioTable.reloadData()
    }
    
    /*func prepare_play()
    {
        do
        {
            self.audioPlayer = try AVAudioPlayer(contentsOf: Utilities.getFileUrl(fileName: Constant.FILENAME))
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }

    func playRecording()
    {
        if(isPlaying)
        {
            self.audioPlayer.stop()
            self.recordPauseBtn.isEnabled = true
            self.play_btn_ref.setTitle("Play", for: .normal)
            self.isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: Utilities.getFileUrl(fileName: Constant.FILENAME).path)
            {
                self.recordPauseBtn.isEnabled = false
                self.play_btn_ref.setTitle("pause", for: .normal)
                self.prepare_play()
                self.audioPlayer.play()
                self.isPlaying = true
            }
            else
            {
                Alert.alertWithOneButton(title: "Error", message: "Audio file is missing.", container: self) { (alert, index) in
                }
            }
        }
    }*/

    
    
    @IBAction func deleteRecordingAction(sender: UIButton) {
        
        finishAudioRecording(success: true)
        self.recordPauseBtn.setImage(UIImage(named: "RecordIcon.png"), for: .normal)
        isRecording = false
        isResume = false
        self.stopRecordBtn.isHidden = true
        self.tapToRecordLbl.isHidden = false
        self.deleteBtn.isEnabled = false
        self.timerLbl.text = "00:05:00"
        self.captionField.text = ""
    }
    
   
    //MARK: API Call
    // Wrap data to send to server API
    func audioJournalExperienceLog() -> AudioJournal?{
        
        if (self.audioJournalArr.count == 0) {
            Alert.alertWithOneButton(title: "", message: "No audio recorded.", container: self) { (alert, index) in
            }
            return nil
        }
                
        let audioJournal = self.audioJournalArr[0]
        return audioJournal
    }

}

extension AudioContainerVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioJournalArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCellIdentifier")! as! AudioCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.setAudioCell(audioObj: self.audioJournalArr[indexPath.row], index: indexPath.row)
        return cell
    }
}

extension AudioContainerVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //self.playRecording()
        if let cell:AudioCell = (tableView.cellForRow(at: indexPath) as? AudioCell){
            cell.didSelect()
        }

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
     
        if let cell:AudioCell = tableView.cellForRow(at: indexPath) as? AudioCell{
            cell.didDeselect()
        }
    }
}


extension AudioContainerVC: AudioContainerDelegate {
    
    func deleteAudio(index: Int) {
        self.overlayView.isHidden = true
        self.audioJournalArr.remove(at: index)
        self.audioTable.reloadData()
    }
}


extension AudioContainerVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        play_btn_ref.isEnabled = true
    }
}


extension AudioContainerVC: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        recordPauseBtn.isEnabled = true
    }

}


