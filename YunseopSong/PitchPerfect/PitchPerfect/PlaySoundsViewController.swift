//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by mac on 2017. 1. 9..
//  Copyright © 2017년 song. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var resultView: UITextView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var resultGender: Int?
    var resultText: String?
    var totalTime: Double!
    var currentTime: Double! = 0
    var currentTimer: Timer!

    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        stopAudio()
    }
    
    @IBAction func pasueButtonPressed(_ sender: AnyObject) {
        pauseAudio()
    }
    
    @IBAction func playButtonPressed(_ sender: AnyObject) {
        playAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        if resultGender == 0 {
            genderButton.setImage(UIImage(named: "male.png"), for: UIControlState.normal)
        } else {
            genderButton.setImage(UIImage(named: "female.png"), for: UIControlState.normal)
        }
        resultView.text = "\"\(resultText!)\""


    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI(.notPlaying)
    }


}
