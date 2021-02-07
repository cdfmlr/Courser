//
//  Sample.swift
//  Courser
//
//  Created by c on 2021/2/5.
//
//  Samples for UI Development.
//

import Foundation

#if DEBUG

    /// 一些样本课程
    let sampleCourses: [Course] = (
        FileHelper.loadBundledJSON(file: "courses")
            as [QzAPI.GetKbcxAzc.ResponseItem])
        .map { Course(from: $0) }

#endif
