//
//  Appdata.swift
//  auther
//
//  Created by Nafish Ahmed on 04/07/25.
//
import Foundation
import Combine

class AppData: ObservableObject {
    @Published var accounts: [Account] = [] {
        didSet {
            saveAccounts()
        }
    }

    private let storageKey = "SavedAccounts"

    init() {
        loadAccounts()
    }

    func addOrUpdate(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
        accounts = Array(accounts)
        saveAccounts()
    }
    
    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()
    }

    func saveAccounts() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func loadAccounts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Account].self, from: data) else { return }
        self.accounts = decoded
    }
}
