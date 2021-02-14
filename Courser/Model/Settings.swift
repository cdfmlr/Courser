//
//  Settings.swift
//  Courser
//
//  Created by c on 2021/2/14.
//

import Foundation

struct Settings {
    var account = Account()
}

// MARK: - Account
extension Settings {
    class Account {
        @Published var sid = ""
        @Published var password = ""
    }
}
