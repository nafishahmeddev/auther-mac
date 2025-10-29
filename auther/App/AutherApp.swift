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

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        appDelegate.configureMenuBar(with: appData, windowManager: WindowManager.shared)
    }

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .onAppear {
                    NotificationCenter.default.addObserver(forName: .openSettingsWindow, object: nil, queue: .main) { _ in
                        SettingsWindowController.shared.show(appData: appData)
                    }
                }
        }
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
