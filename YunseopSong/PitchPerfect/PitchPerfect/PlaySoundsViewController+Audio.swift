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

    enum PlayingState { case playing, notPlaying, pause, restart }

    // MARK: Audio Functions

    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
            self.totalTime = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate)
            totalTimeLabel.text = String(format: "%.2f", self.totalTime)

        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }

    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        currentTime = 0
        progressBar.setProgress(Float(0), animated: false)

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
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.renderProgress), userInfo: nil, repeats: true)
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        audioPlayerNode.play()
        
        
               
    }

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
        
        if let currentTimer = currentTimer {
            currentTimer.invalidate()
        }
        
        currentTime = totalTime
        progressLabel.text = String(format: "%.2f", self.totalTime)

        progressBar.setProgress(Float(1), animated: false)
        
        

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
            setStopButtonEnabled(true)
            playButton.isEnabled = false
        case .notPlaying:
            setPlayButtonsEnabled(true)
            setStopButtonEnabled(false)
            playButton.isEnabled = false

        case .pause:
            setPlayButtonsEnabled(false)
            playButton.isEnabled = true
            pauseButton.isEnabled = false
        case .restart:
            setPlayButtonsEnabled(false)
            playButton.isEnabled = false
            pauseButton.isEnabled = true

        }
    }

    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
    
    func setStopButtonEnabled(_ enabled: Bool) {
        stopButton.isEnabled = enabled
        pauseButton.isEnabled = enabled
        playButton.isEnabled = enabled
    }

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changePitch(_ pitch: Float) {
        if let audioPlayerNode = audioPlayerNode {
            let changeRatePitchNode = AVAudioUnitTimePitch()
            changeRatePitchNode.pitch = pitch
            audioEngine.attach(changeRatePitchNode)

            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }

        
        print(pitch)
    }
    
    
    func pauseAudio() {

        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.pause()
        }
        

        if let audioEngine = audioEngine {
            audioEngine.pause()
        }
        
        configureUI(.pause)

        
        
    }
    
    func playAudio() {
        if let lastRenderTime: AVAudioTime = self.audioPlayerNode.lastRenderTime{
            if let playerTime: AVAudioTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                audioPlayerNode.scheduleFile(audioFile, at: playerTime) {
                    
                    var delayInSeconds: Double = 0
                    
                    if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                        delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                    }
                    
                    self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
                    RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
                }
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        audioPlayerNode.play()
    }
    
    func renderProgress() {
        if audioPlayerNode.isPlaying {
            if let nodeTime: AVAudioTime = self.audioPlayerNode.lastRenderTime, let playerTime: AVAudioTime = self.audioPlayerNode.playerTime(forNodeTime: nodeTime) {
                self.currentTime = Double(playerTime.sampleTime) / Double(playerTime.sampleRate)
                
            }

            progressLabel.text = String(format: "%.2f", self.currentTime)
            progressBar.setProgress(Float(currentTime/totalTime), animated: true)

        }

       
    }
    
}
