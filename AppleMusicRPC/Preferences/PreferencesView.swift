//
//  PreferencesView.swift
//  Discord-Apple Music Rich Presence
//
//  Created by Eric Rabil on 5/17/20.
//  Copyright © 2020 Ayden Panhuyzen. All rights reserved.
//

import SwiftUI

struct GradientPreference: View {
    private static let minimumGradientPriority = -1
    
    private static let gradientPriorityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formattingContext = .standalone
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .none
        formatter.minimum = NSNumber(value: minimumGradientPriority)
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.isLenient = true
        return formatter
    }()
    
    @State private var priority: Int = PreferencesManager.shared.gradientPriority
    @State private var enabled: Bool = PreferencesManager.shared.gradientEnabled
    
    var body: some View {
        let gradientPriority = Binding<Int>(get: {
            self.priority
        }, set: {
            PreferencesManager.shared.gradientPriority = $0
            self.priority = $0
        })
        
        let gradientEnabled = Binding<Bool>(get: {
            self.enabled
        }, set: {
            PreferencesManager.shared.gradientEnabled = $0
            self.enabled = $0
        })
        
        return HStack {
            Text("Gradient Priority:")
            Toggle(isOn: gradientEnabled) {
                Stepper(value: gradientPriority, in: Self.minimumGradientPriority...(9999), step: 1) {
                    TextField("", value: gradientPriority, formatter: Self.gradientPriorityFormatter).frame(width: 70)
                }.disabled(!gradientEnabled.wrappedValue)
            }
        }
    }
}

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
    
    @State private var reloadInterval: Double = PreferencesManager.shared.reloadInterval
    
    var body: some View {
        let binding = Binding<Double>(get: {
            self.reloadInterval
        }, set: {
            PreferencesManager.shared.reloadInterval = $0
            self.reloadInterval = $0
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
            GradientPreference()
            Divider()
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
