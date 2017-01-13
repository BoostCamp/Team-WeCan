//
//  CustomPlayViewController.swift
//  pitchPerfect
//
//  Created by Seungwook Jeong on 2017. 1. 13..
//  Copyright © 2017년 boostcamp. All rights reserved.
//

import UIKit

class CustomPlayViewController: UIViewController {

    @IBOutlet weak var pitchValueLabel: UILabel!
    @IBOutlet weak var rateValueLabel: UILabel!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var rateSlider: UISlider!
    
    @IBOutlet weak var echoSwitch: UISwitch!
    
    @IBOutlet weak var reverbSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pitchSliderMove(_ sender: AnyObject) {
        let pitchValue = pitchSlider.value
        pitchValueLabel.text = String(pitchValue)
    }

    @IBAction func rateSliderMove(_ sender: AnyObject) {
        let rateValue = rateSlider.value
        rateValueLabel.text = String(rateValue)
    }
    
    @IBAction func saveValue(_ sender: AnyObject) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
      
        
        
        appDelegate?.paramPitchValue = self.pitchSlider.value
        appDelegate?.paramRateValue = self.rateSlider.value
        appDelegate?.paramEcho = self.echoSwitch.isOn
        appDelegate?.paramReverb = self.reverbSwitch.isOn
        
        navigationController?.popViewController(animated: true)
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
