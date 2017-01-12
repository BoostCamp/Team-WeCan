//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by mac on 2016. 12. 27..
//  Copyright © 2016년 song. All rights reserved.
//

import UIKit
import AVFoundation
import NaverSpeech

let ClientID: String = "E3VVA7GT6wc_IuqrvLJH"

open class Languages {
    
    public init() {
        languages = [.korean: "Korean", .japanese: "Japanese", .english: "English", .simplifiedChinese: "Simplified Chinese"]
    }
    
    // MARK: - public
    open var count: Int {
        return self.languages.count
    }
    open var selectedLanguageString: String {
        if let language = self.languages[self._selectedLanguage] {
            return language
        }
        return "Korean"
    }
    open var selectedLanguage: NSKRecognizerLanguageCode {
        return self._selectedLanguage
    }
    
    open func languageString(at index: Int) -> String {
        if let code = NSKRecognizerLanguageCode(rawValue: index),
            let string = self.languages[code] {
            return string
        }
        return "Korean"
    }
    
    open func selectLanguage(at index: Int) {
        if let language = NSKRecognizerLanguageCode(rawValue: index) {
            self._selectedLanguage = language
        }
    }
    
    // MARK: - private
    fileprivate let languages: [NSKRecognizerLanguageCode: String]
    fileprivate var _selectedLanguage: NSKRecognizerLanguageCode = .korean
    
}



class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var naverButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recognitionResultLabel: UILabel!
    
    
    fileprivate let speechRecognizer: NSKRecognizer
    fileprivate let languages = Languages()

    
    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        /*
         *  NSKRecognizer를 초기화 하는데 필요한 NSKRecognizerConfiguration을 생성합니다.
         */
        let configuration = NSKRecognizerConfiguration(clientID: ClientID)
        configuration?.canQuestionDetected = true
        configuration?.epdType = .manual
        self.speechRecognizer = NSKRecognizer(configuration: configuration)
        super.init(coder: aDecoder)
        
        self.speechRecognizer.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
//        self.setupLanguagePicker()
        self.setupRecognitionButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func recodeAudio(_ sender: Any) {
        recordingLabel.text = "Recoding in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()

    }

    @IBAction func stopRecording(_ sender: Any) {
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tab to Record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    @IBAction func naverButtonPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            self.speechRecognizer.start(with: self.languages.selectedLanguage)
            self.statusLabel.text = "Connecting......."
        } else if sender.state == .ended {
            self.speechRecognizer.stop()
        }
    }
    
}

/*
 * NSKRecognizerDelegate protocol 구현부
 */
extension RecordSoundsViewController: NSKRecognizerDelegate {
    
    public func recognizerDidEnterReady(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Ready")
        
        self.statusLabel.text = "Connected"
        self.recognitionResultLabel.text = "Recognizing......"
        self.setRecognitionButtonTitle(withText: "Recognizing", color: .red)
        self.naverButton.isEnabled = true
    }
    
    public func recognizerDidDetectEndPoint(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: End point detected")
    }
    
    public func recognizerDidEnterInactive(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Inactive")
        
        self.setRecognitionButtonTitle(withText: "NAVER", color: .blue)
        self.naverButton.isEnabled = true
        self.statusLabel.text = "STATUS"
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
        print("Final result: \(aResult)")
        
        if let result = aResult.results.first as? String {
            self.recognitionResultLabel.text = "Result: " + result
        }
    }
}

fileprivate extension RecordSoundsViewController {

    
    func setupRecognitionButton() {
        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(naverButtonPressed(_:)))
        longpressRecognizer.minimumPressDuration = 1
        self.naverButton.addGestureRecognizer(longpressRecognizer)
    }
    
    func setRecognitionButtonTitle(withText text: String, color: UIColor) {
        self.naverButton.setTitle(text, for: .normal)
        self.naverButton.setTitleColor(color, for: .normal)
    }
}



