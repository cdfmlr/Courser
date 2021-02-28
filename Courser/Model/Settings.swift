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
        @Published var school = ""
        @Published var sid = ""
        @Published var password = ""

        var student: Student {
            Student(school: school, sid: sid, password: password)
        }

        init() {}

        init(from student: Student) {
            school = student.school
            sid = student.sid
            password = student.password
        }
    }
}
