//
//  PlaySoundsViewController.swift
//  myPitchPerfect
//
//  Created by connect on 2017. 1. 11..
//  Copyright © 2017년 udacity. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var changePitchSlider: UISlider!
    @IBOutlet weak var changeSpeedSlider: UISlider!
    @IBOutlet weak var playProgressView: UIProgressView!
    
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var pvTimer: Timer!
    var audioPlayer: AVAudioPlayer!
    var resumeTime: AVAudioTime!
    var renderTime: AVAudioTime!
    var duration: Float = 0.0
    var cntTime: Float = 0.0
    var changedRate: Float = 0.0
    
    let pivotRate: Float = 44100.0
    let maxSpeed : Float = 1.5
    let minSpeed : Float = 0.5
    let maxPitch : Float = 1000
    let minPitch : Float = -1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButton(_ sender: Any) {
        print("playButton clicked")
        startButton.isEnabled = false
        if !pauseButton.isEnabled && !stopButton.isEnabled{
            playSound(rate: changeSpeedSlider.value, pitch: changePitchSlider.value, echo: echoButton.isSelected, reverb: reverbButton.isSelected)
            changedRate = changeSpeedSlider.value
            configureUI(.playing)
        }else{
            resumeAudio(resumeTime: resumeTime)
        }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        stopAudio()
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        resumeTime = pauseAudio()
    }
    
    func initPlay(){
        configureUI(.notPlaying)
        setupAudio()
        changeSpeedSlider.maximumValue = maxSpeed
        changeSpeedSlider.minimumValue = minSpeed
        changeSpeedSlider.value = 1
        changePitchSlider.maximumValue = maxPitch
        changePitchSlider.minimumValue = minPitch
        changePitchSlider.value = 0
        playProgressView.progress = 0
        echoButton.isSelected = false
        reverbButton.isSelected = false

    }
    
    func updateRecordTime(){
        
    }
    
    @IBAction func changeSpeedSlider(_ sender: UISlider) {
    }

    @IBAction func changePitchSlider(_ sender: UISlider) {
    }

    @IBAction func echoButtonClicked(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
        
    }
    
    @IBAction func reverbButtonClicked(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
