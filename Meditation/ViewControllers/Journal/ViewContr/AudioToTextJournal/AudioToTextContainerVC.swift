//
//  AudioToTextContainerVC.swift
//  MeditationDemo
//
//  Created by Ehsan on 11/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

struct AudioToTextJournal {
    
    var caption: String?
    var transcribingText: String?
}

class AudioToTextContainerVC: UIViewController {

    @IBOutlet weak var captionField: UITextField!
    //@IBOutlet weak var tapToRecordLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var transcTextView: UITextView!
    @IBOutlet weak var recordBtn: UIButton!
    //@IBOutlet weak var play_btn_ref: UIButton!
    @IBOutlet weak var stopRecordBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var recordCtrBGView: UIView!

    
    //var audioRecorder: AVAudioRecorder!
    //var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var second = 60
    let saySomethingTxt = "Say something, I'm listening!"
    //var isAudioRecordingGranted: Bool!
    //var isRecording = false
    //var isResume = false
    //var isPlaying = false
    
    //var audioJournalArr : [AudioJournal] = []
    
    var audioView = AudioVisualizerView()
    let waveAudioEngine = WaveAudioEngine()
    
    let kDataManager = DataManager.sharedInstance
    let kSpeechPermissionMsg = "Don't have access to use your Speech recognization. Please allow it from the settings."
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.captionField.setLeftPaddingPoints(20)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopAudioEngineAndSpeechRecog(notification:)), name: Notification.Name(Constant.kNotificationInAudioToTextJournal), object: nil)
    }
        
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    //MARK: Events
    // When tab changed (Journal option). Check if recording is going on then stop.
    @objc func stopAudioEngineAndSpeechRecog(notification: Notification) {
        
        if self.audioEngine.isRunning {
            self.stopRecording()
        }
    }

    // Call this function from AddJournalVC upper tab option to select Journal
    func updateAudioToTextView() {
        
        self.overlayView.isHidden = (kDataManager.isPaidAc) ? true : false
        self.setupAudioWaveView()
        self.setupSpeechRecognizerPermission()
    }
    
    // Access Permission from user for Speech Recognization
    func setupSpeechRecognizerPermission() {
        
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
                
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
                
            default:
                print("default")

            }
            
            OperationQueue.main.addOperation() {
                //self.recordBtn.isEnabled = isButtonEnabled
                self.checkSpeechPermission(isGranted: isButtonEnabled)
            }
        }
    }
    
    func checkSpeechPermission(isGranted: Bool) {
        self.recordBtn.isEnabled = isGranted
        if (!isGranted) {
            Alert.alertWithTwoButton(title: "Opss!", message: kSpeechPermissionMsg,
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

    
    fileprivate func setupAudioWaveView() {
        audioView.frame = CGRect(x: 0, y: self.recordCtrBGView.frame.height - 30, width: self.recordCtrBGView.frame.width, height: 40)
        self.recordCtrBGView.addSubview(audioView)
    }

    // Call this function from AddJournalVC to remove overlay if already paid.
    func purchasedUpdate() {
        //kDataManager.isPaidAc = true
        self.overlayView.isHidden = (kDataManager.isPaidAc) ? true : false
    }
    
    // Timer for 1 minute
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioEngine.isRunning
        {
            second -= 1
            let totalTimeString = String(format: "00:00:%02d", second)
            self.timerLbl.text = totalTimeString
            if (second == 0) {
                self.stopRecording()
            }
        }
    }

    func stopAudioWave() {
        self.waveAudioEngine.stopAudioEngine()
        self.audioView.removeFromSuperview()
        self.audioView = AudioVisualizerView()
        setupAudioWaveView()
    }
    
    func stopRecording() {
        self.stopAudioWave()
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.meterTimer.invalidate()
        self.recordBtn.isEnabled = false
        self.updateRecordBtn(isRecording: false)
        self.second = 60
        self.timerLbl.text = "00:01:00"
    }
    
    // flag to update record/save button
    func updateRecordBtn(isRecording: Bool) {
        self.recordBtn.setImage(UIImage(named: (isRecording) ? "":"RecordIcon.png"), for: UIControl.State.normal)
        self.recordBtn.setTitle((isRecording) ? "Save":"", for: .normal)
        self.recordBtn.layer.borderWidth = (isRecording) ? 2 : 0
        self.recordBtn.layer.borderColor = UIColor.white.cgColor
        self.recordBtn.layer.cornerRadius = 20
    }
    
    
    func startRecording() {
        
        if self.recognitionTask != nil {  //1
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
//        guard let inputNode = audioEngine.inputNode else {
//            fatalError("Audio engine has no input node")
//        }  //4
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.transcTextView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
                self.transcTextView.isEditable = true
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()  //12
        
        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.transcTextView.text = saySomethingTxt
        self.transcTextView.textColor = UIColor.white
    }

    //MARK: IBAction
    @IBAction func recordAction(sender: UIButton) {
        
        if self.audioEngine.isRunning {
            self.stopRecording()
        }
        else {
            self.startRecording()
            self.waveAudioEngine.startAudioEngine(audioView: self.audioView)

            self.updateRecordBtn(isRecording: true)
            
            self.meterTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self,
                                              selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
        }
    }
    
    @IBAction func stopAndSaveRecordingAction(sender: UIButton) {
        
    }
    
    
    //MARK: API Call
    // Wrap data to send to server API
    func audioToTextJournalExperienceLog() -> AudioToTextJournal?{
            
        if (self.captionField.text == "") {
            Alert.alertWithOneButton(title: "", message: "Please add caption.", container: self) { (alert, index) in
            }
            return nil
        }
        
        if (self.transcTextView.text == saySomethingTxt) {
            Alert.alertWithOneButton(title: "", message: "You did not record anything.",
                                     container: self) { (alert, index) in
            }
            return nil
        }

        let journal = AudioToTextJournal(caption: self.captionField.text, transcribingText: self.transcTextView.text)
        return journal
    }
    
    
}


extension AudioToTextContainerVC: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
        } else {
            recordBtn.isEnabled = false
        }
    }

}
