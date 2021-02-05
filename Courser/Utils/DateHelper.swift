//
//  DateHelper.swift
//  Courser
//
//  Created by c on 2021/2/3.
//

import Foundation

// MARK: - 时间间隔判断: 判断是否为同一周
// From: https://www.jianshu.com/p/b98fd874348a
extension Date {
    /// 两个日期的间隔
    private func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return abs(components.day!)
    }

    /// 日期对应当周的周几. 周一为开始, 周天为结束
    private func dayForWeekAtIndex() -> Int {
        let components = Calendar.current.dateComponents([.weekday], from: self)

        return (components.weekday! - 1) == 0 ? 7 : (components.weekday! - 1)
    }

    /// 判断是否为同一周
    func isSameWeek(date: Date) -> Bool {
        let differ = daysBetweenDate(toDate: date)
        // 判断哪一个日期更早
        let compareResult = Calendar.current.compare(self, to: date, toGranularity: Calendar.Component.day)

        // 获取更早的日期
        var earlyDate: Date
        if compareResult == ComparisonResult.orderedAscending {
            earlyDate = self
        } else {
            earlyDate = date
        }

        let indexOfWeek = earlyDate.dayForWeekAtIndex()
        let result = differ + indexOfWeek

        return result > 7 ? false : true
    }
}
