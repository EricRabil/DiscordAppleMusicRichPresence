//
//  NowPlayingManager.swift
//  AppleMusicRPC
//
//  Created by Ayden Panhuyzen on 2020-05-16.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import SwordRPC

class NowPlayingManager {
    static let shared = NowPlayingManager()
    let rpc = PresentiConnection()
    
    private init() {
        rpc.delegate = self
        PreferencesManager.shared.delegate = self
    }
    
    @objc func setup() {
        guard !rpc.isConnected else { return }
        guard let token = PreferencesManager.shared.token else { return }
        rpc.token = token
        rpc.connect()
    }
    
    @objc private func updateState(force: Bool = false) {
        if NowPlaying.changed == false {
            print("no change. force: \(force)")
            if force == false { return }
        }
        
        let item = NowPlaying.current
        
        StatusItemManager.shared.iconState = .from(isPaused: item?.isPaused)
        
        guard let presence = getPresence(forItem: item) else {
            return
        }
        
        rpc.setPresence(presence)
    }
    
    private var timer: Timer? {
        didSet { oldValue?.invalidate() }
    }
    
    func getPresence(forItem item: NowPlaying?) -> PresentiPresence? {
        guard let item = item else { return nil }
        
        var presence = PresentiPresence()
        
//        presence.details = item.title
        let playbackStateText = item.isPaused ? "Paused" : "Playing"
//
        let trackInfoSecondaryLineItems = [item.artist, item.album].lazy
                            .compactMap({ $0 })
                            .filter({ !$0.isEmpty })
//
//        presence.state =  trackInfoSecondaryLineItems.isEmpty ? playbackStateText : trackInfoSecondaryLineItems.joined(separator: " — ")
//
//        if !item.isPaused {
//            presence.timestamps.start = item.startDate
//        }
//
//        presence.assets.largeImage = "music"
//        presence.assets.largeText = "Music app"
//
//        presence.assets.smallImage = item.isPaused ? "paused" : "playing"
//        presence.assets.smallText = playbackStateText
        
        presence.id = "com.aydenanderic.applemusic"
        
        presence.title = "Listening to Music"
        presence.isPaused = item.isPaused
        
        var texts = [PresentiText]()
        texts.append(PresentiText(text: trackInfoSecondaryLineItems.isEmpty ? playbackStateText : trackInfoSecondaryLineItems.joined(separator: " — ")))
        
        if !item.isPaused {
//            presence.timestamps = PresentiTimeRange(start: item.startDate)
        }
        
        if let artwork = item.artwork {
            presence.image = PresentiImage(src: artwork, link: nil)
        }
        
        presence.largeText = PresentiText(text: item.title)
        presence.smallTexts = texts
        presence.timestamps = PresentiTimeRange(start: item.start?.millisecondsSince1970, stop: item.stop?.millisecondsSince1970, effective: Date().millisecondsSince1970)
        
        
        presence.gradient = PreferencesManager.shared.gradientEnabled ? PresentiGradient(
            enabled: PreferencesManager.shared.gradientEnabled,
            priority: PreferencesManager.shared.gradientPriority
        ) : nil
        
        return presence
    }
}

extension NowPlayingManager: PresentiRPCDelegate {
    func rpcDidConnect() {
        print("Connected to Presenti!")
        print(PreferencesManager.shared.reloadInterval)
        DispatchQueue.main.async {
            StatusItemManager.shared.isConnectedToPresenti = true
            self.updateState(force: true)
            self.timer = Timer.scheduledTimer(withTimeInterval: PreferencesManager.shared.reloadInterval, repeats: true) { timer in
                self.updateState(force: false)
            }
        }
    }
    
    func rpcDidDisconnect() {
        print("Lost Presenti connection :(")
        DispatchQueue.main.async {
            StatusItemManager.shared.isConnectedToPresenti = false
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.setup), userInfo: nil, repeats: true)
            self.setup()
        }
    }
}

extension NowPlayingManager: PreferencesManagerDelegate {
    func tokenDidChange(token: String?) {
        self.rpc.token = token
    }
    
    func reloadIntervalDidChange(interval: Double) {
        self.timer?.invalidate()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: PreferencesManager.shared.reloadInterval, target: self, selector: #selector(self.updateState), userInfo: nil, repeats: true)
        }
    }
    
    func gradientEnabledDidChange(enabled: Bool) {
        
    }
    
    func gradientPriorityDidChange(priority: Int) {
        
    }
}
