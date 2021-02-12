//
//  DailyViewModel.swift
//  Courser
//
//  Created by c on 2021/2/7.
//

import Foundation

struct DailyViewModel: Codable {
    /// 第几周
    let week: Int
    /// 星期几
    let weekday: Int

    /// 这天的所有课程的 ViewModel
    let courseModels: [CourseViewModel]

    /// 从给定的 allCourseModels 里面**筛选**出给定第几周、星期几的来，构造 DailyViewModel
    /// - Parameters:
    ///   - week: 周次
    ///   - weekday: 星期几
    ///   - allCourseModels: 所有的课程
    init(week: Int, weekday: Int, from allCourseModels: [CourseViewModel]) {
        self.week = week
        self.weekday = weekday
        courseModels = allCourseModels
            .filter { model in
                (model.course.courseWeekday == weekday) &&
                    model.course.hasClass(at: week)
            }
    }
}

extension DailyViewModel {
    static func sample(week: Int, weekday: Int) -> DailyViewModel {
        DailyViewModel(
            week: week,
            weekday: weekday,
            from: sampleCourses.map { CourseViewModel(course: $0) }
        )
    }
}
