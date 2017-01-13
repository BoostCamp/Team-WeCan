//
//  PlaySoundsViewController.swift
//  pitchPerfect
//
//  Created by Seungwook Jeong on 2017. 1. 10..
//  Copyright © 2017년 boostcamp. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var recordedAudioURL : URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    var pitchValue: Float = 0
    var rateValue: Float = 1
    var isEcho: Bool = false
    var isReverb: Bool = false
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var customPlayButton: UIButton!
    
    
    enum ButtonType: Int {case slow=0, fast, chipmunk, vader, echo, reverb, custom}
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
        case .custom:
            playSound(rate: rateValue, pitch: pitchValue, echo: isEcho, reverb: isReverb)
        }
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject){
        stopAudio()
    }
    
    // MARK: - sharing audio file
    
    @IBAction func shareFile(_ sender: Any) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let url = [filePath]
       
        let activityViewController = UIActivityViewController(activityItems: url, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
   /*
    @IBAction func showAlert(_ sender: Any) {
        let alertController = UIAlertController(title : "Custom Vocie", message:"원하는 목소리를 만들어 보세요", preferredStyle: .actionSheet)
        
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        //customPlayButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI(.notPlaying)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
       
        if(appDelegate?.paramPitchValue) != nil {
            customPlayButton.isEnabled = true
            
        }
        if let rateVal = appDelegate?.paramRateValue {
            print(rateVal)
            rateValue = (appDelegate?.paramRateValue)!
        }
        if let pitchVal = appDelegate?.paramPitchValue {
            print(pitchVal)
            rateValue = (appDelegate?.paramRateValue)!
        }

        if let echoVal = appDelegate?.paramEcho {
            print(echoVal)
            isEcho = (appDelegate?.paramEcho)!
        }
        if let reverbVal = appDelegate?.paramReverb {
            print(reverbVal)
            isReverb = (appDelegate?.paramReverb)!
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
