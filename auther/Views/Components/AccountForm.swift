//
//  AccountForm.swift
//  auther
//
//  Created by Nafish Ahmed on 04/07/25.
//
import SwiftUI
import AppKit
import SwiftOTP

struct AccountForm: View {
    @State private var id: UUID?
    @State private var issuer = ""
    @State private var name = ""
    @State private var secret = ""
    @State private var type = "TOTP"
    @State private var digits = 6
    @State private var algorithm = "SHA1"
    @State private var period = 30
    @State private var counter: Int?
    
    let algorithms = ["SHA1", "SHA256", "SHA512"]
    let types = ["TOTP", "HOTP"]
    let digitsOptions = [6, 8]

    var onSave: (Account) -> Void
    var onCancel: () -> Void

    init(account: Account?, onSave: @escaping (Account) -> Void, onCancel: @escaping () -> Void) {
        _id = State(initialValue: account?.id)
        _issuer = State(initialValue: account?.issuer ?? "")
        _name = State(initialValue: account?.name ?? "")
        _secret = State(initialValue: account?.secret ?? "")
        _type = State(initialValue: account?.type ?? "TOTP")
        _digits = State(initialValue: account?.digits ?? 6)
        _algorithm = State(initialValue: account?.algorithm ?? "SHA1")
        _period = State(initialValue: account?.period ?? 30)
        _counter = State(initialValue: account?.counter ?? 0)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Basic Info").fontWeight(.semibold)) {
                    TextField("Issuer", text: $issuer)
                    TextField("Account Name", text: $name)
                    SecureField("Secret", text: $secret)
                }

                Section(header: Text("OTP Configuration").fontWeight(.semibold)) {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)

                    if type == "HOTP" {
                        TextField("Counter", value: $counter, formatter: NumberFormatter())
                    }

                    Picker("Algorithm", selection: $algorithm) {
                        ForEach(algorithms, id: \.self) { Text($0) }
                    }

                    Picker("Digits", selection: $digits) {
                        ForEach(digitsOptions, id: \.self) { Text(String($0)) }
                    }

                    if type == "TOTP" {
                        Stepper("Period: \(period)s", value: $period, in: 5...300, step: 5)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button("Cancel", role: .cancel, action: onCancel)
                            .buttonStyle(.bordered)
                        Button("Save") {
                            onSave(Account(
                                id: id ?? UUID(),
                                issuer: issuer,
                                name: name,
                                secret: secret,
                                type: type,
                                digits: digits,
                                algorithm: algorithm,
                                period: type == "TOTP" ? period : nil,
                                counter: type == "HOTP" ? counter : nil,
                                lastCode: nil
                            ))
                        }
                        .disabled(issuer.isEmpty || name.isEmpty || secret.isEmpty || (type == "HOTP" && counter == nil))
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 10)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 300, height: 450)
    }
}


#Preview {
    AccountForm(
        account: nil,
        onSave: { acc in
            print("Account")
        },
        onCancel: {
            
        }
    )
}
