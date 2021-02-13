//
//  CourseViewModel.swift
//  Courser
//
//  Created by c on 2021/2/5.
//

import Foundation
import SwiftUI

struct CourseViewModel: Identifiable, Hashable, Codable {
    let course: Course

    init(course: Course) {
        self.course = course
    }

    /// 一个主题颜色
    ///
    /// XXX:
    /// 后续可能想拓展成一组颜色:
    ///  ColorSet: {fore,back}ground{Light,Dark}, secondary 什么的
    ///  e.g. #eee8d8, #1e2e4f, #0f1144, #cab387, #94b3b8
    var color: Color {
        .blue
    }
    
    /// 课在周几
    var courseWeekday: String {
        "星期\(course.courseWeekday)"
    }
    
    /// 课在第几节
    var courseSessions: String {
        "第\(course.courseSessionsDescription)节"
    }
    
    /// 课上几节
    var length: Int {
        course.courseSessions.1 - course.courseSessions.0 + 1
    }

    /// 图片
    ///
    /// XXX: 暂时用一个完全随机的，后面可以考虑利用 hash 值，得到每个课程相对固定的图片。
    var imageURL: String {
        "https://api.ixiaowai.cn/api/api.php"
        // "https://source.unsplash.com/random/800x450"  // 1600x900
    }

    var id: Int { hashValue }

    static func == (lhs: CourseViewModel, rhs: CourseViewModel) -> Bool {
        return lhs.course.courseName == rhs.course.courseName &&
            lhs.course.courseWeeks == rhs.course.courseWeeks
    }
}
