//
//  AppState.swift
//  Courser
//
//  Created by c on 2021/2/25.
//

import Foundation
import Combine

struct AppState {
    // Views
    var settings = SettingsState()
    var courseTable = TableState()
    var courseDaily = DailyState()
    
    var mainTab = MainTabState()
    
    // Qz Client
    @FileStorage(directory: .cachesDirectory, fileName: "qzclient.json")
    var client: QzClient?
}

// MARK: - AppState.SettingsState
extension AppState {
    struct SettingsState {
        var model: Settings = Settings()
        var logining: Bool = false
        var loginError: AppError? = nil
        var loginUser: QzAPI.AuthUser.Response? = nil
    }
}

// MARK: - AppState.TableState
extension AppState {
    struct TableState {
        var model: TableViewModel = .sample(week: 12, today: 3)
    }
}

// MARK: - AppState.DailyState
extension AppState {
    struct DailyState {
        var model: DailyViewModel = .sample(week: 12, weekday: 3)
    }
}

// MARK: - AppState.MainTabState
extension AppState {
    struct MainTabState {
        enum Index: Hashable {
            case table, daily, settings
        }
        
        var selection: Index = .daily
    }
}
