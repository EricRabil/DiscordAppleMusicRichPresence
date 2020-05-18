//
//  EID.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct EID<P: Codable>: Equatable, Hashable {
    /// The unique id.
    let id: PresentiPayloadType
    
    /// See `CustomStringConvertible`.
    var description: PresentiPayloadType {
        return id
    }
    
    /// Create a new `EventIdentifier`.
    init(_ id: PresentiPayloadType) {
        self.id = id
    }
}

struct Nothing: Codable {}

extension EID {
    static var ping: EID<Nothing> { .init(.ping) }
    static var pong: EID<Nothing> { .init(.pong) }
    static var greetings: EID<Nothing> { .init(.greetings) }
    static var identify: EID<String> { .init(.identify) }
    static var presence: EID<[PresentiPresence]> { .init(.presence) }
}
