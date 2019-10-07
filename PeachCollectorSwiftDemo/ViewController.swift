//
//  ViewController.swift
//  PeachCollectorSwiftDemo
//
//  Created by Rayan Arnaout on 25.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

import UIKit
import PeachCollector
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var audioButton: UIButton?
    
    let audioMetadata = ["type": PCMediaMetadataType.audio, "format": PCMediaMetadataFormat.live] as! [String : NSCopying]
    var audioContext = PeachCollectorContext.init()
    var audioProperties = PeachCollectorProperties.init()
    var isPlaying = false
    
    var player : AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let component = PeachCollectorContextComponent.init()
        component.type = "player"
        component.name = "AudioPlayer"
        component.version = "1.0"
        audioContext = PeachCollectorContext.init(mediaContextWithID: "recoA", component: component, appSectionID: "Demo/AudioPlayer", source: "Demo.reco")
        
        audioProperties.audioMode = .normal
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.logNotificationReceived), name: NSNotification.Name.PeachCollector, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }

        
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.play()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return .success
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "Peach Demo Audio"]
        
        let audioUrl = URL(string: "https://lyssna-cdn.sr.se/Isidor/EREG/sr_varmland/2019/05/37_rekordmanga_kvinnor_antag_21a9b7f_a192.m4a")
        player = AVPlayer.init(playerItem: AVPlayerItem.init(asset: AVURLAsset.init(url: audioUrl!)))
    }
    
    @objc func logNotificationReceived(notification: Notification)
    {
        let logString = notification.userInfo![PeachCollectorNotificationLogKey]
        print(logString ?? "")
    }
    
    @IBAction func sendRecommendationHit(sender: UIButton) {
    
        let carouselComponent = PeachCollectorContextComponent.init()
        carouselComponent.type = "Carousel"
        carouselComponent.name = "recoCarousel"
        carouselComponent.version = "1.0"
        PeachCollectorEvent.sendRecommendationHit(withID: "reco00", items: ["reco00", "reco01", "reco02", "reco03"], itemsDisplayed: 3, hit: 0, appSectionID: "news/videos", source: nil, component: carouselComponent)
      
    }
    
    
    @IBAction func audioButtonPressed(sender: UIButton) {
        if isPlaying {
            pause()
        }
        else {
            play()
        }
    }
    
    func play() {
        isPlaying = true
        player?.play()
        self.audioButton?.setTitle("Pause Background Audio", for: .normal)
        PeachCollectorEvent.sendMediaPlay(withID: "audio00", properties: self.audioProperties, context: self.audioContext, metadata: self.audioMetadata)
    }
    
    func pause() {
        isPlaying = false
        player?.pause()
        self.audioButton?.setTitle("Play Background Audio", for: .normal)
        PeachCollectorEvent.sendMediaPause(withID: "audio00", properties: self.audioProperties, context: self.audioContext, metadata: self.audioMetadata)
    }

}

