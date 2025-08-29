//
//  autherApp.swift
//  auther
//
//  Created by Nafish Ahmed on 03/07/25.
//

import SwiftUI

struct FormState {
    var isPresented: Bool = false
    var editingAccount: Account? = nil
}

@main
struct autherApp: App {
    @StateObject private var appData = AppData()
    @State private var formState: FormState = FormState()

    var body: some Scene {
        WindowGroup("aither.") {
            ContentView(
                onAddTapped: { account in
                    formState = FormState(isPresented: true, editingAccount: account)
                }
            )
            .padding()
            .frame(minWidth: 250, minHeight: 250)
            .environmentObject(appData)
            .sheet(isPresented: $formState.isPresented) {
                AccountForm(
                    account: formState.editingAccount,
                    onSave: { newAccount in
                        appData.addOrUpdate(newAccount)
                        formState = FormState(isPresented: false, editingAccount: nil)
                        
                    },
                    onCancel: {
                        formState = FormState(isPresented: false, editingAccount: nil)
                    }
                )
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 250, height: 500))
        .commands {
            CommandMenu("Account") {
                Button("Add New Account") {
                    formState = FormState(isPresented: true, editingAccount: nil)
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
        }
    }
}
