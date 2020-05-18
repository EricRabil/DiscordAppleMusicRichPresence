//
//  PreferencesView.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import SwiftUI

struct ReloadIntervalPreference: View {
    private static let defaultReloadInterval = 1.0
    private static let minimumReloadInterval = 0.1
    
    private static let reloadIntervalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formattingContext = .standalone
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.minimum = NSNumber(value: minimumReloadInterval)
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.isLenient = true
        return formatter
    }()
    
    var body: some View {
        let binding = Binding<Double>(get: {
            PreferencesManager.shared.reloadInterval
        }, set: {
            PreferencesManager.shared.reloadInterval = $0
        })
        
        return HStack {
            Text("Reload Interval:")
            Stepper(value: binding, in: Self.minimumReloadInterval...(.greatestFiniteMagnitude), step: 0.1) {
                TextField("", value: binding, formatter: Self.reloadIntervalFormatter).frame(width: 70)
            }
            Text("seconds")
        }
    }
}

struct AuthenticationPreference: View {
    var body: some View {
        let binding = Binding<String>(get: {
            PreferencesManager.shared.token ?? ""
        }, set: {
            PreferencesManager.shared.token = $0
        })
        
        return VStack {
            Text("Presenti API Key:")
            SecureField("Presenti API Key", text: binding)
        }
    }
}

struct PreferencesView: View {
    var body: some View {
        VStack {
            ReloadIntervalPreference()
            Divider()
            AuthenticationPreference()
        }.frame(width: 340).padding().padding()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PreferencesView()
            }
    }
}
