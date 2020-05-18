//
//  PreferencesManager.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import Foundation

protocol PreferencesManagerDelegate {
    func tokenDidChange(token: String?)
    func reloadIntervalDidChange(interval: Double)
    func gradientEnabledDidChange(enabled: Bool)
    func gradientPriorityDidChange(priority: Int)
}

class PreferencesManager {
    public static let shared = PreferencesManager()
    
    var delegate: PreferencesManagerDelegate?
    
    private init() {
        
    }
    
    var token: String? {
        get {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.aydeneric.presentiitunes",
                kSecAttrAccount as String: "token",
                kSecReturnAttributes as String: kCFBooleanTrue!,
                kSecReturnData as String: kCFBooleanTrue!
            ]
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status == errSecSuccess else {
                return nil
            }
            
            let dict = item as? [String: Any]
            guard let tokenData = dict?[String(kSecValueData)] as? Data else {
                return nil
            }
            
            return String(data: tokenData, encoding: .utf8)
        }
        set {
            SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.aydeneric.presentiitunes",
                kSecAttrAccount as String: "token"] as CFDictionary)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.aydeneric.presentiitunes",
                kSecAttrAccount as String: "token",
                kSecValueData as String: newValue as Any
            ];
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                return
            }
            
            delegate?.tokenDidChange(token: newValue)
        }
    }
    
    var reloadInterval: Double {
        get {
            let interval = UserDefaults.standard.double(forKey: "reload-interval") as Double? ?? 1.0
            if interval == 0.0 {
                return 1.0
            }
            return interval
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "reload-interval")
            self.delegate?.reloadIntervalDidChange(interval: newValue)
        }
    }
    
    var gradientEnabled: Bool {
        get {
            let enabled = UserDefaults.standard.bool(forKey: "gradient-enabled") as Bool? ?? false
            return enabled
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gradient-enabled")
            self.delegate?.gradientEnabledDidChange(enabled: newValue)
        }
    }
    
    var gradientPriority: Int {
        get {
            return Int(UserDefaults.standard.double(forKey: "gradient-priority") as Double? ?? 1.0)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gradient-priority")
            self.delegate?.gradientPriorityDidChange(priority: newValue)
        }
    }
}
