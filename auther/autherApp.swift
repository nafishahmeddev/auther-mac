//
//  autherApp.swift
//  auther
//
//  Created by Nafish Ahmed on 03/07/25.
//

import SwiftUI
import AppKit

struct FormState {
    var isPresented: Bool = false
    var editingAccount: Account? = nil
}

@main
struct autherApp: App {
    @StateObject private var appData = AppData()
    @State private var formState: FormState = FormState()
    @Environment(\.openWindow) private var openWindow
    // This property is required to register AppDelegate with the SwiftUI app lifecycle.
    // It is also used in setupAppDelegateBridges() to bridge app data and closures.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Removed appDelegate.appData = appData from here
    }

    private func setupAppDelegateBridges() {
        appDelegate.appData = appData
        appDelegate.openSettingsWindow = {
            openWindow(id: "settings")
        }
        appDelegate.buildRootView = { close in
            let root = MenuBarView(
                onOpenManage: {
                    ActivationPolicyManager.showDockIconAndActivate()
                    NSApp.activate(ignoringOtherApps: true)
                },
                onAddAccount: {
                    ActivationPolicyManager.showDockIconAndActivate()
                    NSApp.activate(ignoringOtherApps: true)
                },
                onOpenSettings: {
                    appDelegate.openSettingsWindow?()
                    ActivationPolicyManager.showDockIconAndActivate()
                    NSApp.activate(ignoringOtherApps: true)
                },
                closeMenu: {
                    close() // close the popover after actions
                }
            )
            .environmentObject(appData)
            return AnyView(root)
        }
        appDelegate.onOpenSettings = {
            appDelegate.openSettingsWindow?()
            ActivationPolicyManager.showDockIconAndActivate()
            NSApp.activate(ignoringOtherApps: true)
        }
        appDelegate.onAbout = {
            NSApp.orderFrontStandardAboutPanel(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        appDelegate.onHelp = {
            if let url = URL(string: "https://example.com/help") {
                NSWorkspace.shared.open(url)
            }
        }
        appDelegate.onQuit = {
            NSApp.terminate(nil)
        }
    }

    var body: some Scene {
        WindowGroup(id: "settings") {
            SettingsView()
            .environmentObject(appData)
            .onAppear {
                setupAppDelegateBridges()
                ActivationPolicyManager.showDockIconAndActivate()
            }
            .onDisappear {
                ActivationPolicyManager.hideDockIconIfNoWindows()
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 600, height: 400))
        .commands {
            CommandMenu("Account") {
                Button("Add New Account") {
                    formState = FormState(isPresented: true, editingAccount: nil)
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
            CommandGroup(replacing: .appInfo) {
                Button("About auther") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
