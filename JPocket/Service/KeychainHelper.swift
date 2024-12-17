//
//  APIKeyViewModel.swift
//  JPocket
//
//  Created by Ruby on 12/12/2024.
//

import Foundation
import Security

func saveToKeychain(key: String, value: String) {
    let data = value.data(using: .utf8)!
    let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecValueData: data
    ] as CFDictionary
    
    SecItemDelete(query) // Remove old value
    SecItemAdd(query, nil)
}

func getFromKeychain(key: String) -> String? {
    let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecReturnData: true,
        kSecMatchLimit: kSecMatchLimitOne
    ] as CFDictionary
    
    var result: AnyObject?
    SecItemCopyMatching(query, &result)
    if let data = result as? Data {
        return String(data: data, encoding: .utf8)
    }
    return nil
}
