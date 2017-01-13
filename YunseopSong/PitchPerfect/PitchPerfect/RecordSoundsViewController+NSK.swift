//
//  RecordSoundsViewController+NSK.swift
//  PitchPerfect
//
//  Created by mac on 2017. 1. 12..
//  Copyright © 2017년 song. All rights reserved.
//
import UIKit
import Foundation
import NaverSpeech
import AVFoundation


extension RecordSoundsViewController: NSKRecognizerDelegate {
    
    public func recognizerDidEnterReady(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Ready")
        
        self.recordingLabel.text = "Connected"

        self.setRecognitionButtonTitle(withText: "NAVER is working...", color: .red)
        self.naverButton.isEnabled = true
    }
    
    public func recognizerDidDetectEndPoint(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: End point detected")
    }
    
    public func recognizerDidEnterInactive(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Inactive")
        
        self.setRecognitionButtonTitle(withText: "NAVER 음성인식 API", color: .green)
        self.naverButton.isEnabled = true
        self.recordingLabel.text = "Complete!"
        self.recordingLabel.textColor = .green
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
    }
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didRecordSpeechData aSpeechData: Data!) {
        print("Record speech data, data size: \(aSpeechData.count)")
        
    }
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceivePartialResult aResult: String!) {
        print("Partial result: \(aResult)")
        
        self.recognitionResultLabel.text = aResult
    }
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceiveError aError: Error!) {
        print("Error: \(aError)")
        
        self.setRecognitionButtonTitle(withText: "Record", color: .blue)
        self.naverButton.isEnabled = true
    }
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceive aResult: NSKRecognizedResult!) {
        print("Final result: \(aResult.gender.rawValue)")
        

        if let result = aResult.results.first as? String {
            resultText = result
            resultGender = aResult.gender.rawValue
            
            self.recognitionResultLabel.text = "Results : " + result
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)


        }
        

        
        
    }
}

extension RecordSoundsViewController {
    
    func setupRecognitionButton() {
        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recodeAudio(_:)))
        longpressRecognizer.minimumPressDuration = 1
        self.naverButton.addGestureRecognizer(longpressRecognizer)
    }
    
    func setRecognitionButtonTitle(withText text: String, color: UIColor) {
        self.naverButton.setTitle(text, for: .normal)
        self.naverButton.setTitleColor(color, for: .normal)
    }
}



