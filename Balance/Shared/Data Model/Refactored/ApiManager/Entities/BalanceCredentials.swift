//
//  BalanceCredentials.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BalanceCredentials: Credentials {
    
    let apiKey: String
    let secretKey: String
    let passphrase: String
    let address: String
    let name: String
    let userId: String
        
    init(apiKey: String? = nil,
         secretKey: String? = nil,
         passphrase: String? = nil,
         address: String? = nil,
         name: String? = nil,
         userId: String? = nil)
    {
        self.apiKey = apiKey ?? ""
        self.secretKey = secretKey ?? ""
        self.passphrase = passphrase ?? ""
        self.address = address ?? ""
        self.name = name ?? ""
        self.userId = userId ?? ""
    }
}

// MARK: Builder methods

extension BalanceCredentials {
    static func credentials(from fields: [Field], source: Source) -> Credentials? {
        guard source != .coinbase else {
            return BalanceCredentials()
        }
        
        guard fields.count == totalFields(for: source) else {
            print("Error - Invalid amount for creating credentials from fields array")
            return nil
        }
        
        let credentials = BalanceCredentials(fields: fields)
        guard areCredentialsValid(credentials, for: source) else {
            print("Error - Credentials weren't setted correctly for \(source)")
            return nil
        }
        
        return credentials
    }
}

private extension BalanceCredentials {
    init(fields: [Field]) {
        var apiKey = ""
        var secretKey = ""
        var passphrase = ""
        var address = ""
        var name = ""
        var userId = ""
        
        for field in fields {
            switch field.type {
            case .address:
                address = field.value
            case .key:
                apiKey = field.value
            case .secret:
                secretKey = field.value
            case .passphrase:
                passphrase = field.value
            case .name:
                name = field.value
            case .userId:
                userId = field.value
            }
        }
        
        self.init(apiKey: apiKey, secretKey: secretKey, passphrase: passphrase, address: address, name: name, userId: userId)
    }
    
    static func areCredentialsValid(_ credentials: Credentials, for source: Source) -> Bool {
        switch source {
        case .poloniex, .kraken, .bitfinex, .bittrex, .binance, .hitbtc, .kucoin:
            return !credentials.apiKey.isEmpty && !credentials.secretKey.isEmpty
        case .gdax:
            return !credentials.apiKey.isEmpty && !credentials.secretKey.isEmpty && !credentials.passphrase.isEmpty
        case .ethplorer, .blockchain:
            return !credentials.address.isEmpty && !credentials.name.isEmpty
        case .cex:
            return !credentials.userId.isEmpty && !credentials.apiKey.isEmpty && !credentials.secretKey.isEmpty
        case .coinbase:
            return false
        }
    }
    
    static func totalFields(for source: Source) -> Int {
        switch source {
        case .gdax, .cex:
            return 3
        default:
            return 2
        }
    }

}