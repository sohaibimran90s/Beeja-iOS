//
//  AudioEngine.swift
//  MeditationDemo
//
//  Created by Ehsan on 10/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class WaveAudioEngine: NSObject {

    let audioEngine = AVAudioEngine()
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    private var silenceTs: Double = 0
    let settings = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1] as [String : Any]

    
     func startAudioEngine(audioView: AudioVisualizerView) {
    //        if let d = self.delegate {
    //            d.didStartRecording()
    //        }
    //
    //        self.recordingTs = NSDate().timeIntervalSince1970
    //        self.silenceTs = 0
    //
    //        do {
    //            let session = AVAudioSession.sharedInstance()
    //            try session.setCategory(.playAndRecord, mode: .default)
    //            try session.setActive(true)
    //        } catch let error as NSError {
    //            print(error.localizedDescription)
    //            return
    //        }
            
            let inputNode = self.audioEngine.inputNode
            guard let format = self.format() else {
                return
            }
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
                let level: Float = -50
                let length: UInt32 = 1024
                buffer.frameLength = length
                let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
                var value: Float = 0
                vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
                var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
                if average > 0 {
                    average = 0
                } else if average < -100 {
                    average = -100
                }
                let silent = average < level
                let ts = NSDate().timeIntervalSince1970
                if ts - self.renderTs > 0.1 {
                    let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                    let frame = floats.map({ (f) -> Int in
                        return Int(f * Float(Int16.max))
                    })
                    DispatchQueue.main.async {
                        self.renderTs = ts
                        let len = audioView.waveforms.count
                        for i in 0 ..< len {
                            let idx = ((frame.count - 1) * i) / len
                            let f: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
                            audioView.waveforms[i] = min(49, Int(f * 50))
                        }
                        audioView.active = !silent
                        audioView.setNeedsDisplay()
                    }
                }
            }
            do {
                self.audioEngine.prepare()
                try self.audioEngine.start()
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
        }

    
    
    private func format() -> AVAudioFormat? {
        let format = AVAudioFormat(settings: self.settings)
        return format
    }

    
         func stopAudioEngine() {
            
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioEngine.stop()
//            do {
//                try AVAudioSession.sharedInstance().setActive(false)
//            } catch  let error as NSError {
//                print(error.localizedDescription)
//                return
//            }
            
            
            //audioView.removeFromSuperview()
            //audioView = AudioVisualizerView()
            //setupAudioView()
        }


}
