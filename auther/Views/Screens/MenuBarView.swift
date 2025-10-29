//
//  MenuBarView.swift
//  auther
//
//  Created by Migration on 29/10/25.
//

import SwiftUI
import AppKit
import SwiftOTP

struct MenuBarView: View {
    @EnvironmentObject var appData: AccountViewModel
    var onOpenManage: () -> Void
    var onAddAccount: () -> Void
    var onOpenSettings: () -> Void
    var closeMenu: () -> Void

    @State private var now = Date()
    @State private var query = ""
    @State private var showCopied = false
    @State private var copiedText = ""

    private var filteredAccounts: [Account] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return appData.accounts
        }
        let q = query.lowercased()
        return appData.accounts.filter { acc in
            acc.issuer.lowercased().contains(q) ||
            acc.name.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                header

                if appData.accounts.isEmpty {
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(filteredAccounts) { account in
                                MenuAccountRow(
                                    account: account,
                                    code: code(for: account, at: now),
                                    remaining: remaining(for: account, at: now),
                                    onCopy: { code in
                                        copyToPasteboard(code)
                                        closeMenu()
                                    },
                                    onGenerateHOTP: { updated in
                                        appData.addOrUpdate(updated)
                                        if let new = updated.lastCode {
                                            copyToPasteboard(new)
                                        }
                                        closeMenu()
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 2)
                        .padding(.trailing, 2) // small right buffer to avoid visual clipping
                    }
                    Spacer()
                }

                // Add Settings button to tray/menu
                Button("Settings") {
                    onOpenSettings()
                    closeMenu()
                }
                .font(.system(size: 13))
                .padding(.top, 8)
            }
            .padding(10)
            .frame(width: 340)
            .frame(minHeight: 150)

            if showCopied {
                copiedToast
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { t in
            now = t
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Text("auther.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.accentColor)
                Spacer()
            }
            TextField("Search accounts", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 14))
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No accounts yet")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var copiedToast: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Copied")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Color.black.opacity(0.85))
                    )
                Spacer()
            }
            .padding(.bottom, 10)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeOut(duration: 0.2), value: showCopied)
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copiedText = text
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            showCopied = false
        }
    }

    private func remaining(for account: Account, at time: Date) -> Int {
        guard account.type == "TOTP" else { return 0 }
        let interval = max(account.period ?? 30, 1) // ensure > 0
        return interval - Int(time.timeIntervalSince1970) % interval
    }

    private func code(for account: Account, at time: Date) -> String {
        switch account.type {
        case "TOTP":
            guard let data = account.secret.base32DecodeToData(),
                  let totp = TOTP(
                    secret: data,
                    digits: account.digits,
                    timeInterval: account.period ?? 30,
                    algorithm: OTPAlgorithm(name: account.algorithm)
                  ),
                  let code = totp.generate(time: time)
            else { return "------" }
            return code
        case "HOTP":
            return account.lastCode ?? "000000"
        default:
            return "------"
        }
    }
}

private struct MenuAccountRow: View {
    let account: Account
    let code: String
    let remaining: Int
    var onCopy: (String) -> Void
    var onGenerateHOTP: (Account) -> Void

    @State private var isPressed = false
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(account.issuer)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(account.name)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()

            if account.type == "TOTP" {
                HStack(spacing: 8) {
                    Button {
                        onCopy(code)
                    } label: {
                        Text(format(code))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.accentColor.opacity(hovered ? 0.15 : 0.1))
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { hovered = $0 }

                    CircularProgressView(
                        progress: clampedProgress(remaining: remaining, period: max(account.period ?? 30, 1)),
                        lineWidth: 3
                    )
                    .frame(width: 20, height: 20)
                }
            } else {
                Button {
                    isPressed = true
                    generateAndCopyHOTP()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isPressed = false
                    }
                } label: {
                    Text(format(code))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor.opacity(hovered ? 0.15 : 0.1))
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.95 : 1)
                .onHover { hovered = $0 }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.05))
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }

    private func clampedProgress(remaining: Int, period: Int) -> Double {
        guard period > 0 else { return 0 }
        let p = Double(remaining) / Double(period)
        return min(max(p, 0), 1)
    }

    private func format(_ code: String) -> String {
        guard !code.isEmpty else { return "------" }
        let chunk = 3
        return stride(from: 0, to: code.count, by: chunk).map { i in
            let start = code.index(code.startIndex, offsetBy: i)
            let end = code.index(start, offsetBy: chunk, limitedBy: code.endIndex) ?? code.endIndex
            return String(code[start..<end])
        }.joined(separator: " ")
    }

    private func generateAndCopyHOTP() {
        guard account.type == "HOTP",
              let data = account.secret.base32DecodeToData(),
              let counter = account.counter,
              let hotp = HOTP(
                secret: data,
                digits: account.digits,
                algorithm: OTPAlgorithm(name: account.algorithm)
              ),
              let newCode = hotp.generate(counter: UInt64(counter))
        else { return }

        let updated = Account(
            id: account.id,
            issuer: account.issuer,
            name: account.name,
            secret: account.secret,
            type: account.type,
            digits: account.digits,
            algorithm: account.algorithm,
            period: account.period,
            counter: counter + 1,
            lastCode: newCode
        )
        onGenerateHOTP(updated)
    }
}
