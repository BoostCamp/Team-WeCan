//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState (raw values correspond to sender tags)
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    
    func setupAudio() {
        // initialize (recording) audio file
        // recordSoundViewController로 부터 전달받은 오디오 파일을 로드.
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
            remainTime = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate)
            printTime()
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }        
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
        
        
        // duration 구하긔!
        let nodeTime = audioPlayerNode.lastRenderTime!
        let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime)!

        
        var duration : TimeInterval
        if let rate = rate {
            duration = Double(audioFile.length - playerTime.sampleTime) / (playerTime.sampleRate * Double(rate) )
        }else{
            duration = Double(audioFile.length - playerTime.sampleTime) / (playerTime.sampleRate)
        }

        remainTime = duration
        audioFileTime = duration
        self.printTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(PlaySoundsViewController.printTime), userInfo: nil, repeats: true)
        RunLoop.main.add(self.printTimer, forMode: RunLoopMode.defaultRunLoopMode)
        
        
    }
    
    func printTime(){
        
        remainTime -= 0.1
        if remainTime <= 0{
            printTimer.invalidate()
            remainTimeLabel.text = "0.0s"
            
            durationProgreeeBar.progress = 1
            return
        }
        
        let intRemainTime = Int(remainTime * 10)
        remainTimeLabel.text = "\(intRemainTime / 10).\(intRemainTime % 10)s"
        
        let progress = 1 - Float((remainTime/audioFileTime))
        durationProgreeeBar.progress = progress
    }
    
//    func sPrintTime(time: TimeInterval){
//        let intTime = Int(time * 10)
//        remainTimeLabel.text = "\(intTime / 10).\(intTime % 10)s"
//    }
    
    func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
                        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        
        if let printTimer = printTimer {
            printTimer.invalidate()
            remainTimeLabel.text = "0.0s"
            durationProgreeeBar.progress = 1

        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions

    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
            customPlayButton.isEnabled = false
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
            if customSwitch.isOn{
                customPlayButton.isEnabled = true
            }
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
        
        customSwitch.isEnabled = enabled
        rateSlider.isEnabled = enabled
        pitchSlider.isEnabled = enabled
        echoSwitch.isEnabled = enabled
        reverbSwitch.isEnabled = enabled
    }

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
