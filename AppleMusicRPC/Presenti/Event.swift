//
//  Event.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

enum PresentiPayloadType: Int, Codable {
    case ping = 0
    case pong = 1
    case presence = 2
    case identify = 3
    case greetings = 4
    case presenceFirstParty = 5
    case subscribe = 6
    case unsubscribe = 7
    case dispatch = 8
}

struct Event<P: Codable>: Codable {
    public let type: PresentiPayloadType
    public let data: P?
    public init (type: PresentiPayloadType, data: P? = nil) {
        self.type = type
        self.data = data
    }
}

struct EventPrototype: Codable {
    public var type: PresentiPayloadType
}
