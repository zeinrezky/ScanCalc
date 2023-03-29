//
//  Extension+String.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 28/03/23.
//

import Foundation
import CryptoSwift

extension String {
    func AESCBCEncrypt(secretKey: String, ivKey: String, padding: Padding) -> String? {
        do {
            let aes = try AES(key: secretKey, iv: ivKey, padding: padding)
            let encrypted = try aes.encrypt(Array(self.utf8))
            let encryptedData = Data.init(encrypted)
            
            let str = encryptedData.base64EncodedString(options: .init(rawValue: 0))
            
            return str
        } catch { return nil }
    }
}
