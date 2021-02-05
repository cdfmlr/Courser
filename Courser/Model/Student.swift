//
//  Student.swift
//  Courser
//
//  Created by c on 2021/2/1.
//

import Foundation

/// 学生
struct Student: Codable {
    /// 学校: xxxx.edu.cn 的 xxxx
    let school: String
    /// 学号
    let sid: String
    /// 教务密码
    let password: String
}
