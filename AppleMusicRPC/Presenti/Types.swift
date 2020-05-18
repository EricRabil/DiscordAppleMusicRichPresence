//
//  Types.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct PresentiText: Codable {
    var text: String
    var link: String?
}

struct PresentiImage: Codable {
    var src: String
    var link: String?
}

struct PresentiTimeRange: Codable {
    var start: Int?
    var stop: Int?
    var effective: Int?
}

struct PresentiGradient: Codable {
    var enabled: Bool
    var priority: Int?
}

struct PresentiPresence: Codable {
    var id: String?
    var title: String?
    var largeText: PresentiText?
    var smallTexts: [PresentiText]?
    var image: PresentiImage?
    var timestamps: PresentiTimeRange?
    var gradient: PresentiGradient?
    var shades: [String]?
    var isPaused: Bool?
}
