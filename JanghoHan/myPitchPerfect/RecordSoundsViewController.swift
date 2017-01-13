//
//  RecordSoundsViewController.swift
//  myPitchPerfect
//
//  Created by connect on 2017. 1. 11..
//  Copyright © 2017년 udacity. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK : Variables
    
    var audioRecorder: AVAudioRecorder!
    var timer = Timer()
    var time: Int = 0
    var pauseNow: Bool = false
    var timeRecordSelector: Selector = #selector(RecordSoundsViewController.updateRecordTime)
    
    // MARK : IBOutlet
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    
    // MARK : Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isHidden = true
        recordTimeLabel.isHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK : IBAction
    // called when record button clicked
    @IBAction func recordAudio(_ sender: Any) {
        recordingLabel.text = "now recording..."
        recordButton.isEnabled = false
        recordTimeLabel.isHidden = false
        stopButton.isHidden = false
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
            
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)

    }
    
    //called when stop button clicked
    @IBAction func stopRecording(_ sender: Any) {
        recordButton.isEnabled = true
        stopButton.isHidden = true
        recordTimeLabel.text = "00:00"
        time = 0
        timer.invalidate()
        recordingLabel.text = "Tab to Record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    // MARK : Functions
    //update recorded time 녹음 진행 시간
    func updateRecordTime(){
        time += 1
        let sec = time/100
        let mSec = time%100
        recordTimeLabel.text = String(sec)+":"+String(mSec)
            //convertTimeInterval12String(audioRecorder.currentTime)
    }
    
    //녹음 끝났을 때
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }else{
            print("recording was not successful")
        }
    }
    
    //다음 화면으로 전환해주는 역할
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
            
        }
    }
}

