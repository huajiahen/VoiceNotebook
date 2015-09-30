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
    
    override func viewWillAppear(animated: Bool) {
        recordButton.backgroundColor = UIColor.redColor()
        recordButton.setTitle("Record", forState: .Normal)
        recordButton.setTitle("Recording", forState: .Highlighted)

        playButton.backgroundColor = UIColor.greenColor()
        playButton.setTitle("Play", forState: .Normal)
        playButton.setTitle("Stop", forState: .Selected)

    }
    
    @IBAction func startRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
        
        recordFileName = String.init(format: "%i.caf", NSDate.init().timeIntervalSince1970)
        let recordFileURL = NSURL.init(string: recordFileName!, relativeToURL: documentsPathURL())
        
        recorder?.stop()
        do {
            recorder = try AVAudioRecorder.init(URL: recordFileURL!, settings: recordSetting)
        } catch let error {
            let alertViewController = UIAlertController.init(title: "Warning", message: "Audio Recorder Error", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertViewController, animated: true, completion: nil)
            print(error)
            return
        }
        
        recorder?.delegate = self
        recorder?.prepareToRecord()
        recorder?.meteringEnabled = true
        
        if !audioSession.inputAvailable {
            let alertViewController = UIAlertController.init(title: "Warning", message: "Audio input not available", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertViewController, animated: true, completion: nil)
            return
        }
        
        recorder?.record()
    }
    
    @IBAction func endRecord() {
        recorder?.stop()
    }
    
    @IBAction func play() {
        if player?.playing == true {
            player?.stop()
            playButton.selected = false
        } else {
            let recordFileURL = NSURL.init(string: recordFileName!, relativeToURL: documentsPathURL())
            do {
                player = try AVAudioPlayer.init(contentsOfURL: recordFileURL!)
            } catch let error {
                print(error)
                return
            }
            player?.play()
            playButton.selected = true
        }
    }
    
}

extension RecordViewController: AVAudioRecorderDelegate {
    
    
}