//
//  Store.swift
//  Courser
//
//  Created by c on 2021/2/25.
//

import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()
    
    init() {
        setupObservers()
    }

    func setupObservers() {
        // TODO
    }
    
    
}
