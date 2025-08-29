//
//  ContentView.swift
//  auther
//
//  Created by Nafish Ahmed on 03/07/25.
//
import SwiftUI
import AppKit
import SwiftOTP

struct ContentView: View {
    var onAddTapped: (Account?) -> Void
    @EnvironmentObject var appData: AppData
    @State private var currentTime = Date()
    @State private var showForm = false
    @State private var showToast = false // toast state
    @State private var toastMessage = "" // toast message

    let gridColumns = [
        GridItem(.adaptive(minimum: 250), spacing: 16)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top logo and Add button
                HStack {
                    Spacer()
                    Text("auther.")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.accentColor)
                    Spacer()
                }
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(appData.accounts) { account in
                            let code = account.type == "TOTP" ? generateTOTP(for: account, at: currentTime) : account.lastCode ?? "000000"
                            let accountS = appData.accounts.first(where: { $0.id == account.id })
                            AccountRowView(
                                onEditTap: onAddTapped,
                                onDeleteTap: appData.deleteAccount,
                                onTap: {
                                    if(account.type == "HOTP"){
                                        generateHOTP(for: account, appData: appData)
                                    }
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(code, forType: .string)
                                },
                                onCodeCopied: {
                                    toastMessage = "Copied!"
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        showToast = false
                                    }
                                },
                                account: account,
                                code: account.type == "TOTP" ? code : accountS?.lastCode ?? "000000",
                                remaining: account.type == "TOTP" ? getRemaining(interval: account.period ?? 30) : 0
                            )
                        }
                    }
                    .padding(.top)
                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now in
                        currentTime = now
                    }
                }
            }
            // Toast overlay at bottom of window
            if showToast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(toastMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.85))
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeOut(duration: 0.2), value: showToast)
                        Spacer()
                    }
                    .padding(.bottom, 18)
                }
            }
        }
    }
    
    func getRemaining(interval: Int, time: Date = Date()) -> Int {
        let remaining = interval - Int(time.timeIntervalSince1970) % interval
        return remaining
    }

    func generateTOTP(for account: Account, at time: Date) -> String {
        guard let data = base32DecodeToData(account.secret),
              let totp = TOTP(
                  secret: data,
                  digits: account.digits,
                  timeInterval: account.period ?? 30,
                  algorithm: OTPAlgorithm(name: account.algorithm)
              ),
              let code = totp.generate(time: time) else {
            return "------"
        }
        return code
    }
    
    func generateHOTP(for account: Account, appData: AppData) {
        guard let data = base32DecodeToData(account.secret),
              let counter = account.counter,
              let hotp = HOTP(
                  secret: data,
                  digits: account.digits,
                  algorithm: OTPAlgorithm(name: account.algorithm)
              ),
              let code = hotp.generate(counter: UInt64(counter)) else {
            print("Failed to generate HOTP")
            return
        }

        print("Generated HOTP: \(code)")

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
            lastCode: code
        )
        
        print(account.id.uuidString)
        print(updated.id.uuidString)

        appData.addOrUpdate(updated)
    }
}

#Preview {
    let appData = AppData()
    ContentView(
        onAddTapped: { account in
            print("test");
        }
    )
    .environmentObject(appData)
    .frame(minWidth: 300, maxWidth: 300)
    .padding()
}
