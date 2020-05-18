//
//  PresentiConnection.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/16/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

typealias BindHandler = (Data) -> Void

class PresentiConnection {
    static let endpoint = "ws://127.0.0.1:8138/remote"
    var token: String!
    var binds: [PresentiPayloadType: BindHandler]
    var decoder: JSONDecoder
    var encoder: JSONEncoder
    var task: URLSessionWebSocketTask!
    var running: Bool {
        get {
            guard let task = task else {
                return false
            }
            return task.state == .running
        }
    }
    
    private var forceClosed: Bool = false
    
    var isConnected = false {
        didSet {
            if isConnected == oldValue {
                return
            }
            
            if isConnected {
                delegate?.rpcDidConnect()
            } else {
                delegate?.rpcDidDisconnect()
            }
        }
    }
    var delegate: PresentiRPCDelegate?
    
    init(token accessToken: String? = nil, delegate: PresentiRPCDelegate? = nil) {
        binds = [PresentiPayloadType: BindHandler]()
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        self.delegate = delegate
        
        listen(.pong, { data in
            print("[Presenti] pong")
            self.deferPing()
        })
        
        listen(.greetings, { data in
            print("[Presenti] Connected to Presenti")
        })
    }
    
    func connect(forced: Bool = false) {
        if (forceClosed && !forced) { return }
        if (running) { return }
        forceClosed = false
        task = URLSession.shared.webSocketTask(with: URL(string: PresentiConnection.endpoint)!)
        task.resume()
        listenForMessages()
        self.send(.identify, data: self.token)
        self.deferPing()
    }
    
    func close(reconnect: Bool = false) {
        guard let task = task else { return }
        if task.state == .running {
            self.forceClosed = !reconnect
            task.cancel()
            self.onClose()
        }
    }
    
    func listenForMessages() {
        task.receive { result in
            switch result {
            case .failure(let error):
                switch error {
                case POSIXError.ECONNREFUSED:
                    fallthrough
                case URLError.cannotConnectToHost:
                    fallthrough
                case POSIXError.ENOTCONN:
                    self.onClose()
                default:
                    print("[Presenti] Failed to receive message: \(error)")
                }
                return
            case .success(let message):
                self.isConnected = true
                switch message {
                case .string(let text):
                    self.onData(Data(text.utf8))
                case .data(let data):
                    self.onData(data)
                @unknown default:
                    print("[Presenti] Unknown message format received")
                }
            }
            self.listenForMessages()
        }
    }
    
    func setPresence(_ presence: PresentiPresence) {
        send(.presence, data: [presence])
    }
    
    private func onClose() {
        print("[Presenti] Disconnected from the server. Scheduling reconnect.")
        self.isConnected = false
        self.deferConnection()
    }
    
    func deferConnection(timeout: TimeInterval = 5) {
        DispatchQueue.global(qos: .background).async {
            Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
                print("[Presenti] Connecting to Presenti")
                self.connect()
            }
            RunLoop.current.run()
        }
    }
    
    func deferPing() {
        DispatchQueue.global(qos: .background).async {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                self.send(.ping)
            }
            RunLoop.current.run()
        }
    }
    
    func onData(_ data: Data) {
        do {
            let prototype = try decoder.decode(EventPrototype.self, from: data)
            if let bind = binds.first(where: { $0.0 == prototype.type }) {
                bind.value(data)
            }
        } catch {
            unableToDecode("", error)
        }
    }
    
    func listen<P: Codable>(_ identifier: EID<P>, _ handler: @escaping (P?) -> Void) {
        binds[identifier.id] = { data in
            do {
                let res = try self.decoder.decode(Event<P>.self, from: data)
                handler(res.data)
            } catch {
                self.unableToDecode(String(identifier.id.rawValue), error)
            }
        }
    }
    
    private func unableToDecode(_ id: String, _ error: Error) {
    }
    
    func send<T: Codable>(_ type: EID<T>) {
        self.send(type, data: nil)
    }
    
    func send<T: Codable>(_ type: EID<T>, data: T?) {
        guard let task = task else {
            return
        }
        
        do {
            let jsonData = try encoder.encode(Event(type: type.id, data: data))
            
            task.send(URLSessionWebSocketTask.Message.data(jsonData)) { error in
                guard let error = error else {
                    return
                }
                
                switch error {
                case POSIXError.ENOTCONN:
                    fallthrough
                case URLError.cannotConnectToHost:
                    print("[Presenti] Not sending packet as we are not connected")
                    return
                default:
                    print("[Presenti] Failed to send to server: \(error)")
                    return
                }
            }
        } catch {
            print("??")
        }
    }
}
