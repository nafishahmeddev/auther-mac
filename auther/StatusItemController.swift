//
//  StatusItemController.swift
//  auther
//

import AppKit
import SwiftUI

final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let menu: NSMenu

    // Dependencies
    private let appData: AppData?
    private let buildRootView: (_ closePopover: @escaping () -> Void) -> AnyView
    private let onOpenSettings: () -> Void
    private let onAbout: () -> Void
    private let onHelp: () -> Void
    private let onQuit: () -> Void

    // Retain hosting controller
    private var hostingController: NSHostingController<AnyView>?

    init(
        appData: AppData?,
        buildRootView: @escaping (_ closePopover: @escaping () -> Void) -> AnyView,
        onOpenSettings: @escaping () -> Void,
        onAbout: @escaping () -> Void,
        onHelp: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.appData = appData
        self.buildRootView = buildRootView
        self.onOpenSettings = onOpenSettings
        self.onAbout = onAbout
        self.onHelp = onHelp
        self.onQuit = onQuit

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
        let close: () -> Void = { [weak self] in self?.closePopover() }
        let root: AnyView
        if appData == nil {
            root = AnyView(EmptyView())
        } else {
            root = buildRootView(close)
        }
        let hosting = NSHostingController(rootView: root)
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
            // Ensure hosting controller exists and has latest view
            if hostingController == nil {
                prepareHostingController()
            } else {
                let close: () -> Void = { [weak self] in self?.closePopover() }
                hostingController?.rootView = buildRootView(close)
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func closePopover() {
        popover.performClose(nil)
    }

    // MARK: - Menu Actions

    @objc private func openSettings() {
        onOpenSettings()
    }

    @objc private func openAbout() {
        onAbout()
    }

    @objc private func openHelp() {
        onHelp()
    }

    @objc private func quitApp() {
        onQuit()
    }
}
