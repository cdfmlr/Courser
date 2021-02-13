//
//  TableViewModel.swift
//  Courser
//
//  Created by c on 2021/2/13.
//

import Foundation
import SwiftUI

struct TableViewModel: Codable {
    /// 第几周
    let week: Int
    /// 今天星期几：高亮显示今天
    let today: Int?

    /// 这周的所有课程的 ViewModel
    let courseModels: [CourseViewModel]

    /// 获取某一天的课程，按节次排列好
    /// - Parameter day: 1...7: 星期几
    func getCourseModels(at day: Int) -> [CourseViewModel] {
        return courseModels
            .filter { model in
                model.course.courseWeekday == day
            }
            .sorted { $0.course.courseSessions.0 < $1.course.courseSessions.0 }
    }

    /// coursesDict: courseModels 字典
    ///
    ///     coursesDict[周次][开始节次] = TableCell
    var coursesDict: [Int: [Int: TableCell]] {
        var dict: [Int: [Int: TableCell]] = .init()

        for day in 1 ... 7 {
            let dayCourses = getCourseModels(at: day)

            /// 某一节课距离上一节课的长度
            var diff: [Int] = []
            if !dayCourses.isEmpty {
                diff.append(dayCourses.first?.course.courseSessions.0 ?? 0)
                for i in 1 ..< dayCourses.count {
                    diff.append(
                        dayCourses[i].course.courseSessions.0 -
                            dayCourses[i - 1].course.courseSessions.1
                    )
                }
            }
            diff = diff.map { $0 - 1 }

            dict[day] = Dictionary(
                uniqueKeysWithValues: zip(
                    dayCourses.map { $0.course.courseSessions.0 },
                    zip(dayCourses, diff)
                        .map {
                            TableCell(courseViewModel: $0.0, distancePrev: $0.1)
                        }
                )
            )
        }

        return dict
    }

    func getCells(at day: Int) -> [TableCell] {
        let dayCourses = getCourseModels(at: day)

        /// 某一节课距离上一节课的长度
        var diff: [Int] = []
        if !dayCourses.isEmpty {
            diff.append(dayCourses.first?.course.courseSessions.0 ?? 0)
            for i in 1 ..< dayCourses.count {
                diff.append(
                    dayCourses[i].course.courseSessions.0 -
                        dayCourses[i - 1].course.courseSessions.1
                )
            }
        }
        diff = diff.map { $0 - 1 }

        return zip(dayCourses, diff).map {
            TableCell(courseViewModel: $0.0, distancePrev: $0.1)
        }
    }

    /// 从给定的 allCourseModels 里面**筛选**出给定第几周、星期几的来，构造 DailyViewModel
    /// - Parameters:
    ///   - week: 周次
    ///   - today: 今天星期几，nil 则不高亮显示
    ///   - allCourseModels: 所有的课程
    init(week: Int, today: Int?, from allCourseModels: [CourseViewModel]) {
        self.week = week
        self.today = today
        courseModels = allCourseModels
            .filter { model in
                model.course.hasClass(at: week)
            }
    }
}

// MARK: - TableViewModel.sample

extension TableViewModel {
    static func sample(week: Int, today: Int?) -> TableViewModel {
        TableViewModel(
            week: week,
            today: today,
            from: sampleCourses.map { CourseViewModel(course: $0) }
        )
    }
}

// MARK: - TableCell

extension TableViewModel {
    /// 课程表里的一个单元格，即一节课
    ///
    /// 这里需要包含当前一节课(courseViewModel)，以及距离前一节课的时长
    struct TableCell {
        let courseViewModel: CourseViewModel
        /// 距离上一节课还有几节课
        let distancePrev: Int

        /// 要在课程表上显示的：课程的名称
        var title: String { courseViewModel.course.courseName }

//        /// 距离下一节课还有几节课
//        var distanceNext: Int {
//            courseViewModel.course.courseSessions.1 -
//                (next?.course.courseSessions.0 ??
//                    courseViewModel.course.courseSessions.1
//                )
//        }

        /// 单元格背景
        var color: Color { courseViewModel.color }

        /// 这节课的长度
        var length: Int {
            courseViewModel.length
        }
    }
}
