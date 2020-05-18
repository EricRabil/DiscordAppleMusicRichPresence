//
//  PresentiRPCDelegate.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

protocol PresentiRPCDelegate {
    func rpcDidConnect()
    func rpcDidDisconnect()
}
