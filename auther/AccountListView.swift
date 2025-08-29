//
//  AccountListView.swift
//  auther
//
//  Created by Nafish Ahmed on 03/07/25.
//

import SwiftUI
import AppKit

struct AccountRowView: View {
    var onEditTap: (Account) -> Void
    var onDeleteTap: (Account) -> Void
    var onTap: () -> Void
    var onCodeCopied: () -> Void
    let account: Account
    let code: String
    let remaining: Int
    @State private var isHovered = false
    @State private var codeCopied = false
    @State private var isPressed = false
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Left: Issuer and Email
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.issuer)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Text(account.name)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding(.leading, 14)
                    Spacer(minLength: 8)
                    if account.type == "TOTP" {
                        CircularProgressView(
                            progress: CGFloat(
                                Float(remaining) / Float(account.period ?? 30)
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 8)
                    }
                    // Code (tap to copy)
                    Button(action: {
                        isPressed = true
                        NSPasteboard.general.setString(code, forType: .string)
                        codeCopied = true
                        onCodeCopied()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isPressed = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            codeCopied = false
                        }
                    }) {
                        
                        Text(splitString(input: code, chunkSize: 3))
                            .font(.system(size: 14, weight: .light, design: .monospaced))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 6)   // 👈 add horizontal padding
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill( Color.accentColor.opacity(0.1))
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 12)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.easeInOut(duration: 0.12), value: isPressed)
                    // Compact vertical three-dot menu button (only show on hover)
                    
                    if isHovered {
                        Menu {
                            Button("Edit") { onEditTap(account) }
                            Button("Delete") { onDeleteTap(account) }
                            Divider()
                            Button("Copy Token") {
                                NSPasteboard.general.setString(account.secret, forType: .string)
                                onCodeCopied()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.secondary)
                                    .frame(width: 18, height: 18)
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .menuStyle(.button)
                        .buttonStyle(.plain)
                        .padding(.trailing, 12)
                        .menuIndicator(.hidden)
                        .frame(width: 20, height: 20)
                    }
                }
                .frame(height: 55)
            }
        }
        .background(
            Color(NSColor.controlBackgroundColor)
            .opacity(isHovered ? 0.85 : 1.0)
        )
        .cornerRadius(14)
        .onHover { isHovered = $0 }
        .onTapGesture { onTap() }
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.12), value: isHovered)
    }
    
    func splitString(input: String, chunkSize: Int) -> String {
        guard chunkSize > 0 else { return input }
        return stride(from: 0, to: input.count, by: chunkSize).map {
            let start = input.index(input.startIndex, offsetBy: $0)
            let end = input.index(start, offsetBy: chunkSize, limitedBy: input.endIndex) ?? input.endIndex
            return String(input[start..<end])
        }.joined(separator: " ")
    }
}

#Preview {
    VStack(spacing: 12){
        
        
        AccountRowView(
            onEditTap: { newAccount in
                print("Edit tapped for \(newAccount.issuer)")
            },
            onDeleteTap: { newAccount in
                print("Delete tapped for \(newAccount.issuer)")
            },
            onTap: {
                print("Row tapped!")
            },
            onCodeCopied: {
                print("Code copied toast triggered")
            },
            account: Account(
                id: UUID(),
                issuer: "ViMO",
                name: "n.ahmed@vimo.me",
                secret: "XHJIDRJHFUF",
                type: "TOTP",
                digits: 6,
                algorithm: "SHA1",
                period: 30,
                counter: nil,
                lastCode: nil
                            ),
            code: "255225",
            remaining : 28
        )
        
        AccountRowView(
            onEditTap: { newAccount in
                print("Edit tapped for \(newAccount.issuer)")
            },
            onDeleteTap: { newAccount in
                print("Delete tapped for \(newAccount.issuer)")
            },
            onTap: {
                print("Row tapped!")
            },
            onCodeCopied: {
                print("Code copied toast triggered")
            },
            account: Account(
                id: UUID(),
                issuer: "Gmail",
                name: "nafish.ahmed.dev@gmail.com",
                secret: "XHJIDRJHFUF",
                type: "TOTP",
                digits: 6,
                algorithm: "SHA1",
                period: 30,
                counter: nil,
                lastCode: nil
                            ),
            code: "255225",
            remaining : 28
        )
    }
    .padding()
    .frame(width: 350)
}
