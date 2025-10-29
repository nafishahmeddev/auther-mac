//
//  ActivationPolicyManager.swift
//  auther
//

import AppKit

enum ActivationPolicyManager {
    static func showDockIconAndActivate() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    static func hideDockIconIfNoWindows() {
        // Hide Dock icon only if there are no visible and non-miniaturized windows
        let hasActiveWindow = NSApp.windows.contains { $0.isVisible && !$0.isMiniaturized }
        if !hasActiveWindow {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
