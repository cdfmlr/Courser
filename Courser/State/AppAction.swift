//
//  AppAction.swift
//  Courser
//
//  Created by c on 2021/2/28.
//

import Foundation

enum AppAction {
    case login(student: Student)
    case loginDone(result: Result<QzClient, AppError>)
}
