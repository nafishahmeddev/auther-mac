//
//  StatusItemController.swift
//  auther
//

import AppKit
import SwiftUI

extension Notification.Name {
    static let openSettingsWindow = Notification.Name("openSettingsWindow")
    static let closeSettingsWindow = Notification.Name("closeSettingsWindow")
}

final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let menu: NSMenu

    // Dependencies
    private let appData: AccountViewModel
    private let windowManager: WindowManager

    // Retain hosting controller
    private var hostingController: NSHostingController<AnyView>?

    init(appData: AccountViewModel, windowManager: WindowManager) {
        self.appData = appData
        self.windowManager = windowManager

        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.menu = NSMenu(title: "auther")

        super.init()

        configureStatusItem()
        configurePopover()
        configureMenu()
        prepareHostingController()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "key.viewfinder", accessibilityDescription: "auther")
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.toolTip = "auther"
    }

    private func configurePopover() {
        popover.behavior = .semitransient // allows interactions without closing too eagerly
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 480)
    }

    private func configureMenu() {
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self

        let aboutItem = NSMenuItem(title: "About", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self

        let helpItem = NSMenuItem(title: "Help", action: #selector(openHelp), keyEquivalent: "")
        helpItem.target = self

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self

        menu.addItem(settingsItem)
        menu.addItem(aboutItem)
        menu.addItem(helpItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
    }

    private func prepareHostingController() {
        let menuBarView = MenuBarView(
            onOpenManage: {
                ActivationPolicyManager.showDockIconAndActivate()
                NSApp.activate(ignoringOtherApps: true)
            },
            onAddAccount: {
                ActivationPolicyManager.showDockIconAndActivate()
                NSApp.activate(ignoringOtherApps: true)
            },
            onOpenSettings: {
                // This will be handled by the app's window management
                NotificationCenter.default.post(name: .openSettingsWindow, object: nil)
                ActivationPolicyManager.showDockIconAndActivate()
                NSApp.activate(ignoringOtherApps: true)
            },
            closeMenu: { [weak self] in
                self?.closePopover()
            }
        )
        .environmentObject(appData)

        let hosting = NSHostingController(rootView: AnyView(menuBarView))
        hosting.sizingOptions = [.intrinsicContentSize]
        hostingController = hosting
        popover.contentViewController = hosting
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showMenu()
        } else {
            togglePopover()
        }
    }

    private func showMenu() {
        guard let button = statusItem.button else { return }
        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func closePopover() {
        popover.performClose(nil)
    }

    // MARK: - Menu Actions

    @objc private func openSettings() {
        NotificationCenter.default.post(name: .openSettingsWindow, object: nil)
    }

    @objc private func openAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openHelp() {
        if let url = URL(string: "https://example.com/help") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
