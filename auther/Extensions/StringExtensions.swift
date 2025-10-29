//
//  StringExtensions.swift
//  auther
//
//  Created by Assistant on 29/10/2025.
//

import Foundation

extension String {
    func base32DecodeToData() -> Data? {
        // Simple base32 decode implementation
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        var bits = ""
        let cleaned = self.uppercased().filter { base32Alphabet.contains($0) }
        
        for char in cleaned {
            if let index = base32Alphabet.firstIndex(of: char) {
                let value = base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
                bits += String(value, radix: 2).paddedLeft(toLength: 5, withPad: "0")
            }
        }
        
        var data = Data()
        for i in stride(from: 0, to: bits.count, by: 8) {
            let startIndex = bits.index(bits.startIndex, offsetBy: i)
            let endIndex = bits.index(startIndex, offsetBy: min(8, bits.distance(from: startIndex, to: bits.endIndex)), limitedBy: bits.endIndex) ?? bits.endIndex
            let byteBits = String(bits[startIndex..<endIndex])
            if let byte = UInt8(byteBits, radix: 2) {
                data.append(byte)
            }
        }
        return data
    }
}

extension String {
    func paddedLeft(toLength length: Int, withPad pad: String) -> String {
        guard count < length else { return self }
        return String(repeating: pad, count: length - count) + self
    }
}