// In SettingsView.swift
import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var appData: AccountViewModel

    @State private var selectedAccount: Account? = nil

    var body: some View {
        TabView {
            accountsTab
                .tabItem {
                    Label("Accounts", systemImage: "key")
                }
            preferencesTab
                .tabItem {
                    Label("Preferences", systemImage: "gear")
                }
            appearanceTab
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        // Window identifier and title are now set by MainWindowController
    }

    private var accountsTab: some View {
        HStack(spacing: 0) {
            // Left: List of accounts
            VStack(spacing: 0) {
                if appData.accounts.isEmpty {
                    ContentUnavailableView(
                        "No Accounts",
                        systemImage: "key",
                        description: Text("Add your first account to get started.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedAccount) {
                        ForEach(appData.accounts) { account in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(account.issuer)
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(account.name)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(account.type)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.secondary.opacity(0.12))
                                    .cornerRadius(6)
                            }
                            .tag(account)
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.inset)
                }

                Divider()

                HStack {
                    Button {
                        selectedAccount = nil
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        if let account = selectedAccount {
                            appData.deleteAccount(account)
                            selectedAccount = nil
                        }
                    } label: {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedAccount == nil)

                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 300)

            Divider()

            // Right: Account form
            VStack {
                if let account = selectedAccount {
                    Text("Edit Account")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.bottom, 8)
                    AccountForm(
                        account: account,
                        onSave: { newAccount in
                            appData.addOrUpdate(newAccount)
                            selectedAccount = newAccount
                        },
                        onCancel: {
                            // Do nothing
                        }
                    )
                } else {
                    Text("Add Account")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.bottom, 8)
                    AccountForm(
                        account: nil,
                        onSave: { newAccount in
                            appData.addOrUpdate(newAccount)
                            selectedAccount = newAccount
                        },
                        onCancel: {
                            // Do nothing
                        }
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var preferencesTab: some View {
        VStack {
            Text("Preferences")
                .font(.title)
            Spacer()
            Text("Settings for preferences will go here.")
            Spacer()
        }
        .padding()
    }

    private var appearanceTab: some View {
        VStack {
            Text("Appearance")
                .font(.title)
            Spacer()
            Text("Settings for appearance will go here.")
            Spacer()
        }
        .padding()
    }

    private var aboutTab: some View {
        VStack {
            Text("About auther")
                .font(.title)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text("auther.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentColor)
                Text("Menu bar authenticator")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("Version 1.0")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack {
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
