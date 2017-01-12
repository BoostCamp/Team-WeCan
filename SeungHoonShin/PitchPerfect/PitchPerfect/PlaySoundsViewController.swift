//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by 신승훈 on 2017. 1. 10..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var printTimer: Timer!
    
    var remainTime : TimeInterval = 0.0
    var audioFileTime : TimeInterval = 0.0
    
    var rate : Float!
    var pitch : Float!
    var echo : Bool!
    var reverb : Bool!
    
    enum ButtonType: Int{
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    // MARK: Outlets
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var remainTimeLabel:UILabel!
    @IBOutlet weak var durationProgreeeBar:UIProgressView!
    
    @IBOutlet weak var customStackView: UIStackView!
    @IBOutlet weak var customPlayButton: UIButton!
    @IBOutlet weak var customSwitch: UISwitch!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var echoSwitch: UISwitch!
    @IBOutlet weak var reverbSwitch: UISwitch!
    
    
    // Mark : Actions
    
    @IBAction func playSoundForButton(_ sender: UIButton){
        
        switch(ButtonType(rawValue: sender.tag)!){
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
    
    @IBAction func customPlayPressed(_ sender: UIButton){
        
        rate = powf(32, rateSlider.value)
        pitch = pitchSlider.value
        echo = echoSwitch.isOn
        reverb = reverbSwitch.isOn
        
        playSound(rate: rate, pitch: pitch, echo: echo, reverb: reverb)
        configureUI(.playing)
    }
    
    
    @IBAction func stopButtonPressed(_ sender: AnyObject){
        stopAudio()
    }
    
    
    @IBAction func customSwichChange(_ sender: UISwitch){
        
        if customSwitch.isOn {
            customPlayButton.isEnabled = true
            buttonStackView.isHidden = true
            customStackView.isHidden = false
            
        }else {
            customPlayButton.isEnabled = false
            buttonStackView.isHidden = false
            customStackView.isHidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()

        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        configureUI(.notPlaying)
        
        durationProgreeeBar.progress = 0
        customPlayButton.isEnabled = false
        customStackView.isHidden = true
        customPlayButton.isEnabled = false
    }
}
