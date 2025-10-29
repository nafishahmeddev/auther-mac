//
//  AutherApp.swift
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
struct AutherApp: App {
    @StateObject private var appData = AccountViewModel()
    @State private var formState: FormState = FormState()
    @Environment(\.openWindow) private var openWindow

    // This property is required to register AppDelegate with the SwiftUI app lifecycle.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Configure the app delegate with our data
        // This happens during app initialization, before SwiftUI scenes are created
    }

    var body: some Scene {
        WindowGroup(id: "settings") {
            SettingsView()
                .environmentObject(appData)
                .onAppear {
                    // Configure menu bar when settings window appears (app is ready)
                    appDelegate.configureMenuBar(with: appData)
                }
                .onDisappear {
                    ActivationPolicyManager.hideDockIconIfNoWindows()
                }
                .onReceive(NotificationCenter.default.publisher(for: .openSettingsWindow)) { _ in
                    openWindow(id: "settings")
                    ActivationPolicyManager.showDockIconAndActivate()
                    NSApp.activate(ignoringOtherApps: true)
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
