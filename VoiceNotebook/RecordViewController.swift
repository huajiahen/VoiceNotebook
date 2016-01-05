//
//  RecordViewController.swift
//  VoiceNotebook
//
//  Created by huajiahen on 9/30/15.
//  Copyright © 2015 huajiahen. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    var recordFileName: String?
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        playButton.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        player?.stop()
        playButton.selected = false
    }
    
    
    @IBAction func startRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
        } catch let error {
            print(error)
            return
        }
        
        let recordSetting: [String: AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatAppleIMA4),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1
        ]
        
        recordFileName = "\(Int64(NSDate().timeIntervalSince1970)).caf"
        let recordFileURL = NSURL(string: recordFileName!, relativeToURL: documentsPathURL())
        
        recorder?.stop()
        do {
            recorder = try AVAudioRecorder(URL: recordFileURL!, settings: recordSetting)
        } catch let error {
            let alertViewController = UIAlertController(title: "Warning", message: "Audio Recorder Error", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertViewController, animated: true, completion: nil)
            print(error)
            return
        }
        
        recorder?.prepareToRecord()
        recorder?.meteringEnabled = true
        
        guard audioSession.inputAvailable else {
            let alertViewController = UIAlertController(title: "Warning", message: "Audio input not available", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertViewController, animated: true, completion: nil)
            return
        }
        
        recorder?.record()
        playButton.hidden = true
        recordButton.setTitle("Recording", forState: .Normal)
    }
    
    @IBAction func endRecord() {
        recorder?.stop()
        recordButton.setTitle("Record", forState: .Normal)
        playButton.hidden = false
    }
    
    @IBAction func play() {
        if player?.playing == true {
            player?.stop()
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(true)
            } catch let error {
                print(error)
                return
            }

            
            let recordFileURL = NSURL(string: recordFileName!, relativeToURL: documentsPathURL())
            do {
                player = try AVAudioPlayer(contentsOfURL: recordFileURL!)
                player?.delegate = self
                player?.play()
                playButton.setImage(UIImage(named: "StopIcon"), forState: .Normal)
            } catch let error {
                print(error)
            }
        }
    }
    
}

extension RecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "PlayIcon"), forState: .Normal)
    }
}