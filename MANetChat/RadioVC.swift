//
//  RadioVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/26/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import AVFoundation

class RadioVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var tapToSwitchLabel: UILabel!
    @IBOutlet weak var noInternetConnection: UIView!
    
    private var url = "http://radiowink.wink.in.th"
    
    private var player:AVPlayer?
    private var isPlaying = false
    
    var reachability: Reachability?
    
    let channel = [ "FM 91",
                    "Wink Thailand",
                    "Radio Thai FM 88",
                    "City life 93.75"]
    
    let urls = ["FM 91":"http://122.155.16.48:8955",
                "Wink Thailand":"http://radiowink.wink.in.th",
                "Radio Thai FM 88":"http://prdonline.prd.go.th:8200/;stream.mp3",
                "City life 93.75":"http://onair.onair.network:8076"]

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try reachability = Reachability()
        } catch let error {
            print(error)
        }
        setPlayer(url: url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (reachability?.isReachable)! {
            noInternetConnection.isHidden = true
        } else {
            noInternetConnection.isHidden = false
        }
    }
    func setPlayer(url:String){
        player = AVPlayer(url: NSURL(string: url)! as URL)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        toggle()
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
            playButton.setTitle("Play", for: .normal)
        } else {
            play()
            playButton.setTitle("Pause", for: .normal)
        }
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
    @IBAction func channelButtonTapped(_ sender: Any) {
        pickerView.isHidden = false
        channelButton.isHidden = true
        tapToSwitchLabel.isHidden = true
        channelButton.setTitle("", for: .normal)
    }
    
    func setUp(){
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return channel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return channel[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(channel[row])
        setPlayer(url: urls[channel[row]]!)
        
        if isPlaying {
            player?.play()
        }
        
        channelButton.setTitle(channel[row], for: .normal)
        channelButton.setNeedsLayout()
        channelButton.isHidden = false
        tapToSwitchLabel.isHidden = false
        pickerView.isHidden = true
    }
}
