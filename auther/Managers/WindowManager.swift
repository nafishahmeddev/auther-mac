//
//  WindowManager.swift
//  auther
//

import SwiftUI
import AppKit

final class WindowManager: ObservableObject {
    @Published var isSettingsWindowOpen = false
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openSettings),
            name: .openSettingsWindow,
            object: nil
        )
    }
    
    @objc private func openSettings() {
        isSettingsWindowOpen = true
        ActivationPolicyManager.showDockIconAndActivate()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}