// MainWindowController.swift
// auther

import AppKit
import SwiftUI

final class MainWindowController: NSWindowController, NSWindowDelegate {
    static let shared = MainWindowController()

    private init() {
        let contentView = NSHostingView(rootView: AnyView(SettingsView().environmentObject(AccountViewModel())))
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Settings"
        win.contentView = contentView
        win.center()
        win.identifier = NSUserInterfaceItemIdentifier("SettingsWindow")
        super.init(window: win)
        win.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(appData: AccountViewModel) {
        if let hostingView = window?.contentView as? NSHostingView<AnyView> {
            hostingView.rootView = AnyView(SettingsView().environmentObject(appData))
        }
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        ActivationPolicyManager.hideDockIconIfNoWindows()
    }
}
