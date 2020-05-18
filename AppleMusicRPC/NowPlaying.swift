//
//  NowPlaying.swift
//  AppleMusicRPC
//
//  Created by Ayden Panhuyzen on 2020-05-15.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import AppKit
import ScriptingBridge

struct NowPlaying {
    let id: Int, title: String, artist: String?, album: String?, isPaused: Bool, artwork: String?, start: Date?, stop: Date?
    
    private static let bridge = MusicBridge()
    
    private static var lastID: Int? = nil
    private static var lastPosition: Double? = nil
    private static var lastCheck: Int? = nil
    private static var wasPaused: Bool? = nil
    
    static var changed: Bool {
        get {
            guard let lastID = lastID, let lastPosition = lastPosition, let lastCheck = lastCheck, let id = bridge.currentTrackInfo()["id"] as? Int, let wasPaused = wasPaused else {
                return true
            }
            
            if id != lastID {
                return true
            }
            
            let isPaused = bridge.isPaused()
            
            if isPaused != wasPaused {
                return true
            }
            
            let position = bridge.playerPosition()
            
            if isPaused {
                return position != lastPosition
            }
            
            let dateDiff = (Date().millisecondsSince1970 - lastCheck) / 1000
            let positionDiff = Int(position - lastPosition)
            let gap = dateDiff - positionDiff
            
            print(abs(gap))
            
            let didChange = abs(gap) > 2
            
            return didChange
        }
    }
    
    static var current: NowPlaying? {
        let trackInfo = bridge.currentTrackInfo()
        guard let id = trackInfo["id"] as? Int, let title = trackInfo["name"] as? String, let duration = trackInfo["duration"] as? Double else { return nil }
        
        let position = bridge.playerPosition()
        bridge.currentTrackInfo()
        
        var artwork: String? = nil
        if var image = bridge.currentTrackArtwork()["data"] as? NSImage {
            image = image.resize(w: 128, h: 128)
            if let tiff = image.tiffRepresentation, let imageRep = NSBitmapImageRep(data: tiff), let data = imageRep.representation(using: .jpeg, properties: [.compressionFactor : 0.5]) {
                artwork = "data:image/jpg;base64,\(data.base64EncodedString())"
            }
        }
        
        let start = Date() - position
        let stop = Date() + (duration - position)
        
        lastID = id
        lastPosition = position
        lastCheck = Date().millisecondsSince1970
        wasPaused = bridge.isPaused()
        
        return NowPlaying(
            id: id, title: title,
            artist: trackInfo["artist"] as? String,
            album: trackInfo["album"] as? String,
            isPaused: bridge.isPaused(),
            artwork: artwork,
            start: start,
            stop: stop
        )
    }
}
