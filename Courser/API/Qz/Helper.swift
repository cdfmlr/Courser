//
//  Helper.swift
//  Courser
//
//  Created by c on 2021/2/3.
//

import Foundation

// MARK: - 拓展 Course 模型：从 QzAPI.GetKbcxAzc.ResponseItem 构建 Course
extension Course {
    /// Course from QzAPI.GetKbcxAzc.ResponseItem
    init(from qzAPIResponse: QzAPI.GetKbcxAzc.ResponseItem) {
        self.init(
            courseName: qzAPIResponse.kcmc,
            classroom: qzAPIResponse.jsmc,
            teacher: qzAPIResponse.jsxm,
            startTime: qzAPIResponse.kssj,
            endTime: qzAPIResponse.jssj,
            courseTime: qzAPIResponse.kcsj,
            courseWeeks: qzAPIResponse.kkzc,
            sjbz: qzAPIResponse.sjbz
        )
    }
}
