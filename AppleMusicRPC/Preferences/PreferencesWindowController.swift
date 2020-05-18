//
//  PreferencesWindowController.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: true);
        self.init(window: window)
        
        let view = PreferencesView()
        
        window.title = "Presenti iTunes Preferences"
        window.level = .modalPanel
        window.contentView = NSHostingView(rootView: view)
        window.center()
    }
    
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
