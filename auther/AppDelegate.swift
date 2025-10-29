//
//  AppDelegate.swift
//  auther
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var appData: AppData!

    // Closures injected from autherApp
    var buildRootView: ((_ closePopover: @escaping () -> Void) -> AnyView)!
    var onOpenSettings: (() -> Void)!
    var onAbout: (() -> Void)!
    var onHelp: (() -> Void)!
    var onQuit: (() -> Void)!

    var openSettingsWindow: (() -> Void)?

    private var statusController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusController = StatusItemController(
            appData: appData,
            buildRootView: buildRootView,
            onOpenSettings: { [weak self] in self?.onOpenSettings() },
            onAbout: { [weak self] in self?.onAbout() },
            onHelp: { [weak self] in self?.onHelp() },
            onQuit: { [weak self] in self?.onQuit() }
        )
    }

    func closePopover() {
        statusController?.closePopover()
    }
}
