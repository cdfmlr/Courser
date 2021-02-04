//
//  Client.swift
//  Courser
//
//  Created by c on 2021/2/4.
//

import Foundation
import Combine

/// 教务系统客户端接口
///
/// 教务系统客户端是一个给定学期、周次就能提供这一周的课程的东西
protocol JwClient {
    /// 获取某学期、某周次的课程
    /// - Parameters:
    ///   -  week: 要查询的周次
    ///   -  schoolTerm: 学年学期号
    /// - Returns:
    ///   - 一个 Combine Publisher: 发布某学期、某周次的课程，或以 AppError 失败结束
    func coursesAt(week: Int?, schoolTerm: String?) -> AnyPublisher<[Course], AppError>
}
