//
//  MemoListViewController.swift
//  VoiceNotebook
//
//  Created by huajiahen on 9/30/15.
//  Copyright © 2015 huajiahen. All rights reserved.
//

import UIKit
import AVFoundation

class MemoListViewController: UITableViewController {
    var memoList: [NSURL] = []
    var playingIndexPath: NSIndexPath?
    var player: AVAudioPlayer?
    let dateFormatter = NSDateFormatter.init()
    
    override func viewDidLoad() {
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        do {
            memoList = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsPathURL(), includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.init())
        } catch let error {
            print(error)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        player?.stop()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemoCell", forIndexPath: indexPath)
        var filename = memoList[indexPath.row].URLByDeletingPathExtension!.lastPathComponent!
        if let timestamp = Int(filename) {
            let date = NSDate.init(timeIntervalSince1970: Double(timestamp))
            filename = dateFormatter.stringFromDate(date)
        }
        cell.textLabel?.text = filename
        cell.detailTextLabel?.text = playingIndexPath == indexPath ? "Playing" : ""
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        player?.delegate = nil
        player?.stop()
        
        if indexPath == playingIndexPath {
            playingIndexPath = nil
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        } else {
            var indexPathsToReload: [NSIndexPath] = []
            if let playingIndexPath = playingIndexPath {
                indexPathsToReload.append(playingIndexPath)
            }
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(true)
                
                player = try AVAudioPlayer.init(contentsOfURL: memoList[indexPath.row])
                player?.delegate = self
                player?.play()
                playingIndexPath = indexPath
                indexPathsToReload.append(indexPath)
            } catch let error {
                print(error)
                playingIndexPath = nil
            }
            tableView.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Automatic)
        }
    }
    
}

extension MemoListViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if let indexPath = playingIndexPath {
            playingIndexPath = nil
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}
