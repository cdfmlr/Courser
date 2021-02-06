//
//  Course.swift
//  Courser
//
//  Created by c on 2021/2/1.
//

import Foundation

/// 课程
///
/// TODO：
/// 用一个 entension 去写 真实的时间（加上日期、时间的 Date）:
///  `var real{Start,end}Time: Date {...}`
struct Course: Codable {
    /// 课程名称: kcmc
    let courseName: String
    /// 教室名称: jsmc
    let classroom: String
    /// 教师姓名: jsxm
    let teacher: String
    /// 开始时间: kssj
    let startTime: String
    /// 结束时间: jssj
    let endTime: String
    /// 课程时间: kcsj
    ///
    /// 格式x0a0b，意为星期x的第a,b节上课
    ///
    /// e.g.
    ///   "10506"
    let courseTime: String
    /// 开课周次: kkzc
    ///
    /// 有三种已知格式:
    /// - `a-b`
    /// - `a,b,c`
    /// - `a-b,c-d`
    let courseWeeks: String
    /// 具体意义未知，据观察值为1时本课单周上，2时双周上
    ///
    /// 我没见过，暂时不用这个
    let sjbz: String?
}

extension Course: Hashable {}

extension Course {
    /// courseTime 的自然语言描述: 星期x的第a,b节上课
    var courseTimeDescription: String {
        let regex = try! Regex("(\\d)(\\d{2})(\\d{2})")
        let match = regex.firstMatch(in: self.courseTime)
        // match: [weekday, firstSession, secondSession]
        
        return "星期\(match?.captures[0] ?? "nil")第\(match?.captures[1]  ?? "nil")、\(match?.captures[2]  ?? "nil")节"
    }
    
    /// 课在周几
    var courseWeekday: Int {
        let regex = try! Regex("(\\d)\\d{2}\\d{2}")
        let match = regex.firstMatch(in: self.courseTime)
        // match: [weekday]
        
        return Int(match!.captures.first!!) ?? 0
    }
    
    /// 课在第几节
    var courseSessions: String {
        let regex = try! Regex("\\d(\\d{2})(\\d{2})")
        let match = regex.firstMatch(in: self.courseTime)
        // match: [firstSession, secondSession]
        
        return "\(match?.captures[0]  ?? "nil")、\(match?.captures[1]  ?? "nil")"
    }
}
