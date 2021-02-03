//
//  AppError.swift
//  Courser
//
//  Created by c on 2021/2/3.
//

import Foundation

/// App 中可能的各种错误
enum AppError: String, Identifiable, Codable {
    var id: String { rawValue }

    case networkError
    case userAuthFailed
    case notInSchoolTerm
    case unexpectedError
}

// MARK: - 错误的本地化描述
extension AppError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .networkError: return "网络错误"
        case .userAuthFailed: return "登陆教务系统失败"
        case .notInSchoolTerm: return "不在学期"
        case .unexpectedError: return "未知错误"
        }
    }
}
