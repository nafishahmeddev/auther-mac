//
//  Models.swift
//  auther
//
//  Created by Nafish Ahmed on 03/07/25.
//

import SwiftUI
import AppKit

import SwiftOTP

extension OTPAlgorithm {
    init(name: String) {
        switch name.uppercased() {
        case "SHA256": self = .sha256
        case "SHA512": self = .sha512
        default: self = .sha1
        }
    }
}

struct Account: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let issuer: String
    let name: String
    let secret: String
    let type: String         // "TOTP" or "HOTP"
    let digits: Int          // 6 or 8
    let algorithm: String    // "SHA1", "SHA256", "SHA512"
        
        // TOTP-specific
    let period: Int?         // in seconds (e.g., 30)

        // HOTP-specific
    var counter: Int?
    
    let lastCode: String?
    
    init(id: UUID, issuer: String, name: String, secret: String, type: String, digits: Int, algorithm: String, period: Int?, counter: Int?, lastCode: String?) {
        self.id = id
        self.issuer = issuer
        self.name = name
        self.secret = secret
        self.type = type
        self.digits = digits
        self.algorithm = algorithm
        self.period = period
        self.counter = counter
        self.lastCode = lastCode
    }
}
