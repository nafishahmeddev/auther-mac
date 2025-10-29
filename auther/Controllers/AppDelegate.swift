//
//  AppDelegate.swift
//  auther
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar setup will be handled by the app's lifecycle
        setupMenuBar()
    }

    private func setupMenuBar() {
        // This will be called after the SwiftUI app is ready
        // The actual setup happens in AutherApp when the environment is available
    }

    func configureMenuBar(with appData: AccountViewModel, windowManager: WindowManager) {
        statusItemController = StatusItemController(appData: appData, windowManager: windowManager)
    }

    func closePopover() {
        statusItemController?.closePopover()
    }
}
