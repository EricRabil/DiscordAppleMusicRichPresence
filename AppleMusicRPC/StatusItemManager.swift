//
//  StatusItemManager.swift
//  AppleMusicRPC
//
//  Created by Ayden Panhuyzen on 2020-05-16.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Cocoa

class StatusItemManager {
    static let shared = StatusItemManager()
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let discordStatusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let connectItem = NSMenuItem(title: "Connect", action: #selector(StatusItemManager.connect(_:)), keyEquivalent: "c")
    private let reconnectItem = NSMenuItem(title: "Reconnect", action: #selector(StatusItemManager.reconnect(_:)), keyEquivalent: "c")
    
    private init() {
        statusItem.button?.title = "Apple Music Presenti Status"
        
        let menu = NSMenu()
        menu.addItem(discordStatusMenuItem)
        menu.addItem(.separator())
        menu.autoenablesItems = false
        
        discordStatusMenuItem.isEnabled = false
        
        let prefsItem = NSMenuItem(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)
        
        connectItem.target = self
        menu.addItem(connectItem)
        
        reconnectItem.target = self
        reconnectItem.isAlternate = true
        reconnectItem.keyEquivalentModifierMask = .option
        menu.addItem(reconnectItem)
        
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
        
        defer {
            isConnectedToPresenti = false
            updateIcon()
        }
    }
    
    @objc func showPreferences(_ sender: NSMenuItem) {
        PreferencesWindowController().showWindow()
    }
    
    @objc func disconnect(_ sender: NSMenuItem) {
        NowPlayingManager.shared.rpc.close()
    }
    
    @objc func connect(_ sender: NSMenuItem) {
        NowPlayingManager.shared.rpc.connect(forced: true)
    }
    
    @objc func reconnect(_ sender: NSMenuItem) {
        NowPlayingManager.shared.rpc.close(reconnect: true)
    }
    
    func setup() {}
    
    private func updateIcon() {
        statusItem.button?.image = NSImage(named: "StatusItem_\(isConnectedToPresenti ? iconState.imageSuffix : "disabled")")
        
        connectItem.title = isConnectedToPresenti ? "Disconnect" : "Connect"
        connectItem.action = isConnectedToPresenti ? #selector(disconnect(_:)) : #selector(connect(_:))
        reconnectItem.isEnabled = isConnectedToPresenti
    }
    
    var isConnectedToPresenti = false {
        didSet {
            discordStatusMenuItem.title = "\(isConnectedToPresenti ? "" : "Not ")Connected to Presenti"
            updateIcon()
        }
    }
    
    var iconState = IconPlaybackState.stopped {
        didSet { updateIcon() }
    }
    
    enum IconPlaybackState: String {
        case playing, paused, stopped
        
        var imageSuffix: String {
            return rawValue
        }
        
        static func from(isPaused: Bool?) -> IconPlaybackState {
            guard let isPaused = isPaused else { return .stopped }
            return isPaused ? .paused : .playing
        }
    }
}
